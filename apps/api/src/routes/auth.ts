// =============================================================================
// COPE API — Auth routes
// POST /api/v1/auth/login           — clinician OR patient login (local bcrypt, PG 17)
// POST /api/v1/auth/register-demo   — public demo clinician registration
// POST /api/v1/auth/change-password — authenticated password change
// POST /api/v1/auth/mfa/verify      — TOTP second factor (clinicians, otplib)
// POST /api/v1/auth/mfa/enroll      — generate TOTP secret (authenticated)
// POST /api/v1/auth/mfa/activate    — confirm first TOTP code, enable MFA
// POST /api/v1/auth/refresh
// POST /api/v1/auth/logout
// GET  /api/v1/auth/me
// =============================================================================

import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import bcrypt from 'bcryptjs';
import { generateSecret, generateURI, verify as verifyTotp } from 'otplib';
import { sql } from '@cope/db';
import { LoginSchema, RefreshTokenSchema, RegisterSchema } from '@cope/shared';
import { config } from '../config.js';
import { auditLog } from '../middleware/audit.js';
import {
  issueRefreshToken,
  revokeAllForUser,
  rotateRefreshToken,
} from '../services/refresh-tokens.js';
import { sendWelcomeEmail, sendCredentialsEmail } from '../services/messaging.js';
import type { JwtPayload } from '../plugins/auth.js';

// MFA verify only needs the 6-digit code; the clinician identity is
// embedded in the partial JWT issued during login.
const MfaVerifyBodySchema = z.object({
  code: z.string().length(6).regex(/^\d{6}$/, 'Must be a 6-digit code'),
});

// Compared against when an account has no usable password so unknown emails
// take as long as wrong passwords (timing-based enumeration).
const TIMING_PAD_HASH = bcrypt.hashSync('cope-timing-pad', 12);

