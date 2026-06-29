// =============================================================================
// COPE API - Mobile-critical OpenAPI route schemas
// Keep these explicit and conservative until all route contracts are formalized.
// =============================================================================

const uuid = { type: 'string', format: 'uuid' } as const;
const isoDate = { type: 'string', pattern: '^\\d{4}-\\d{2}-\\d{2}$' } as const;
const isoDateTime = { type: 'string', format: 'date-time' } as const;

const errorResponse = {
  type: 'object',
  required: ['success', 'error'],
  additionalProperties: true,
  properties: {
    success: { type: 'boolean' },
    error: {
      type: 'object',
      required: ['code', 'message'],
      additionalProperties: true,
      properties: {
        code: { type: 'string' },
        message: { type: 'string' },
      },
    },
  },
} as const;

const successResponse = {
  type: 'object',
  required: ['success', 'data'],
  additionalProperties: true,
  properties: {
    success: { type: 'boolean' },
    data: {
      type: 'object',
      additionalProperties: true,
    },
  },
} as const;

const authSessionResponse = {
  type: 'object',
  required: ['success', 'data'],
  additionalProperties: true,
  properties: {
    success: { type: 'boolean' },
    data: {
      type: 'object',
      required: ['access_token', 'role', 'org_id', 'user'],
      additionalProperties: true,
      properties: {
        access_token: { type: 'string' },
        refresh_token: { type: 'string' },
        patient_id: uuid,
        clinician_id: uuid,
        org_id: uuid,
        role: { type: 'string', enum: ['patient', 'clinician', 'admin', 'researcher'] },
        mfa_required: { type: 'boolean' },
        partial_token: { type: 'string' },
        must_change_password: { type: 'boolean' },
        user: {
          type: 'object',
          required: ['id', 'email', 'role', 'org_id'],
          additionalProperties: true,
          properties: {
            id: uuid,
            email: { type: 'string', format: 'email' },
            role: { type: 'string' },
            org_id: uuid,
          },
        },
      },
    },
  },
} as const;

const authHeader = [
  {
    bearerAuth: [],
  },
] as const;

export const loginRouteSchema = {
  tags: ['auth'],
  summary: 'Log in as a patient or clinician',
  body: {
    type: 'object',
    required: ['email', 'password'],
    additionalProperties: false,
    properties: {
      email: { type: 'string', description: 'Email address, or admin in local development.' },
      password: { type: 'string', minLength: 1, maxLength: 128 },
    },
  },
  response: {
    200: authSessionResponse,
    401: errorResponse,
  },
} as const;

export const registerRouteSchema = {
  tags: ['auth'],
  summary: 'Register an invited patient account',
  body: {
    type: 'object',
    required: ['invite_token', 'email', 'password', 'first_name', 'last_name', 'date_of_birth'],
    additionalProperties: false,
    properties: {
      invite_token: { type: 'string', minLength: 1 },
      email: { type: 'string', format: 'email' },
      password: { type: 'string', minLength: 12, maxLength: 128 },
      first_name: { type: 'string', minLength: 1, maxLength: 100 },
      last_name: { type: 'string', minLength: 1, maxLength: 100 },
      date_of_birth: isoDate,
      timezone: { type: 'string', maxLength: 100, default: 'America/New_York' },
    },
  },
  response: {
    201: authSessionResponse,
    400: errorResponse,
    409: errorResponse,
    500: errorResponse,
  },
} as const;

export const mfaVerifyRouteSchema = {
  tags: ['auth'],
  summary: 'Verify a TOTP MFA code using a partial MFA token',
  security: authHeader,
  body: {
    type: 'object',
    required: ['code'],
    additionalProperties: false,
    properties: {
      code: { type: 'string', pattern: '^\\d{6}$' },
    },
  },
  response: {
    200: authSessionResponse,
    400: errorResponse,
    401: errorResponse,
  },
} as const;

