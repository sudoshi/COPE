
# ApiV1AuthRegisterPost201ResponseData

## Properties
| Name | Type | Description | Notes |
| ------------ | ------------- | ------------- | ------------- |
| **accessToken** | **kotlin.String** |  |  |
| **orgId** | [**java.util.UUID**](java.util.UUID.md) |  |  |
| **role** | [**inline**](#Role) |  |  |
| **user** | [**ApiV1AuthRegisterPost201ResponseDataUser**](ApiV1AuthRegisterPost201ResponseDataUser.md) |  |  |
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



