
# ApiV1ConsentGet200ResponseDataInner

## Properties
| Name | Type | Description | Notes |
| ------------ | ------------- | ------------- | ------------- |
| **id** | [**java.util.UUID**](java.util.UUID.md) |  |  |
| **consentType** | [**inline**](#ConsentType) |  |  |
| **granted** | **kotlin.Boolean** |  |  |
| **grantedAt** | [**java.time.OffsetDateTime**](java.time.OffsetDateTime.md) |  |  |
| **expiresAt** | [**java.time.OffsetDateTime**](java.time.OffsetDateTime.md) |  |  [optional] |
| **revokedAt** | [**java.time.OffsetDateTime**](java.time.OffsetDateTime.md) |  |  [optional] |


<a id="ConsentType"></a>
## Enum: consent_type
| Name | Value |
| ---- | ----- |
| consentType | share_with_clinician, share_journal_with_clinician, research_participation, data_export, push_notifications, terms_of_service, privacy_policy, journal_sharing, data_research, ai_insights, emergency_contact |



