// =============================================================================
// COPE API - PHI-safe push notification payloads
// =============================================================================

export interface PhiSafePushPayload {
  title: string;
  body: string;
  data: Record<string, string>;
}

const FORBIDDEN_DATA_KEYS = new Set([
  'alertId',
  'clinicianId',
  'patientId',
  'patient_id',
  'ruleKey',
  'scale',
]);

export function buildAssessmentRequestPushPayload(): PhiSafePushPayload {
  return {
    title: 'COPE update',
    body: 'Open COPE for an update from your care team.',
    data: {
      type: 'assessment_request',
      screen: '/(tabs)',
    },
  };
}

export function buildClinicalAlertPushPayload(): PhiSafePushPayload {
  return {
    title: 'COPE alert',
    body: 'Open COPE to review a clinical alert.',
    data: {
      type: 'clinical_alert',
    },
  };
}

export function assertPhiSafePushPayload(payload: PhiSafePushPayload): void {
  for (const key of Object.keys(payload.data)) {
    if (FORBIDDEN_DATA_KEYS.has(key)) {
      throw new Error(`Push payload data key "${key}" is not allowed`);
    }
  }
}
