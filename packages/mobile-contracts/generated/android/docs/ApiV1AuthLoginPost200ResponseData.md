
# ApiV1AuthLoginPost200ResponseData

## Properties
| Name | Type | Description | Notes |
| ------------ | ------------- | ------------- | ------------- |
| **accessToken** | **kotlin.String** |  |  |
| **orgId** | [**java.util.UUID**](java.util.UUID.md) |  |  |
| **role** | [**inline**](#Role) |  |  |
| **user** | [**ApiV1AuthLoginPost200ResponseDataUser**](ApiV1AuthLoginPost200ResponseDataUser.md) |  |  |
| **refreshToken** | **kotlin.String** |  |  [optional] |
| **patientId** | [**java.util.UUID**](java.util.UUID.md) |  |  [optional] |
| **clinicianId** | [**java.util.UUID**](java.util.UUID.md) |  |  [optional] |
| **mfaRequired** | **kotlin.Boolean** |  |  [optional] |
| **partialToken** | **kotlin.String** |  |  [optional] |
| **mustChangePassword** | **kotlin.Boolean** |  |  [optional] |


<a id="Role"></a>
## Enum: role
| Name | Value |
| ---- | ----- |
| role | patient, clinician, admin, researcher |



