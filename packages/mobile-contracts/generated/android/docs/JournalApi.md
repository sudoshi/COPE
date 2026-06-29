# JournalApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1JournalGet**](JournalApi.md#apiV1JournalGet) | **GET** /api/v1/journal/ | List authenticated patient journal entries |
| [**apiV1JournalPost**](JournalApi.md#apiV1JournalPost) | **POST** /api/v1/journal/ | Create or upsert today journal entry |


<a id="apiV1JournalGet"></a>
# **apiV1JournalGet**
> ApiV1PatientsMeGet200Response apiV1JournalGet(page, limit)

List authenticated patient journal entries

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = JournalApi()
val page : kotlin.Int = 56 // kotlin.Int | 
val limit : kotlin.Int = 56 // kotlin.Int | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1JournalGet(page, limit)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling JournalApi#apiV1JournalGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling JournalApi#apiV1JournalGet")
    e.printStackTrace()
}
```

### Parameters
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

<a id="apiV1JournalPost"></a>
# **apiV1JournalPost**
> ApiV1PatientsMeGet200Response apiV1JournalPost(apiV1JournalPostRequest)

Create or upsert today journal entry

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = JournalApi()
val apiV1JournalPostRequest : ApiV1JournalPostRequest =  // ApiV1JournalPostRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1JournalPost(apiV1JournalPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling JournalApi#apiV1JournalPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling JournalApi#apiV1JournalPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1JournalPostRequest** | [**ApiV1JournalPostRequest**](ApiV1JournalPostRequest.md)|  | |

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

