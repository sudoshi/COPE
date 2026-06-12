// =============================================================================
// MindLog Web — Auth store tests
// Covers the storage-layer contract: Remember Me → localStorage, otherwise
// sessionStorage, expired sessions discarded on init, forced-password-change
// flag round-trips. Runs in node with an in-memory Storage stand-in.
// =============================================================================

import { describe, it, expect, beforeEach } from 'vitest';

class MemoryStorage implements Storage {
  private store = new Map<string, string>();

  get length(): number {
    return this.store.size;
  }

  clear(): void {
    this.store.clear();
  }

  getItem(key: string): string | null {
    return this.store.get(key) ?? null;
  }

  key(index: number): string | null {
    return [...this.store.keys()][index] ?? null;
  }

  removeItem(key: string): void {
    this.store.delete(key);
  }

  setItem(key: string, value: string): void {
    this.store.set(key, value);
  }
}

Object.defineProperty(globalThis, 'localStorage', { value: new MemoryStorage() });
Object.defineProperty(globalThis, 'sessionStorage', { value: new MemoryStorage() });

const { authActions, getAuthState } = await import('./auth.js');

const TOKEN = 'header.payload.signature';
const CLINICIAN_ID = '7c9e6679-7425-40de-944b-e07fc1f90ae7';
const ORG_ID = 'f46cc7e7-163a-4291-acc3-148044a5b232';

describe('auth store', () => {
  beforeEach(() => {
    authActions.logout();
  });

  it('persists to sessionStorage only when Remember Me is off', () => {
    authActions.login(TOKEN, CLINICIAN_ID, ORG_ID, 'refresh-token', 900, false);

    expect(sessionStorage.getItem('ml_access_token')).toBe(TOKEN);
    expect(localStorage.getItem('ml_access_token')).toBeNull();
    expect(getAuthState().isAuthenticated).toBe(true);
  });

  it('persists to localStorage only when Remember Me is on', () => {
    authActions.login(TOKEN, CLINICIAN_ID, ORG_ID, 'refresh-token', 900, true);

    expect(localStorage.getItem('ml_access_token')).toBe(TOKEN);
    expect(sessionStorage.getItem('ml_access_token')).toBeNull();
  });

  it('logout clears both storages and resets state', () => {
    authActions.login(TOKEN, CLINICIAN_ID, ORG_ID, 'refresh-token', 900, true);
    authActions.logout();

    expect(localStorage.getItem('ml_access_token')).toBeNull();
    expect(sessionStorage.getItem('ml_access_token')).toBeNull();
    const state = getAuthState();
    expect(state.isAuthenticated).toBe(false);
    expect(state.accessToken).toBeNull();
  });

  it('discards expired sessions on initFromStorage instead of restoring them', () => {
    // Simulate app restart: no in-memory state, only an expired persisted session
    sessionStorage.setItem('ml_access_token', TOKEN);
    sessionStorage.setItem('ml_token_expires_at', String(Math.floor(Date.now() / 1000) - 10));
    sessionStorage.setItem('ml_clinician_id', CLINICIAN_ID);
    sessionStorage.setItem('ml_org_id', ORG_ID);

    authActions.initFromStorage();

    expect(getAuthState().isAuthenticated).toBe(false);
    expect(sessionStorage.getItem('ml_access_token')).toBeNull();
  });

  it('restores a valid persisted session on initFromStorage', () => {
    sessionStorage.setItem('ml_access_token', TOKEN);
    sessionStorage.setItem('ml_token_expires_at', String(Math.floor(Date.now() / 1000) + 600));
    sessionStorage.setItem('ml_clinician_id', CLINICIAN_ID);
    sessionStorage.setItem('ml_org_id', ORG_ID);
    sessionStorage.setItem('ml_role', 'admin');

    authActions.initFromStorage();

    const state = getAuthState();
    expect(state.isAuthenticated).toBe(true);
    expect(state.clinicianId).toBe(CLINICIAN_ID);
    expect(state.role).toBe('admin');
  });

  it('round-trips the forced password change flag', () => {
    authActions.login(TOKEN, CLINICIAN_ID, ORG_ID, undefined, 900, false, 'researcher', true);
    expect(getAuthState().mustChangePassword).toBe(true);

    authActions.clearMustChangePassword();
    expect(getAuthState().mustChangePassword).toBe(false);
    expect(sessionStorage.getItem('ml_must_change_password')).toBe('false');
  });
});
