# SyncApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1SyncPullGet**](SyncApi.md#apiV1SyncPullGet) | **GET** /api/v1/sync/pull | Pull WatermelonDB-compatible offline changes |
| [**apiV1SyncPushPost**](SyncApi.md#apiV1SyncPushPost) | **POST** /api/v1/sync/push | Push WatermelonDB-compatible offline changes |


<a id="apiV1SyncPullGet"></a>
# **apiV1SyncPullGet**
> ApiV1SyncPullGet200Response apiV1SyncPullGet(lastPulledAt)

Pull WatermelonDB-compatible offline changes

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = SyncApi()
val lastPulledAt : kotlin.String = lastPulledAt_example // kotlin.String | 
try {
    val result : ApiV1SyncPullGet200Response = apiInstance.apiV1SyncPullGet(lastPulledAt)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling SyncApi#apiV1SyncPullGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling SyncApi#apiV1SyncPullGet")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **lastPulledAt** | **kotlin.String**|  | [optional] |

### Return type

[**ApiV1SyncPullGet200Response**](ApiV1SyncPullGet200Response.md)

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

<a id="apiV1SyncPushPost"></a>
# **apiV1SyncPushPost**
> ApiV1PatientsMeGet200Response apiV1SyncPushPost(apiV1SyncPushPostRequest)

Push WatermelonDB-compatible offline changes

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = SyncApi()
val apiV1SyncPushPostRequest : ApiV1SyncPushPostRequest =  // ApiV1SyncPushPostRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1SyncPushPost(apiV1SyncPushPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling SyncApi#apiV1SyncPushPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling SyncApi#apiV1SyncPushPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1SyncPushPostRequest** | [**ApiV1SyncPushPostRequest**](ApiV1SyncPushPostRequest.md)|  | |

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

