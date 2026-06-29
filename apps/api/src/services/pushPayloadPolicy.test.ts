import { describe, expect, it } from 'vitest';
import {
  assertPhiSafePushPayload,
  buildAssessmentRequestPushPayload,
  buildClinicalAlertPushPayload,
} from './pushPayloadPolicy.js';

describe('push payload policy', () => {
  it('builds generic assessment request push payloads', () => {
    const payload = buildAssessmentRequestPushPayload();

    expect(payload.title).toBe('COPE update');
    expect(payload.body).toBe('Open COPE for an update from your care team.');
    expect(payload.data).toEqual({ type: 'assessment_request', screen: '/(tabs)' });
    expect(() => assertPhiSafePushPayload(payload)).not.toThrow();
  });

  it('builds generic clinical alert push payloads', () => {
    const payload = buildClinicalAlertPushPayload();

    expect(payload.title).toBe('COPE alert');
    expect(payload.body).toBe('Open COPE to review a clinical alert.');
    expect(payload.data).toEqual({ type: 'clinical_alert' });
    expect(() => assertPhiSafePushPayload(payload)).not.toThrow();
  });

  it('rejects known PHI-bearing routing keys in push payload data', () => {
    expect(() =>
      assertPhiSafePushPayload({
        title: 'COPE update',
        body: 'Open COPE.',
        data: { patientId: 'patient-1' },
      }),
    ).toThrow('patientId');

    expect(() =>
      assertPhiSafePushPayload({
        title: 'COPE update',
        body: 'Open COPE.',
        data: { scale: 'PHQ-9' },
      }),
    ).toThrow('scale');
  });
});