export const refreshRouteSchema = {
  tags: ['auth'],
  summary: 'Rotate a refresh token and issue a new access token',
  body: {
    type: 'object',
    required: ['refresh_token'],
    additionalProperties: false,
    properties: {
      refresh_token: { type: 'string', minLength: 1 },
    },
  },
  response: {
    200: authSessionResponse,
    401: errorResponse,
  },
} as const;

const dailyEntryAssociations = {
  triggers: {
    type: 'array',
    maxItems: 20,
    items: {
      type: 'object',
      required: ['trigger_id', 'severity'],
      additionalProperties: false,
      properties: {
        trigger_id: uuid,
        severity: { type: 'integer', minimum: 1, maximum: 10 },
      },
    },
  },
  symptoms: {
    type: 'array',
    maxItems: 20,
    items: {
      type: 'object',
      required: ['symptom_id', 'severity'],
      additionalProperties: false,
      properties: {
        symptom_id: uuid,
        severity: { type: 'integer', minimum: 1, maximum: 10 },
      },
    },
  },
  strategies: {
    type: 'array',
    maxItems: 20,
    items: {
      type: 'object',
      required: ['strategy_id'],
      additionalProperties: false,
      properties: {
        strategy_id: uuid,
        helped: { type: ['boolean', 'null'] },
      },
    },
  },
} as const;

export const createDailyEntryRouteSchema = {
  tags: ['daily-entries'],
  summary: 'Create or upsert a patient daily check-in',
  security: authHeader,
  body: {
    type: 'object',
    required: ['entry_date', 'mood_score'],
    additionalProperties: false,
    properties: {
      entry_date: isoDate,
      mood_score: { type: 'integer', minimum: 1, maximum: 10 },
      sleep_hours: { type: ['number', 'null'], minimum: 0, maximum: 24 },
      sleep_quality: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
      exercise_minutes: { type: ['integer', 'null'], minimum: 0, maximum: 1440 },
      notes: { type: ['string', 'null'], maxLength: 1000 },
      ...dailyEntryAssociations,
      mania_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
      racing_thoughts: { type: ['boolean', 'null'] },
      decreased_sleep_need: { type: ['boolean', 'null'] },
      anxiety_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
      somatic_anxiety: { type: ['boolean', 'null'] },
      anhedonia_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
      suicidal_ideation: { type: ['integer', 'null'], minimum: 0, maximum: 3 },
      substance_use: { type: ['string', 'null'], enum: ['none', 'alcohol', 'cannabis', 'other', null] },
      substance_quantity: { type: ['integer', 'null'], minimum: 0, maximum: 99 },
      social_score: { type: ['integer', 'null'], minimum: 1, maximum: 5 },
      social_avoidance: { type: ['boolean', 'null'] },
      cognitive_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
      brain_fog: { type: ['boolean', 'null'] },
      appetite_score: { type: ['integer', 'null'], minimum: 1, maximum: 5 },
      stress_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
      life_event_note: { type: ['string', 'null'], maxLength: 500 },
    },
  },
  response: {
    201: successResponse,
    400: errorResponse,
    401: errorResponse,
  },
} as const;

export const getTodayDailyEntryRouteSchema = {
  tags: ['daily-entries'],
  summary: "Get today's daily check-in",
  security: authHeader,
  response: {
    200: successResponse,
    401: errorResponse,
    404: errorResponse,
  },
} as const;

export const submitDailyEntryRouteSchema = {
  tags: ['daily-entries'],
  summary: 'Mark a daily check-in as submitted',
  security: authHeader,
  params: {
    type: 'object',
    required: ['id'],
    additionalProperties: false,
    properties: { id: uuid },
  },
  response: {
    200: successResponse,
    401: errorResponse,
    404: errorResponse,
  },
} as const;

const consentTypeEnum = [
  'share_with_clinician',
  'share_journal_with_clinician',
  'research_participation',
  'data_export',
  'push_notifications',
  'terms_of_service',
  'privacy_policy',
  'journal_sharing',
  'data_research',
  'ai_insights',
  'emergency_contact',
] as const;