export default async function authRoutes(fastify: FastifyInstance): Promise<void> {
  // ---------------------------------------------------------------------------
  // POST /login — supports both clinician and patient accounts
  // Stricter rate limit: 10 attempts per minute per IP (brute-force protection)
  // ---------------------------------------------------------------------------
  fastify.post('/login', {
    config: { rateLimit: { max: 10, timeWindow: '1 minute' } },
  }, async (request, reply) => {
    const body = LoginSchema.parse(request.body);

    // -------------------------------------------------------------------------
    // DEV-ONLY: admin:admin bypass for superuser access (no external dependencies)
    // This allows quick testing without MFA or external auth dependencies.
    // -------------------------------------------------------------------------
    if (config.isDev && body.email === 'admin' && body.password === 'admin') {
      // Check for existing dev admin clinician, or create one on-the-fly
      let [devOrg] = await sql<{ id: string }[]>`
        SELECT id FROM organisations WHERE name = 'COPE Dev' LIMIT 1
      `;

      if (!devOrg) {
        [devOrg] = await sql<{ id: string }[]>`
          INSERT INTO organisations (name, type, timezone, locale)
          VALUES ('COPE Dev', 'clinic', 'America/New_York', 'en-US')
          RETURNING id
        `;
      }

      let [devAdmin] = await sql<{ id: string; organisation_id: string }[]>`
        SELECT id, organisation_id FROM clinicians
        WHERE email = 'admin@cope.dev' AND is_active = TRUE
        LIMIT 1
      `;

      if (!devAdmin) {
        [devAdmin] = await sql<{ id: string; organisation_id: string }[]>`
          INSERT INTO clinicians (
            organisation_id, email, first_name, last_name, title, role, mfa_enabled
          ) VALUES (
            ${devOrg!.id}::UUID, 'admin@cope.dev', 'System', 'Administrator', 'Dr', 'admin', FALSE
          )
          RETURNING id, organisation_id
        `;
      }

      if (!devAdmin) throw new Error('[auth] DEV: could not create dev admin');

      const payload: JwtPayload = {
        sub: devAdmin.id,
        email: 'admin@cope.dev',
        role: 'admin',
        org_id: devAdmin.organisation_id,
      };
      const accessToken = fastify.jwt.sign(payload, { expiresIn: config.jwtAccessExpiry });
      const devRefreshToken = await issueRefreshToken({
        userId: devAdmin.id,
        role: 'admin',
        orgId: devAdmin.organisation_id,
      });

      await sql`UPDATE clinicians SET last_login_at = NOW() WHERE id = ${devAdmin.id}`;

      await auditLog({
        actor: payload,
        action: 'login',
        resourceType: 'auth',
        resourceId: devAdmin.id,
        ipAddress: request.ip,
        userAgent: request.headers['user-agent'],
      });

      fastify.log.info('[auth] DEV admin:admin bypass login successful');

      return reply.send({
        success: true,
        data: {
          access_token: accessToken,
          refresh_token: devRefreshToken,
          clinician_id: devAdmin.id,
          org_id: devAdmin.organisation_id,
          role: 'admin',  // Special admin role for frontend routing
          user: { id: devAdmin.id, email: 'admin@cope.dev', role: 'admin', org_id: devAdmin.organisation_id },
        },
      });
    }

    // -------------------------------------------------------------------------
    // Uniform failure: identical 401 for every credential failure so account
    // existence can't be probed; the audit trail keeps the real reason.
    // -------------------------------------------------------------------------
    const invalidCredentials = async (
      failureReason: string,
      actorRole: 'clinician' | 'patient' = 'clinician',
    ) => {
      await auditLog({
        actor: { sub: 'unknown', email: body.email, role: actorRole, org_id: 'unknown' },
        action: 'login',
        resourceType: 'auth',
        ipAddress: request.ip,
        userAgent: request.headers['user-agent'],
        newValues: { attempted_email: body.email },
        success: false,
        failureReason,
      });
      return reply.status(401).send({
        success: false,
        error: { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password' },
      });
    };

    // -------------------------------------------------------------------------
    // CLINICIAN LOGIN — bcrypt against clinicians.password_hash
    // -------------------------------------------------------------------------
    const [clinician] = await sql<{
      id: string; organisation_id: string; role: string; mfa_enabled: boolean;
      mfa_secret: string | null; password_hash: string | null; must_change_password: boolean;
    }[]>`
      SELECT id, organisation_id, role, mfa_enabled, mfa_secret, password_hash, must_change_password
      FROM clinicians
      WHERE email = ${body.email} AND is_active = TRUE
      LIMIT 1
    `;

    if (clinician) {
      if (!clinician.password_hash) {
        // Supabase-era account that never received a local password
        await bcrypt.compare(body.password, TIMING_PAD_HASH);
        return invalidCredentials('no_local_password');
      }

      const passwordValid = await bcrypt.compare(body.password, clinician.password_hash);
      if (!passwordValid) {
        return invalidCredentials('invalid_credentials');
      }

      // TOTP second factor — full token only after /mfa/verify succeeds
      if (clinician.mfa_enabled && clinician.mfa_secret) {
        const partialToken = fastify.jwt.sign(
          {
            sub: clinician.id,
            email: body.email,
            role: 'clinician',
            org_id: clinician.organisation_id,
            mfa_pending: true,
            clinician_id: clinician.id,
          },
          { expiresIn: '5m' },
        );
        return reply.send({ success: true, data: { mfa_required: true, partial_token: partialToken } });
      }

      const payload: JwtPayload = {
        sub: clinician.id,
        email: body.email,
        role: 'clinician',
        org_id: clinician.organisation_id,
      };
      const accessToken = fastify.jwt.sign(payload, { expiresIn: config.jwtAccessExpiry });
      const refreshToken = await issueRefreshToken({
        userId: clinician.id,
        role: 'clinician',
        orgId: clinician.organisation_id,
      });

      await sql`UPDATE clinicians SET last_login_at = NOW() WHERE id = ${clinician.id}`;

      await auditLog({
        actor: payload,
        action: 'login',
        resourceType: 'auth',
        resourceId: clinician.id,
        ipAddress: request.ip,
        userAgent: request.headers['user-agent'],
      });

      return reply.send({
        success: true,
        data: {
          access_token: accessToken,
          refresh_token: refreshToken,
          clinician_id: clinician.id,
          org_id: clinician.organisation_id,
          role: clinician.role,
          must_change_password: clinician.must_change_password,
          user: {
            id: clinician.id,
            email: body.email,
            role: clinician.role,
            org_id: clinician.organisation_id,
            must_change_password: clinician.must_change_password,
          },
        },
      });
    }

    // -------------------------------------------------------------------------
    // PATIENT LOGIN — bcrypt against patients.password_hash
    // -------------------------------------------------------------------------
    const [patient] = await sql<{
      id: string; organisation_id: string; password_hash: string | null;
    }[]>`
      SELECT id, organisation_id, password_hash
      FROM patients
      WHERE email = ${body.email} AND is_active = TRUE
      LIMIT 1
    `;

    if (!patient) {
      await bcrypt.compare(body.password, TIMING_PAD_HASH);
      return invalidCredentials('account_not_found', 'patient');
    }
    if (!patient.password_hash) {
      await bcrypt.compare(body.password, TIMING_PAD_HASH);
      return invalidCredentials('no_local_password', 'patient');
    }
    if (!(await bcrypt.compare(body.password, patient.password_hash))) {
      return invalidCredentials('invalid_credentials', 'patient');
    }

    const patientPayload: JwtPayload = {
      sub: patient.id,
      email: body.email,
      role: 'patient',
      org_id: patient.organisation_id,
    };
    const accessToken = fastify.jwt.sign(patientPayload, { expiresIn: config.jwtAccessExpiry });
    const refreshToken = await issueRefreshToken({
      userId: patient.id,
      role: 'patient',
      orgId: patient.organisation_id,
    });

    await auditLog({
      actor: patientPayload,
      action: 'login',
      resourceType: 'auth',
      resourceId: patient.id,
      ipAddress: request.ip,
      userAgent: request.headers['user-agent'],
    });

    return reply.send({
      success: true,
      data: {
        access_token: accessToken,
        refresh_token: refreshToken,
        patient_id: patient.id,
        org_id: patient.organisation_id,
        role: 'patient',
        user: { id: patient.id, email: body.email, role: 'patient', org_id: patient.organisation_id },
      },
    });
  });

  // ---------------------------------------------------------------------------
  // POST /register-demo — public demo account registration
  // Generates a temp password, hashes with bcrypt, emails via Resend.
  // Rate limit: 20 per 15 minutes per IP
  // ---------------------------------------------------------------------------
  const RegisterDemoBodySchema = z.object({
    email: z.string().email('Must be a valid email address'),
    firstName: z.string().min(1, 'First name is required').max(100),
    lastName: z.string().min(1, 'Last name is required').max(100),
    phone: z.string().max(30).optional(),
  });

  fastify.post('/register-demo', {
    config: { rateLimit: { max: 20, timeWindow: '15 minutes' } },
  }, async (request, reply) => {
    const body = RegisterDemoBodySchema.parse(request.body);

    // Always return success to prevent email enumeration
    const successResponse = {
      success: true,
      data: { message: 'If that email is not already registered, you will receive your credentials shortly.' },
    };

    // Check if email already exists (clinician)
    const [existing] = await sql<{ id: string }[]>`
      SELECT id FROM clinicians
      WHERE lower(email) = lower(${body.email})
      LIMIT 1
    `;

    if (existing) {
      // Don't reveal that account exists — return same success message
      return reply.send(successResponse);
    }

    // Generate 12-char temp password (exclude ambiguous chars: I, l, O, 0)
    const CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$%&*';
    const tempPassword = Array.from(
      { length: 12 },
      () => CHARS[Math.floor(Math.random() * CHARS.length)],
    ).join('');

    // Hash with bcrypt (12 rounds)
    const passwordHash = await bcrypt.hash(tempPassword, 12);

    // Demo org: COPE Demo Clinic
    const DEMO_ORG_ID = 'f46cc7e7-163a-4291-acc3-148044a5b232';

    // Insert clinician with 'researcher' role (safe default within CHECK constraint)
    try {
      const [newClinician] = await sql<{ id: string }[]>`
        INSERT INTO clinicians (
          organisation_id, email, first_name, last_name, role,
          password_hash, must_change_password, is_active, mfa_enabled
        ) VALUES (
          ${DEMO_ORG_ID}::UUID,
          ${body.email.toLowerCase()},
          ${body.firstName},
          ${body.lastName},
          'researcher',
          ${passwordHash},
          TRUE,
          TRUE,
          FALSE
        )
        RETURNING id
      `;

      if (!newClinician) {
        fastify.log.error('[register-demo] Insert returned no rows');
        return reply.send(successResponse);
      }

      // Audit
      await auditLog({
        actor: { sub: newClinician.id, email: body.email, role: 'clinician', org_id: DEMO_ORG_ID },
        action: 'create',
        resourceType: 'clinician',
        resourceId: newClinician.id,
        ipAddress: request.ip,
        userAgent: request.headers['user-agent'],
      });

      // Send credentials email
      try {
        await sendCredentialsEmail({
          to: body.email,
          firstName: body.firstName,
          tempPassword,
        });
      } catch (err) {
        fastify.log.error({ err }, '[register-demo] Failed to send credentials email');
      }
    } catch (err) {
      fastify.log.error({ err }, '[register-demo] Failed to create demo clinician');
    }

    return reply.send(successResponse);
  });

  // ---------------------------------------------------------------------------
  // POST /change-password — authenticated password change
  // Used after login when must_change_password is true
  // ---------------------------------------------------------------------------
  const ChangePasswordBodySchema = z.object({
    currentPassword: z.string().min(1, 'Current password is required'),
    newPassword: z.string().min(8, 'Password must be at least 8 characters').max(128),
  });

  fastify.post('/change-password', {
    preHandler: [fastify.authenticate],
  }, async (request, reply) => {
    const body = ChangePasswordBodySchema.parse(request.body);

    if (body.currentPassword === body.newPassword) {
      return reply.status(400).send({
        success: false,
        error: { code: 'SAME_PASSWORD', message: 'New password must be different from current password' },
      });
    }

    // Look up clinician's current password_hash
    const [clinician] = await sql<{
      id: string; password_hash: string | null;
    }[]>`
      SELECT id, password_hash FROM clinicians
      WHERE email = ${request.user.email} AND is_active = TRUE
      LIMIT 1
    `;

    if (!clinician?.password_hash) {
      return reply.status(400).send({
        success: false,
        error: { code: 'NO_PASSWORD', message: 'This account does not use password authentication' },
      });
    }

    // Verify current password
    const currentValid = await bcrypt.compare(body.currentPassword, clinician.password_hash);
    if (!currentValid) {
      return reply.status(401).send({
        success: false,
        error: { code: 'INVALID_PASSWORD', message: 'Current password is incorrect' },
      });
    }

    // Hash new password and update
    const newHash = await bcrypt.hash(body.newPassword, 12);
    await sql`
      UPDATE clinicians
      SET password_hash = ${newHash},
          must_change_password = FALSE,
          updated_at = NOW()
      WHERE id = ${clinician.id}
    `;

    await auditLog({
      actor: request.user,
      action: 'update',
      resourceType: 'clinician',
      resourceId: clinician.id,
      ipAddress: request.ip,
      userAgent: request.headers['user-agent'],
    });

    return reply.send({
      success: true,
      data: { message: 'Password changed successfully', must_change_password: false },
    });
  });

  // ---------------------------------------------------------------------------
  // POST /register — invite-only patient self-registration
  // Stricter rate limit: 5 registrations per minute per IP
  // ---------------------------------------------------------------------------
  fastify.post('/register', {
    config: { rateLimit: { max: 5, timeWindow: '1 minute' } },
  }, async (request, reply) => {
    const body = RegisterSchema.parse(request.body);

    // --- 1. Validate invite token -------------------------------------------
    const [invite] = await sql<{
      id: string; clinician_id: string; org_id: string;
      email: string; personal_message: string | null;
    }[]>`
      SELECT id, clinician_id, org_id, email, personal_message
      FROM patient_invites
      WHERE token = ${body.invite_token}
        AND status = 'pending'
        AND expires_at > NOW()
      LIMIT 1
    `;

    if (!invite) {
      return reply.status(400).send({
        success: false,
        error: { code: 'INVITE_INVALID', message: 'Invite token is invalid or has expired' },
      });
    }

    // Emails must match (case-insensitive)
    if (invite.email.toLowerCase() !== body.email.toLowerCase()) {
      return reply.status(400).send({
        success: false,
        error: { code: 'EMAIL_MISMATCH', message: 'Email does not match the invite' },
      });
    }

    // --- 2. Guard: email already registered ---------------------------------
    const [existingPatient] = await sql<{ id: string }[]>`
      SELECT id FROM patients
      WHERE lower(email) = lower(${body.email})
        AND is_active = TRUE
      LIMIT 1
    `;
    if (existingPatient) {
      return reply.status(409).send({
        success: false,
        error: { code: 'EMAIL_TAKEN', message: 'An account with this email already exists' },
      });
    }

    // --- 3. Hash password (local auth — bcrypt 12 rounds) --------------------
    const passwordHash = await bcrypt.hash(body.password, 12);

    // --- 4. Insert patient row ----------------------------------------------
    const autoMrn = `AUTO-${Date.now().toString(36).toUpperCase()}`;

    const [newPatient] = await sql<{ id: string }[]>`
      INSERT INTO patients (
        organisation_id, mrn, email, password_hash,
        first_name, last_name, date_of_birth,
        timezone, invite_id
      ) VALUES (
        ${invite.org_id}::UUID,
        ${autoMrn},
        ${body.email},
        ${passwordHash},
        ${body.first_name},
        ${body.last_name},
        ${body.date_of_birth}::DATE,
        ${body.timezone},
        ${invite.id}::UUID
      )
      RETURNING id
    `;

    if (!newPatient) {
      return reply.status(500).send({
        success: false,
        error: { code: 'INTERNAL_ERROR', message: 'Failed to create patient record' },
      });
    }

    const patientId = newPatient.id;

    // --- 5. Mark invite as accepted -----------------------------------------
    await sql`
      UPDATE patient_invites
      SET status      = 'accepted',
          patient_id  = ${patientId}::UUID,
          accepted_at = NOW()
      WHERE id = ${invite.id}::UUID
    `;

    // --- 6. Add clinician to care team --------------------------------------
    await sql`
      INSERT INTO care_team_members (patient_id, clinician_id, role)
      VALUES (${patientId}::UUID, ${invite.clinician_id}::UUID, 'primary')
      ON CONFLICT (patient_id, clinician_id, role) DO NOTHING
    `;

    // --- 7. Seed required consents (user agreed to ToS/PP by submitting form) ---
    const ipAddress = request.ip;
    await sql`
      INSERT INTO consent_records
        (patient_id, consent_type, granted, consent_version, ip_address)
      VALUES
        (${patientId}::UUID, 'terms_of_service', TRUE, '1.0', ${ipAddress}::INET),
        (${patientId}::UUID, 'privacy_policy',   TRUE, '1.0', ${ipAddress}::INET)
    `;

    // --- 8. Alert clinician: new patient registered -------------------------
    try {
      await sql`
        INSERT INTO clinical_alerts
          (patient_id, organisation_id, alert_type, severity, title, body)
        VALUES (
          ${patientId}::UUID,
          ${invite.org_id}::UUID,
          'patient_registered',
          'info',
          'New patient registered',
          ${`${body.first_name} ${body.last_name} has registered and completed their account setup.`}
        )
      `;
    } catch (err) {
      fastify.log.warn({ err }, '[register] Failed to insert patient_registered alert');
    }

    // --- 9. Audit log -------------------------------------------------------
    await auditLog({
      actor: { sub: patientId, email: body.email, role: 'patient', org_id: invite.org_id },
      action: 'create',
      resourceType: 'patient',
      resourceId: patientId,
      ipAddress: request.ip,
      userAgent: request.headers['user-agent'],
    });

    // --- 10. Send welcome email ---------------------------------------------
    try {
      const [clinicianRow] = await sql<{ first_name: string; last_name: string }[]>`
        SELECT first_name, last_name FROM clinicians WHERE id = ${invite.clinician_id}::UUID LIMIT 1
      `;
      await sendWelcomeEmail({
        to: body.email,
        firstName: body.first_name,
        clinicianName: clinicianRow
          ? `${clinicianRow.first_name} ${clinicianRow.last_name}`
          : 'your care team',
      });
    } catch (err) {
      fastify.log.error({ err }, '[register] sendWelcomeEmail failed');
    }

    // --- 11. Issue tokens -----------------------------------------------------
    const registerRefreshToken = await issueRefreshToken({
      userId: patientId,
      role: 'patient',
      orgId: invite.org_id,
    });

    const jwtPayload: JwtPayload = {
      sub: patientId,
      email: body.email,
      role: 'patient',
      org_id: invite.org_id,
    };
    const accessToken = fastify.jwt.sign(jwtPayload, { expiresIn: config.jwtAccessExpiry });

    return reply.status(201).send({
      success: true,
      data: {
        access_token: accessToken,
        refresh_token: registerRefreshToken,
        patient_id: patientId,
        org_id: invite.org_id,
        role: 'patient',
        user: { id: patientId, email: body.email, role: 'patient', org_id: invite.org_id },
      },
    });
  });

  // ---------------------------------------------------------------------------
  // POST /mfa/verify — complete TOTP second factor for clinicians
  // The clinician identity is read from the partial JWT (not the request body);
  // the code is checked against the locally stored TOTP secret.
  // ---------------------------------------------------------------------------
  fastify.post('/mfa/verify', async (request, reply) => {
    const body = MfaVerifyBodySchema.parse(request.body);

    try {
      const partial = await request.jwtVerify<JwtPayload>();

      if (!partial.mfa_pending || !partial.clinician_id) {
        return reply.status(400).send({
          success: false,
          error: { code: 'BAD_REQUEST', message: 'MFA not required for this token' },
        });
      }

      const [clinician] = await sql<{
        id: string; organisation_id: string; role: string;
        mfa_secret: string | null; must_change_password: boolean;
      }[]>`
        SELECT id, organisation_id, role, mfa_secret, must_change_password
        FROM clinicians
        WHERE id = ${partial.clinician_id} AND is_active = TRUE
        LIMIT 1
      `;

      if (!clinician?.mfa_secret || !(await verifyTotp({ token: body.code, secret: clinician.mfa_secret })).valid) {
        await auditLog({
          actor: { sub: partial.sub, email: partial.email, role: 'clinician', org_id: partial.org_id },
          action: 'login',
          resourceType: 'auth',
          ipAddress: request.ip,
          userAgent: request.headers['user-agent'],
          success: false,
          failureReason: 'mfa_invalid',
        });
        return reply.status(401).send({
          success: false,
          error: { code: 'MFA_INVALID', message: 'Invalid MFA code' },
        });
      }

      const fullPayload: JwtPayload = {
        sub: partial.sub,
        email: partial.email,
        role: partial.role,
        org_id: partial.org_id,
      };
      const accessToken = fastify.jwt.sign(fullPayload, { expiresIn: config.jwtAccessExpiry });
      const refreshToken = await issueRefreshToken({
        userId: clinician.id,
        role: 'clinician',
        orgId: clinician.organisation_id,
      });

      await sql`UPDATE clinicians SET last_login_at = NOW() WHERE id = ${clinician.id}`;

      await auditLog({
        actor: fullPayload,
        action: 'login',
        resourceType: 'auth',
        resourceId: clinician.id,
        ipAddress: request.ip,
        userAgent: request.headers['user-agent'],
      });

      return reply.send({
        success: true,
        data: {
          access_token: accessToken,
          refresh_token: refreshToken,
          clinician_id: clinician.id,
          org_id: fullPayload.org_id,
          role: 'clinician',
          must_change_password: clinician.must_change_password,
          user: {
            id: clinician.id,
            email: fullPayload.email,
            role: 'clinician',
            org_id: fullPayload.org_id,
          },
        },
      });
    } catch {
      return reply.status(401).send({
        success: false,
        error: { code: 'UNAUTHORIZED', message: 'Invalid or expired partial token' },
      });
    }
  });

  // ---------------------------------------------------------------------------
  // POST /mfa/enroll — generate a TOTP secret for the authenticated clinician.
  // MFA only takes effect after /mfa/activate confirms the first code.
  // ---------------------------------------------------------------------------
  fastify.post('/mfa/enroll', { preHandler: [fastify.authenticate] }, async (request, reply) => {
    if (request.user.role === 'patient') {
      return reply.status(403).send({
        success: false,
        error: { code: 'FORBIDDEN', message: 'MFA enrollment is for clinicians' },
      });
    }

    const secret = generateSecret();
    const [clinician] = await sql<{ id: string }[]>`
      UPDATE clinicians
      SET mfa_secret = ${secret}, mfa_enabled = FALSE, updated_at = NOW()
      WHERE email = ${request.user.email} AND is_active = TRUE
      RETURNING id
    `;

    if (!clinician) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Clinician not found' },
      });
    }

    return reply.send({
      success: true,
      data: {
        secret,
        otpauth_url: generateURI({ issuer: 'COPE', label: request.user.email, secret }),
      },
    });
  });

  // ---------------------------------------------------------------------------
  // POST /mfa/activate — verify the first TOTP code and switch MFA on
  // ---------------------------------------------------------------------------
  fastify.post('/mfa/activate', { preHandler: [fastify.authenticate] }, async (request, reply) => {
    const body = MfaVerifyBodySchema.parse(request.body);

    const [clinician] = await sql<{ id: string; mfa_secret: string | null }[]>`
      SELECT id, mfa_secret FROM clinicians
      WHERE email = ${request.user.email} AND is_active = TRUE
      LIMIT 1
    `;

    if (!clinician?.mfa_secret || !(await verifyTotp({ token: body.code, secret: clinician.mfa_secret })).valid) {
      return reply.status(401).send({
        success: false,
        error: { code: 'MFA_INVALID', message: 'Invalid MFA code' },
      });
    }

    await sql`UPDATE clinicians SET mfa_enabled = TRUE, updated_at = NOW() WHERE id = ${clinician.id}`;

    await auditLog({
      actor: request.user,
      action: 'update',
      resourceType: 'clinician',
      resourceId: clinician.id,
      ipAddress: request.ip,
      userAgent: request.headers['user-agent'],
      newValues: { mfa_enabled: true },
    });

    return reply.send({ success: true, data: { mfa_enabled: true } });
  });

  // ---------------------------------------------------------------------------
  // POST /refresh — rotate a first-party refresh token (clinician or patient)
  // ---------------------------------------------------------------------------
  fastify.post('/refresh', async (request, reply) => {
    const body = RefreshTokenSchema.parse(request.body);

    const rotated = await rotateRefreshToken(body.refresh_token);
    if (!rotated) {
      return reply.status(401).send({
        success: false,
        error: { code: 'INVALID_REFRESH_TOKEN', message: 'Refresh token is invalid or expired' },
      });
    }

    const { owner, newToken } = rotated;
    const table = owner.role === 'patient' ? 'patients' : 'clinicians';
    const [account] = owner.role === 'patient'
      ? await sql<{ id: string; email: string; organisation_id: string }[]>`
          SELECT id, email, organisation_id FROM patients
          WHERE id = ${owner.userId} AND is_active = TRUE LIMIT 1
        `
      : await sql<{ id: string; email: string; organisation_id: string }[]>`
          SELECT id, email, organisation_id FROM clinicians
          WHERE id = ${owner.userId} AND is_active = TRUE LIMIT 1
        `;

    if (!account) {
      // Account deactivated since the token was issued — kill the session line.
      await revokeAllForUser(owner.userId);
      request.log.warn({ table, userId: owner.userId }, '[auth] refresh for inactive account');
      return reply.status(401).send({
        success: false,
        error: { code: 'INVALID_REFRESH_TOKEN', message: 'Refresh token is invalid or expired' },
      });
    }

    const payload: JwtPayload = {
      sub: account.id,
      email: account.email,
      role: owner.role,
      org_id: account.organisation_id,
    };
    const accessToken = fastify.jwt.sign(payload, { expiresIn: config.jwtAccessExpiry });

    return reply.send({
      success: true,
      data: { access_token: accessToken, refresh_token: newToken },
    });
  });

  // ---------------------------------------------------------------------------
  // POST /logout
  // ---------------------------------------------------------------------------
  fastify.post('/logout', { preHandler: [fastify.authenticate] }, async (request, reply) => {
    await revokeAllForUser(request.user.sub);
    await auditLog({
      actor: request.user,
      action: 'logout',
      resourceType: 'auth',
      ipAddress: request.ip,
      userAgent: request.headers['user-agent'],
    });
    return reply.send({ success: true, data: { message: 'Logged out' } });
  });

  // ---------------------------------------------------------------------------
  // GET /me — current user profile (clinician or patient)
  // ---------------------------------------------------------------------------
  fastify.get('/me', { preHandler: [fastify.authenticate] }, async (request, reply) => {
    if (request.user.role === 'patient') {
      const [patient] = await sql<{
        id: string; first_name: string; last_name: string; email: string;
        date_of_birth: string; status: string; preferred_name: string | null;
      }[]>`
        SELECT id, first_name, last_name, email, date_of_birth, status, preferred_name
        FROM patients
        WHERE email = ${request.user.email} AND is_active = TRUE
        LIMIT 1
      `;
      if (!patient) {
        return reply.status(404).send({
          success: false,
          error: { code: 'NOT_FOUND', message: 'Patient not found' },
        });
      }
      return reply.send({ success: true, data: { ...patient, role: 'patient' } });
    }

    // Clinician
    const [clinician] = await sql<{
      id: string; first_name: string; last_name: string; title: string | null;
      role: string; npi: string | null; email: string; mfa_enabled: boolean;
    }[]>`
      SELECT id, first_name, last_name, title, role, npi, email, mfa_enabled
      FROM clinicians
      WHERE email = ${request.user.email} AND is_active = TRUE
      LIMIT 1
    `;
    if (!clinician) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Clinician not found' },
      });
    }
    return reply.send({ success: true, data: clinician });
  });
}
