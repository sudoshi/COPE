// =============================================================================
// COPE Mobile — Accessibility label tests
// These strings are read aloud by screen readers; clinical values must be
// announced unambiguously (WCAG 2.1 AA).
// =============================================================================

import {
  a11yListCount,
  a11yMedicationLabel,
  a11yMoodLabel,
  a11yScaleLabel,
  a11ySeverityLabel,
  a11yToggleLabel,
} from './a11y';

describe('a11yMoodLabel', () => {
  it('announces score and qualitative name', () => {
    expect(a11yMoodLabel(7)).toBe('Mood score 7 out of 10 — Good');
    expect(a11yMoodLabel(1)).toBe('Mood score 1 out of 10 — Very poor');
    expect(a11yMoodLabel(10)).toBe('Mood score 10 out of 10 — Excellent');
  });

  it('falls back to Unknown for out-of-range scores', () => {
    expect(a11yMoodLabel(0)).toContain('Unknown');
    expect(a11yMoodLabel(11)).toContain('Unknown');
  });
});

describe('a11yMedicationLabel', () => {
  it('includes dose and adherence status', () => {
    expect(a11yMedicationLabel('Sertraline', 50, 'mg', true)).toBe('Sertraline 50mg, taken today');
    expect(a11yMedicationLabel('Sertraline', 50, 'mg', false)).toBe(
      'Sertraline 50mg, not taken today',
    );
  });

  it('handles missing dose and unknown adherence', () => {
    expect(a11yMedicationLabel('Lithium', null, 'mg', null)).toBe('Lithium, status unknown');
  });
});

describe('a11yScaleLabel', () => {
  it('expands clinical instrument abbreviations', () => {
    expect(a11yScaleLabel('PHQ-9', 12)).toBe('Patient Health Questionnaire 9, score 12');
    expect(a11yScaleLabel('C-SSRS')).toBe('Columbia Suicide Severity Rating Scale');
  });

  it('passes unknown scales through unchanged', () => {
    expect(a11yScaleLabel('MADRS', 20)).toBe('MADRS, score 20');
  });
});

describe('a11ySeverityLabel', () => {
  it('announces value against the maximum', () => {
    expect(a11ySeverityLabel(3)).toBe('Severity 3 out of 10');
    expect(a11ySeverityLabel(2, 5)).toBe('Severity 2 out of 5');
  });
});

describe('a11yToggleLabel', () => {
  it('announces state and the toggle gesture', () => {
    expect(a11yToggleLabel('Reminders', true)).toBe('Reminders, enabled, double-tap to toggle');
  });
});

describe('a11yListCount', () => {
  it('pluralises correctly', () => {
    expect(a11yListCount(1, 'alert')).toBe('1 alert');
    expect(a11yListCount(3, 'alert')).toBe('3 alerts');
    expect(a11yListCount(0, 'entry')).toBe('0 entrys');
  });
});