export const listConsentRouteSchema = {
  tags: ['consent'],
  summary: 'List latest patient consent records by type',
  security: authHeader,
  response: {
    200: {
      type: 'object',
      required: ['success', 'data'],
      additionalProperties: true,
      properties: {
        success: { type: 'boolean' },
        data: {
          type: 'array',
          items: {
            type: 'object',
            required: ['id', 'consent_type', 'granted', 'granted_at'],
            additionalProperties: true,
            properties: {
              id: uuid,
              consent_type: { type: 'string', enum: consentTypeEnum },
              granted: { type: 'boolean' },
              granted_at: isoDateTime,
              expires_at: { type: ['string', 'null'], format: 'date-time' },
              revoked_at: { type: ['string', 'null'], format: 'date-time' },
            },
          },
        },
      },
    },
    401: errorResponse,
    403: errorResponse,
  },
} as const;

export const updateConsentRouteSchema = {
  tags: ['consent'],
  summary: 'Grant or update a patient consent record',
  security: authHeader,
  body: {
    type: 'object',
    required: ['consent_type', 'granted'],
    additionalProperties: false,
    properties: {
      consent_type: { type: 'string', enum: consentTypeEnum },
      granted: { type: 'boolean' },
    },
  },
  response: {
    201: successResponse,
    400: errorResponse,
    401: errorResponse,
    403: errorResponse,
  },
} as const;

export const revokeConsentRouteSchema = {
  tags: ['consent'],
  summary: 'Revoke an app-revocable patient consent type',
  security: authHeader,
  params: {
    type: 'object',
    required: ['type'],
    additionalProperties: false,
    properties: {
      type: {
        type: 'string',
        enum: ['journal_sharing', 'data_research', 'ai_insights', 'emergency_contact'],
      },
    },
  },
  response: {
    200: successResponse,
    400: errorResponse,
    401: errorResponse,
    403: errorResponse,
  },
} as const;

const paginationQuery = {
  type: 'object',
  additionalProperties: false,
  properties: {
    page: { type: 'integer', minimum: 1, default: 1 },
    limit: { type: 'integer', minimum: 1, maximum: 100, default: 20 },
  },
} as const;

const medicationFrequencyEnum = [
  'once_daily_morning',
  'once_daily_evening',
  'once_daily_bedtime',
  'twice_daily',
  'three_times_daily',
  'as_needed',
  'weekly',
  'other',
] as const;

const assessmentScaleEnum = ['PHQ-9', 'GAD-7', 'ASRM', 'ISI', 'C-SSRS', 'WHODAS', 'QIDS-SR'] as const;

export const getPatientMeRouteSchema = {
  tags: ['patients'],
  summary: 'Get the authenticated patient profile',
  security: authHeader,
  response: {
    200: successResponse,
    403: errorResponse,
    404: errorResponse,
  },
} as const;

export const updatePatientMeRouteSchema = {
  tags: ['patients'],
  summary: 'Update authenticated patient profile preferences',
  security: authHeader,
  body: {
    type: 'object',
    additionalProperties: false,
    properties: {
      preferred_name: { type: 'string', maxLength: 100 },
      timezone: { type: 'string', maxLength: 60 },
    },
  },
  response: {
    200: successResponse,
    400: errorResponse,
    403: errorResponse,
    404: errorResponse,
  },
} as const;

export const updatePatientIntakeRouteSchema = {
  tags: ['patients'],
  summary: 'Update authenticated patient onboarding intake fields',
  security: authHeader,
  body: {
    type: 'object',
    additionalProperties: false,
    properties: {
      primary_concern: { type: 'string', maxLength: 500 },
      emergency_contact_name: { type: 'string', maxLength: 200 },
      emergency_contact_phone: { type: 'string', maxLength: 30 },
      emergency_contact_relationship: { type: 'string', maxLength: 100 },
      mark_complete: { type: 'boolean' },
    },
  },
  response: {
    200: successResponse,
    400: errorResponse,
    403: errorResponse,
    404: errorResponse,
  },
} as const;

