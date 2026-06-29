# PatientsApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1PatientsMeGet**](PatientsApi.md#apiV1PatientsMeGet) | **GET** /api/v1/patients/me | Get the authenticated patient profile |
| [**apiV1PatientsMeIntakePatch**](PatientsApi.md#apiV1PatientsMeIntakePatch) | **PATCH** /api/v1/patients/me/intake | Update authenticated patient onboarding intake fields |
| [**apiV1PatientsMePatch**](PatientsApi.md#apiV1PatientsMePatch) | **PATCH** /api/v1/patients/me | Update authenticated patient profile preferences |


<a id="apiV1PatientsMeGet"></a>
# **apiV1PatientsMeGet**
> ApiV1PatientsMeGet200Response apiV1PatientsMeGet()

Get the authenticated patient profile

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1PatientsMeGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization


Configure bearerAuth statically:
```kotlin
ApiClient.accessToken = ""
```
Configure bearerAuth dynamically:
```kotlin
apiInstance.accessTokenProvider = { "" }
```

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

<a id="apiV1PatientsMeIntakePatch"></a>
# **apiV1PatientsMeIntakePatch**
> ApiV1PatientsMeGet200Response apiV1PatientsMeIntakePatch(apiV1PatientsMeIntakePatchRequest)

Update authenticated patient onboarding intake fields

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
val apiV1PatientsMeIntakePatchRequest : ApiV1PatientsMeIntakePatchRequest =  // ApiV1PatientsMeIntakePatchRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1PatientsMeIntakePatch(apiV1PatientsMeIntakePatchRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeIntakePatch")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeIntakePatch")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1PatientsMeIntakePatchRequest** | [**ApiV1PatientsMeIntakePatchRequest**](ApiV1PatientsMeIntakePatchRequest.md)|  | |

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization


Configure bearerAuth statically:
```kotlin
ApiClient.accessToken = ""
```
Configure bearerAuth dynamically:
```kotlin
apiInstance.accessTokenProvider = { "" }
```

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

<a id="apiV1PatientsMePatch"></a>
# **apiV1PatientsMePatch**
> ApiV1PatientsMeGet200Response apiV1PatientsMePatch(apiV1PatientsMePatchRequest)

Update authenticated patient profile preferences

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
val apiV1PatientsMePatchRequest : ApiV1PatientsMePatchRequest =  // ApiV1PatientsMePatchRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1PatientsMePatch(apiV1PatientsMePatchRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMePatch")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMePatch")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1PatientsMePatchRequest** | [**ApiV1PatientsMePatchRequest**](ApiV1PatientsMePatchRequest.md)|  | |

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization


Configure bearerAuth statically:
```kotlin
ApiClient.accessToken = ""
```
Configure bearerAuth dynamically:
```kotlin
apiInstance.accessTokenProvider = { "" }
```

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

