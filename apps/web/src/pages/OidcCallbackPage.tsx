// =============================================================================
// COPE Web — Authentik OIDC callback landing page
// Authentik → API callback redirects the browser here with a one-time ?code=.
// We swap it for a COPE session via POST /auth/oidc/exchange, then enter the app.
// =============================================================================

import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api, ApiError } from '../services/api.js';
import { authActions } from '../stores/auth.js';

interface ExchangeResponse {
  access_token: string;
  refresh_token?: string;
  clinician_id: string;
  org_id: string;
  role?: string;
  must_change_password?: boolean;
}

export function OidcCallbackPage() {
  const navigate = useNavigate();
  const [error, setError] = useState<string | null>(null);
  // React 19 strict mode double-invokes effects; the one-time code can only be
  // consumed once, so guard with a ref.
  const ranRef = useRef(false);

  useEffect(() => {
    if (ranRef.current) return;
    ranRef.current = true;

    const params = new URLSearchParams(window.location.search);
    const oidcError = params.get('oidc_error');
    if (oidcError) {
      setError(oidcError);
      return;
    }

    const code = params.get('code');
    if (!code) {
      setError('missing_code');
      return;
    }

    void (async () => {
      try {
        const data = await api.post<ExchangeResponse>('/auth/oidc/exchange', { code });

        if (!data.access_token || !data.clinician_id || !data.org_id) {
          setError('invalid_response');
          return;
        }

        authActions.login(
          data.access_token,
          data.clinician_id,
          data.org_id,
          data.refresh_token,
          900,
          true, // SSO sessions persist (Remember Me)
          data.role ?? 'clinician',
          data.must_change_password,
        );

        // Full-page navigation so AppShell boots with a clean store.
        window.location.href = '/dashboard';
      } catch (err) {
        if (err instanceof ApiError) {
          setError(err.message);
        } else {
          setError(err instanceof Error ? err.message : 'sign_in_failed');
        }
      }
    })();
  }, [navigate]);

  return (
    <main
      className="login-page"
      data-testid="oidc-callback-page"
      style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}
    >
      <div className="login-card" style={{ textAlign: 'center', maxWidth: 420 }}>
        {error ? (
          <>
            <h2 className="login-title">Sign-in failed</h2>
            <p className="login-subtitle" style={{ marginBottom: 20 }}>
              {error === 'access_denied'
                ? 'Your account is not authorized for COPE. Contact an administrator.'
                : 'We could not complete single sign-on. Please try again.'}
            </p>
            <button
              type="button"
              className="login-submit"
              onClick={() => navigate('/login')}
            >
              Back to sign in
            </button>
          </>
        ) : (
          <>
            <span className="login-spinner" />
            <h2 className="login-title" style={{ marginTop: 16 }}>Signing you in…</h2>
            <p className="login-subtitle">Completing Authentik sign-in.</p>
          </>
        )}
      </div>
    </main>
  );
}
