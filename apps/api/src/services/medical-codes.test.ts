import { describe, expect, it } from 'vitest';
import { SCALE_LOINC_MAP, SCALE_TOTAL_SCORE_LOINC_MAP } from '@cope/shared';
import { ASSESSMENT_CONCEPTS } from './omopConceptMap.js';
import { mapQuestionnaireResponse, type AssessmentRow } from './fhir/mappers.js';

describe('assessment LOINC semantics', () => {
  it('keeps questionnaire panel codes separate from total-score codes', () => {
    expect(SCALE_LOINC_MAP['PHQ-9']).toBe('44249-1');
    expect(SCALE_TOTAL_SCORE_LOINC_MAP['PHQ-9']).toBe('44261-6');

    expect(SCALE_LOINC_MAP['GAD-7']).toBe('69737-5');
    expect(SCALE_TOTAL_SCORE_LOINC_MAP['GAD-7']).toBe('70274-6');
  });

  it('uses total-score codes for OMOP assessment measurements', () => {
    expect(ASSESSMENT_CONCEPTS['PHQ-9']?.loinc_code).toBe('44261-6');
    expect(ASSESSMENT_CONCEPTS['GAD-7']?.loinc_code).toBe('70274-6');
  });

  it('does not assign unverified panel/screener codes as total-score measurement codes', () => {
    expect(ASSESSMENT_CONCEPTS.ISI?.loinc_code).toBe('');
    expect(ASSESSMENT_CONCEPTS['C-SSRS']?.loinc_code).toBe('');
    expect(SCALE_TOTAL_SCORE_LOINC_MAP.ISI).toBeNull();
    expect(SCALE_TOTAL_SCORE_LOINC_MAP['C-SSRS']).toBeNull();
  });

  it('uses questionnaire panel codes for FHIR QuestionnaireResponse.questionnaire', () => {
    const row: AssessmentRow = {
      id: 'assessment-1',
      patient_id: 'patient-1',
      scale_code: 'PHQ-9',
      total_score: 7,
      responses: { '1': 1, '2': 2 },
      severity_label: 'mild',
      assessed_at: '2026-06-29T00:00:00.000Z',
      assessed_by: null,
      clinician_name: null,
    };

    const resource = mapQuestionnaireResponse(row, 'https://api.cope.health/fhir') as {
      questionnaire: string;
      extension: Array<{ url: string; valueCode: string }>;
    };

    expect(resource.questionnaire).toBe('http://loinc.org/q/44249-1');
    expect(resource.extension).toContainEqual({ url: 'urn:cope:loinc-code', valueCode: '44249-1' });
  });
});