export const createJournalEntryRouteSchema = {
  tags: ['journal'],
  summary: 'Create or upsert today journal entry',
  security: authHeader,
  body: {
    type: 'object',
    required: ['body'],
    additionalProperties: false,
    properties: {
      title: { type: ['string', 'null'], maxLength: 200 },
      body: { type: 'string', minLength: 1, maxLength: 20000 },
      mood_at_writing: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
      is_shared_with_care_team: { type: 'boolean', default: false },
      tags: {
        type: 'array',
        maxItems: 20,
        items: { type: 'string', minLength: 1, maxLength: 50 },
      },
    },
  },
  response: {
    201: successResponse,
    400: errorResponse,
    401: errorResponse,
  },
} as const;

export const listJournalEntriesRouteSchema = {
  tags: ['journal'],
  summary: 'List authenticated patient journal entries',
  security: authHeader,
  querystring: paginationQuery,
  response: {
    200: successResponse,
    401: errorResponse,
  },
} as const;

export const getTodayMedicationsRouteSchema = {
  tags: ['medications'],
  summary: "Get today's active medications and adherence status",
  security: authHeader,
  response: {
    200: successResponse,
    403: errorResponse,
  },
} as const;

export const createMedicationRouteSchema = {
  tags: ['medications'],
  summary: 'Add a patient medication',
  security: authHeader,
  body: {
    type: 'object',
    required: ['medication_name', 'frequency'],
    additionalProperties: false,
    properties: {
      medication_name: { type: 'string', minLength: 1, maxLength: 200 },
      dose: { type: ['number', 'null'], exclusiveMinimum: 0 },
      dose_unit: { type: 'string', maxLength: 20, default: 'mg' },
      frequency: { type: 'string', enum: medicationFrequencyEnum },
      frequency_other: { type: ['string', 'null'], maxLength: 200 },
      instructions: { type: ['string', 'null'], maxLength: 500 },
      prescribed_at: { ...isoDate, nullable: true },
      show_in_app: { type: 'boolean', default: true },
    },
  },
  response: {
    201: successResponse,
    400: errorResponse,
    401: errorResponse,
  },
} as const;

export const logMedicationAdherenceRouteSchema = {
  tags: ['medications'],
  summary: 'Log or upsert patient medication adherence',
  security: authHeader,
  params: {
    type: 'object',
    required: ['id'],
    additionalProperties: false,
    properties: { id: uuid },
  },
  body: {
    type: 'object',
    required: ['taken'],
    additionalProperties: false,
    properties: {
      entry_date: isoDate,
      taken: { type: 'boolean' },
      taken_at: { type: ['string', 'null'], format: 'date-time' },
      notes: { type: ['string', 'null'], maxLength: 500 },
    },
  },
  response: {
    201: successResponse,
    400: errorResponse,
    403: errorResponse,
    404: errorResponse,
  },
} as const;

export const listMedicationLogsRouteSchema = {
  tags: ['medications'],
  summary: 'List adherence history for a medication',
  security: authHeader,
  params: {
    type: 'object',
    required: ['id'],
    additionalProperties: false,
    properties: { id: uuid },
  },
  querystring: paginationQuery,
  response: {
    200: successResponse,
    400: errorResponse,
    404: errorResponse,
  },
} as const;

export const submitAssessmentRouteSchema = {
  tags: ['assessments'],
  summary: 'Submit a completed validated assessment scale',
  security: authHeader,
  body: {
    type: 'object',
    required: ['scale', 'score', 'item_responses'],
    additionalProperties: false,
    properties: {
      scale: { type: 'string', enum: assessmentScaleEnum },
      score: { type: 'integer', minimum: 0, maximum: 100 },
      item_responses: {
        type: 'object',
        additionalProperties: { type: 'integer', minimum: 0, maximum: 9 },
      },
      notes: { type: 'string', maxLength: 2000 },
    },
  },
  response: {
    201: successResponse,
    400: errorResponse,
    403: errorResponse,
  },
} as const;

