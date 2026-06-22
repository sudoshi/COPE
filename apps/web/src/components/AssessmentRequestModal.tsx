// =============================================================================
// COPE Web — AssessmentRequestModal
// Clinician selects a scale and sends a push notification to the patient.
// =============================================================================

import { useState } from 'react';
import { api, ApiError } from '../services/api.js';
import { useAuthStore } from '../stores/auth.js';

const SCALES = [
  { value: 'PHQ-9',   label: 'PHQ-9',   description: 'Patient Health Questionnaire (Depression)' },
  { value: 'GAD-7',   label: 'GAD-7',   description: 'Generalized Anxiety Disorder Scale' },
  { value: 'ASRM',    label: 'ASRM',    description: 'Altman Self-Rating Mania Scale' },
  { value: 'C-SSRS',  label: 'C-SSRS',  description: 'Columbia Suicide Severity Rating Scale' },
  { value: 'ISI',     label: 'ISI',     description: 'Insomnia Severity Index' },
  { value: 'WHODAS',  label: 'WHODAS',  description: 'WHO Disability Assessment Schedule' },
];

interface AssessmentRequestModalProps {
  patientId: string;
  patientName: string;
  onClose: () => void;
  onSuccess: () => void;
}

export function AssessmentRequestModal({
  patientId, patientName, onClose, onSuccess,
}: AssessmentRequestModalProps) {
  const token = useAuthStore((s) => s.accessToken);
  const [selectedScale, setSelectedScale] = useState('PHQ-9');
  const [customMessage, setCustomMessage] = useState('');
  const [sending, setSending] = useState(false);
  const [error, setError] = useState('');

  async function handleSend() {
    if (!token) return;
    setSending(true);
    setError('');
    try {
      await api.post('/notifications/send-assessment-request', {
        patient_id: patientId,
        scale: selectedScale,
        message: customMessage.trim() || undefined,
      }, token);
      onSuccess();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Failed to send request');
    } finally {
      setSending(false);
    }
  }

  return (
    <>
      {/* Backdrop */}
      <div
        onClick={onClose}
        style={{
          position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)',
          backdropFilter: 'blur(4px)', zIndex: 1100,
        }}
      />

      {/* Modal */}
      <div style={{
        position: 'fixed', top: '50%', left: '50%', transform: 'translate(-50%,-50%)',
        width: 'min(480px, 90vw)', zIndex: 1101,
        background: 'var(--bg)', border: '1px solid var(--border)',
        borderRadius: 14, boxShadow: '0 20px 60px rgba(0,0,0,0.5)',
        overflow: 'hidden',
      }}>
        {/* Header */}
        <div style={{
          padding: '16px 20px', borderBottom: '1px solid var(--border)',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <div>
            <div style={{ fontSize: 'var(--text-base)', fontWeight: 700, color: 'var(--text-primary)' }}>Request Assessment</div>
            <div style={{ fontSize: 'var(--text-sm)', color: 'var(--text-muted)', marginTop: 2 }}>{patientName}</div>
          </div>
          <button
            onClick={onClose}
            style={{ background: 'transparent', border: 'none', color: 'var(--text-muted)', fontSize: 'var(--text-2xl)', cursor: 'pointer', padding: 4 }}
          >
            ×
          </button>
        </div>

        {/* Body */}
        <div style={{ padding: '16px 20px', display: 'flex', flexDirection: 'column', gap: 16 }}>
          {/* Scale selector */}
          <div>
            <div style={{ fontSize: 'var(--text-sm)', color: 'var(--text-muted)', marginBottom: 8, fontWeight: 600 }}>
              SELECT SCALE
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              {SCALES.map((s) => (
                <label
                  key={s.value}
                  style={{
                    display: 'flex', alignItems: 'center', gap: 10,
                    padding: '10px 12px', borderRadius: 8, cursor: 'pointer',
                    background: selectedScale === s.value ? 'rgba(45,212,191,0.12)' : 'var(--glass-01)',
                    border: `1px solid ${selectedScale === s.value ? 'var(--safe)' : 'var(--border)'}`,
                    transition: 'all 0.15s',
                  }}
                >
                  <input
                    type="radio"
                    name="scale"
                    value={s.value}
                    checked={selectedScale === s.value}
                    onChange={() => setSelectedScale(s.value)}
                    style={{ accentColor: 'var(--safe)' }}
                  />
                  <div>
                    <div style={{ fontSize: 'var(--text-base)', fontWeight: 600, color: 'var(--text-primary)' }}>{s.label}</div>
                    <div style={{ fontSize: 'var(--text-sm)', color: 'var(--text-muted)' }}>{s.description}</div>
                  </div>
                </label>
              ))}
            </div>
          </div>

          {/* Optional message */}
          <div>
            <div style={{ fontSize: 'var(--text-sm)', color: 'var(--text-muted)', marginBottom: 6 }}>
              Custom message <span style={{ color: 'var(--text-ghost)' }}>(optional, max 200 chars)</span>
            </div>
            <textarea
              value={customMessage}
              onChange={(e) => setCustomMessage(e.target.value.slice(0, 200))}
              placeholder={`Please complete your ${selectedScale} assessment…`}
              rows={2}
              style={{
                width: '100%', background: 'var(--glass-01)', border: '1px solid var(--border)',
                color: 'var(--text-primary)', borderRadius: 8, padding: '8px 10px',
                fontSize: 'var(--text-sm)', outline: 'none', resize: 'none', fontFamily: 'inherit',
                boxSizing: 'border-box',
              }}
            />
            <div style={{ textAlign: 'right', fontSize: 'var(--text-sm)', color: 'var(--text-ghost)' }}>
              {customMessage.length}/200
            </div>
          </div>

          {/* Error */}
          {error && (
            <div style={{ fontSize: 'var(--text-sm)', color: 'var(--critical)', background: 'rgba(214,40,40,0.1)', padding: '8px 12px', borderRadius: 6 }}>
              {error}
            </div>
          )}
        </div>

        {/* Footer */}
        <div style={{ padding: '12px 20px', borderTop: '1px solid var(--border)', display: 'flex', gap: 10 }}>
          <button
            onClick={onClose}
            style={{
              flex: 1, background: 'transparent', border: '1px solid var(--border)',
              color: 'var(--text-secondary)', borderRadius: 8, padding: '9px', fontSize: 'var(--text-base)', cursor: 'pointer',
            }}
          >
            Cancel
          </button>
          <button
            onClick={() => void handleSend()}
            disabled={sending}
            style={{
              flex: 2, background: 'var(--safe)', border: 'none',
              color: '#0a0e1a', borderRadius: 8, padding: '9px', fontSize: 'var(--text-base)', fontWeight: 700,
              cursor: sending ? 'not-allowed' : 'pointer', opacity: sending ? 0.8 : 1,
            }}
          >
            {sending ? 'Sending…' : `Send ${selectedScale} Request`}
          </button>
        </div>
      </div>
    </>
  );
}
