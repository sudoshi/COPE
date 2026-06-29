# AssessmentsApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1AssessmentsPendingGet**](AssessmentsApi.md#apiV1AssessmentsPendingGet) | **GET** /api/v1/assessments/pending | List assessment scales due for the authenticated patient |
| [**apiV1AssessmentsPost**](AssessmentsApi.md#apiV1AssessmentsPost) | **POST** /api/v1/assessments/ | Submit a completed validated assessment scale |
| [**apiV1AssessmentsScaleResponsesPost**](AssessmentsApi.md#apiV1AssessmentsScaleResponsesPost) | **POST** /api/v1/assessments/{scale}/responses | Submit a completed validated assessment scale using the scale path parameter |


<a id="apiV1AssessmentsPendingGet"></a>
# **apiV1AssessmentsPendingGet**
> ApiV1PatientsMeGet200Response apiV1AssessmentsPendingGet()

List assessment scales due for the authenticated patient

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = AssessmentsApi()
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1AssessmentsPendingGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling AssessmentsApi#apiV1AssessmentsPendingGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling AssessmentsApi#apiV1AssessmentsPendingGet")
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

<a id="apiV1AssessmentsPost"></a>
# **apiV1AssessmentsPost**
> ApiV1PatientsMeGet200Response apiV1AssessmentsPost(apiV1AssessmentsPostRequest)

Submit a completed validated assessment scale

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = AssessmentsApi()
val apiV1AssessmentsPostRequest : ApiV1AssessmentsPostRequest =  // ApiV1AssessmentsPostRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1AssessmentsPost(apiV1AssessmentsPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling AssessmentsApi#apiV1AssessmentsPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling AssessmentsApi#apiV1AssessmentsPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1AssessmentsPostRequest** | [**ApiV1AssessmentsPostRequest**](ApiV1AssessmentsPostRequest.md)|  | |

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

<a id="apiV1AssessmentsScaleResponsesPost"></a>
# **apiV1AssessmentsScaleResponsesPost**
> ApiV1PatientsMeGet200Response apiV1AssessmentsScaleResponsesPost(scale, apiV1AssessmentsScaleResponsesPostRequest)

Submit a completed validated assessment scale using the scale path parameter

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = AssessmentsApi()
val scale : kotlin.String = scale_example // kotlin.String | 
val apiV1AssessmentsScaleResponsesPostRequest : ApiV1AssessmentsScaleResponsesPostRequest =  // ApiV1AssessmentsScaleResponsesPostRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1AssessmentsScaleResponsesPost(scale, apiV1AssessmentsScaleResponsesPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling AssessmentsApi#apiV1AssessmentsScaleResponsesPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling AssessmentsApi#apiV1AssessmentsScaleResponsesPost")
    e.printStackTrace()
}
```

### Parameters
| **scale** | **kotlin.String**|  | [enum: PHQ-9, GAD-7, ASRM, ISI, C-SSRS, WHODAS, QIDS-SR] |
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1AssessmentsScaleResponsesPostRequest** | [**ApiV1AssessmentsScaleResponsesPostRequest**](ApiV1AssessmentsScaleResponsesPostRequest.md)|  | |

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