export const submitAssessmentByScaleRouteSchema = {
  tags: ['assessments'],
  summary: 'Submit a completed validated assessment scale using the scale path parameter',
  security: authHeader,
  params: {
    type: 'object',
    required: ['scale'],
    additionalProperties: false,
    properties: {
      scale: { type: 'string', enum: assessmentScaleEnum },
    },
  },
  body: {
    type: 'object',
    required: ['score', 'item_responses'],
    additionalProperties: false,
    properties: {
      score: { type: 'integer', minimum: 0, maximum: 100 },
      item_responses: {
        type: 'object',
        additionalProperties: { type: 'integer', minimum: 0, maximum: 9 },
      },
      notes: { type: 'string', maxLength: 2000 },
    },
  },
  response: {
    201: successResponse,
    400: errorResponse,
    403: errorResponse,
  },
} as const;

export const getPendingAssessmentsRouteSchema = {
  tags: ['assessments'],
  summary: 'List assessment scales due for the authenticated patient',
  security: authHeader,
  response: {
    200: successResponse,
    403: errorResponse,
  },
} as const;

const syncCollectionChanges = {
  type: 'object',
  additionalProperties: false,
  properties: {
    created: { type: 'array', items: { type: 'object', additionalProperties: true }, default: [] },
    updated: { type: 'array', items: { type: 'object', additionalProperties: true }, default: [] },
    deleted: { type: 'array', items: { type: 'string' }, default: [] },
  },
} as const;

const nullableDateTimeOrEpoch = {
  anyOf: [
    { type: 'string', format: 'date-time' },
    { type: 'number' },
    { type: 'null' },
  ],
} as const;

const syncDailyEntryRecord = {
  type: 'object',
  additionalProperties: true,
  properties: {
    id: uuid,
    server_id: { ...uuid, nullable: true },
    patient_id: uuid,
    entry_date: isoDate,
    mood_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
    sleep_hours: { type: ['number', 'null'], minimum: 0, maximum: 24 },
    exercise_minutes: { type: ['integer', 'null'], minimum: 0, maximum: 1440 },
    notes: { type: ['string', 'null'], maxLength: 1000 },
    is_complete: { type: 'boolean' },
    completion_pct: { type: 'integer', minimum: 0, maximum: 100 },
    core_complete: { type: 'boolean' },
    wellness_complete: { type: 'boolean' },
    triggers_complete: { type: 'boolean' },
    symptoms_complete: { type: 'boolean' },
    journal_complete: { type: 'boolean' },
    mania_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
    racing_thoughts: { type: ['boolean', 'null'] },
    decreased_sleep_need: { type: ['boolean', 'null'] },
    anxiety_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
    somatic_anxiety: { type: ['boolean', 'null'] },
    anhedonia_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
    suicidal_ideation: { type: ['integer', 'null'], minimum: 0, maximum: 3 },
    substance_use: { type: ['string', 'null'], enum: ['none', 'alcohol', 'cannabis', 'other', null] },
    substance_quantity: { type: ['integer', 'null'], minimum: 0, maximum: 99 },
    social_score: { type: ['integer', 'null'], minimum: 1, maximum: 5 },
    social_avoidance: { type: ['boolean', 'null'] },
    cognitive_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
    brain_fog: { type: ['boolean', 'null'] },
    appetite_score: { type: ['integer', 'null'], minimum: 1, maximum: 5 },
    stress_score: { type: ['integer', 'null'], minimum: 1, maximum: 10 },
    life_event_note: { type: ['string', 'null'], maxLength: 500 },
    submitted_at: { type: ['string', 'null'], format: 'date-time' },
    synced_at: { type: ['number', 'null'] },
    is_dirty: { type: 'boolean' },
    created_at: nullableDateTimeOrEpoch,
    updated_at: nullableDateTimeOrEpoch,
  },
} as const;

const syncDailyEntryCollectionChanges = {
  type: 'object',
  additionalProperties: false,
  properties: {
    created: { type: 'array', items: syncDailyEntryRecord, default: [] },
    updated: { type: 'array', items: syncDailyEntryRecord, default: [] },
    deleted: { type: 'array', items: { type: 'string' }, default: [] },
  },
} as const;

