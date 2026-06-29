# DailyEntriesApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1DailyEntriesIdSubmitPatch**](DailyEntriesApi.md#apiV1DailyEntriesIdSubmitPatch) | **PATCH** /api/v1/daily-entries/{id}/submit | Mark a daily check-in as submitted |
| [**apiV1DailyEntriesPost**](DailyEntriesApi.md#apiV1DailyEntriesPost) | **POST** /api/v1/daily-entries/ | Create or upsert a patient daily check-in |
| [**apiV1DailyEntriesTodayGet**](DailyEntriesApi.md#apiV1DailyEntriesTodayGet) | **GET** /api/v1/daily-entries/today | Get today&#39;s daily check-in |


<a id="apiV1DailyEntriesIdSubmitPatch"></a>
# **apiV1DailyEntriesIdSubmitPatch**
> ApiV1PatientsMeGet200Response apiV1DailyEntriesIdSubmitPatch(id)

Mark a daily check-in as submitted

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = DailyEntriesApi()
val id : java.util.UUID = 38400000-8cf0-11bd-b23e-10b96e4ef00d // java.util.UUID | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1DailyEntriesIdSubmitPatch(id)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling DailyEntriesApi#apiV1DailyEntriesIdSubmitPatch")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling DailyEntriesApi#apiV1DailyEntriesIdSubmitPatch")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **id** | **java.util.UUID**|  | |

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

<a id="apiV1DailyEntriesPost"></a>
# **apiV1DailyEntriesPost**
> ApiV1PatientsMeGet200Response apiV1DailyEntriesPost(apiV1DailyEntriesPostRequest)

Create or upsert a patient daily check-in

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = DailyEntriesApi()
val apiV1DailyEntriesPostRequest : ApiV1DailyEntriesPostRequest =  // ApiV1DailyEntriesPostRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1DailyEntriesPost(apiV1DailyEntriesPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling DailyEntriesApi#apiV1DailyEntriesPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling DailyEntriesApi#apiV1DailyEntriesPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1DailyEntriesPostRequest** | [**ApiV1DailyEntriesPostRequest**](ApiV1DailyEntriesPostRequest.md)|  | |

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

<a id="apiV1DailyEntriesTodayGet"></a>
# **apiV1DailyEntriesTodayGet**
> ApiV1PatientsMeGet200Response apiV1DailyEntriesTodayGet()

Get today&#39;s daily check-in

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = DailyEntriesApi()
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1DailyEntriesTodayGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling DailyEntriesApi#apiV1DailyEntriesTodayGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling DailyEntriesApi#apiV1DailyEntriesTodayGet")
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

