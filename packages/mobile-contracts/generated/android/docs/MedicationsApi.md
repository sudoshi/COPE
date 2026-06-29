# MedicationsApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1MedicationsIdLogsGet**](MedicationsApi.md#apiV1MedicationsIdLogsGet) | **GET** /api/v1/medications/{id}/logs | List adherence history for a medication |
| [**apiV1MedicationsIdLogsPost**](MedicationsApi.md#apiV1MedicationsIdLogsPost) | **POST** /api/v1/medications/{id}/logs | Log or upsert patient medication adherence |
| [**apiV1MedicationsPost**](MedicationsApi.md#apiV1MedicationsPost) | **POST** /api/v1/medications/ | Add a patient medication |
| [**apiV1MedicationsTodayGet**](MedicationsApi.md#apiV1MedicationsTodayGet) | **GET** /api/v1/medications/today | Get today&#39;s active medications and adherence status |


<a id="apiV1MedicationsIdLogsGet"></a>
# **apiV1MedicationsIdLogsGet**
> ApiV1PatientsMeGet200Response apiV1MedicationsIdLogsGet(id, page, limit)

List adherence history for a medication

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = MedicationsApi()
val id : java.util.UUID = 38400000-8cf0-11bd-b23e-10b96e4ef00d // java.util.UUID | 
val page : kotlin.Int = 56 // kotlin.Int | 
val limit : kotlin.Int = 56 // kotlin.Int | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1MedicationsIdLogsGet(id, page, limit)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling MedicationsApi#apiV1MedicationsIdLogsGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling MedicationsApi#apiV1MedicationsIdLogsGet")
    e.printStackTrace()
}
```

### Parameters
| **id** | **java.util.UUID**|  | |
| **page** | **kotlin.Int**|  | [optional] [default to 1] |
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **limit** | **kotlin.Int**|  | [optional] [default to 20] |

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

<a id="apiV1MedicationsIdLogsPost"></a>
# **apiV1MedicationsIdLogsPost**
> ApiV1PatientsMeGet200Response apiV1MedicationsIdLogsPost(id, apiV1MedicationsIdLogsPostRequest)

Log or upsert patient medication adherence

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = MedicationsApi()
val id : java.util.UUID = 38400000-8cf0-11bd-b23e-10b96e4ef00d // java.util.UUID | 
val apiV1MedicationsIdLogsPostRequest : ApiV1MedicationsIdLogsPostRequest =  // ApiV1MedicationsIdLogsPostRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1MedicationsIdLogsPost(id, apiV1MedicationsIdLogsPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling MedicationsApi#apiV1MedicationsIdLogsPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling MedicationsApi#apiV1MedicationsIdLogsPost")
    e.printStackTrace()
}
```

### Parameters
| **id** | **java.util.UUID**|  | |
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1MedicationsIdLogsPostRequest** | [**ApiV1MedicationsIdLogsPostRequest**](ApiV1MedicationsIdLogsPostRequest.md)|  | |

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

<a id="apiV1MedicationsPost"></a>
# **apiV1MedicationsPost**
> ApiV1PatientsMeGet200Response apiV1MedicationsPost(apiV1MedicationsPostRequest)

Add a patient medication

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = MedicationsApi()
val apiV1MedicationsPostRequest : ApiV1MedicationsPostRequest =  // ApiV1MedicationsPostRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1MedicationsPost(apiV1MedicationsPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling MedicationsApi#apiV1MedicationsPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling MedicationsApi#apiV1MedicationsPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1MedicationsPostRequest** | [**ApiV1MedicationsPostRequest**](ApiV1MedicationsPostRequest.md)|  | |

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

<a id="apiV1MedicationsTodayGet"></a>
# **apiV1MedicationsTodayGet**
> ApiV1PatientsMeGet200Response apiV1MedicationsTodayGet()

Get today&#39;s active medications and adherence status

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = MedicationsApi()
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1MedicationsTodayGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling MedicationsApi#apiV1MedicationsTodayGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling MedicationsApi#apiV1MedicationsTodayGet")
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