const syncChanges = {
  type: 'object',
  additionalProperties: false,
  properties: {
    daily_entries: syncDailyEntryCollectionChanges,
    daily_entry_triggers: syncCollectionChanges,
    daily_entry_symptoms: syncCollectionChanges,
    daily_entry_strategies: syncCollectionChanges,
    journal_entries: syncCollectionChanges,
    trigger_catalogue: syncCollectionChanges,
    symptom_catalogue: syncCollectionChanges,
    wellness_strategies: syncCollectionChanges,
  },
} as const;

export const syncPullRouteSchema = {
  tags: ['sync'],
  summary: 'Pull WatermelonDB-compatible offline changes',
  security: authHeader,
  querystring: {
    type: 'object',
    additionalProperties: false,
    properties: {
      last_pulled_at: { type: 'string', pattern: '^\\d+$' },
    },
  },
  response: {
    200: {
      type: 'object',
      required: ['success', 'data'],
      additionalProperties: true,
      properties: {
        success: { type: 'boolean' },
        data: {
          type: 'object',
          required: ['changes', 'timestamp'],
          additionalProperties: false,
          properties: {
            changes: syncChanges,
            timestamp: { type: 'number' },
          },
        },
      },
    },
    403: errorResponse,
  },
} as const;

export const syncPushRouteSchema = {
  tags: ['sync'],
  summary: 'Push WatermelonDB-compatible offline changes',
  security: authHeader,
  body: {
    type: 'object',
    required: ['changes'],
    additionalProperties: false,
    properties: {
      changes: {
        type: 'object',
        additionalProperties: false,
        properties: {
          daily_entries: syncDailyEntryCollectionChanges,
          daily_entry_triggers: syncCollectionChanges,
          daily_entry_symptoms: syncCollectionChanges,
          daily_entry_strategies: syncCollectionChanges,
          journal_entries: syncCollectionChanges,
        },
      },
      last_pulled_at: { type: 'number' },
    },
  },
  response: {
    200: successResponse,
    400: errorResponse,
    403: errorResponse,
  },
} as const;

export const getSafetyResourcesRouteSchema = {
  tags: ['safety'],
  summary: 'Get public crisis and safety resources',
  response: {
    200: successResponse,
  },
} as const;

export const getMySafetyPlanRouteSchema = {
  tags: ['safety'],
  summary: 'Get authenticated patient safety plan',
  security: authHeader,
  response: {
    200: successResponse,
    403: errorResponse,
    404: errorResponse,
  },
} as const;

export const getNotificationPrefsRouteSchema = {
  tags: ['notifications'],
  summary: 'Get authenticated patient notification preferences',
  security: authHeader,
  response: {
    200: successResponse,
    403: errorResponse,
  },
} as const;

export const updateNotificationPrefsRouteSchema = {
  tags: ['notifications'],
  summary: 'Update authenticated patient notification preferences and push token',
  security: authHeader,
  body: {
    type: 'object',
    additionalProperties: false,
    properties: {
      daily_reminder_enabled: { type: 'boolean' },
      daily_reminder_time: { type: 'string', pattern: '^\\d{2}:\\d{2}$' },
      medication_reminder_enabled: { type: 'boolean' },
      streak_notifications: { type: 'boolean' },
      appointment_reminders: { type: 'boolean' },
      push_token: { type: ['string', 'null'], maxLength: 512 },
    },
  },
  response: {
    200: successResponse,
    400: errorResponse,
    403: errorResponse,
  },
} as const;

export const registerPushTokenRouteSchema = {
  tags: ['notifications'],
  summary: 'Register or replace the authenticated patient push token',
  security: authHeader,
  body: {
    type: 'object',
    required: ['push_token'],
    additionalProperties: false,
    properties: {
      push_token: { type: 'string', minLength: 1, maxLength: 512 },
    },
  },
  response: {
    200: successResponse,
    400: errorResponse,
    403: errorResponse,
  },
} as const;
