# ConsentApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1ConsentGet**](ConsentApi.md#apiV1ConsentGet) | **GET** /api/v1/consent/ | List latest patient consent records by type |
| [**apiV1ConsentPost**](ConsentApi.md#apiV1ConsentPost) | **POST** /api/v1/consent/ | Grant or update a patient consent record |
| [**apiV1ConsentTypeDelete**](ConsentApi.md#apiV1ConsentTypeDelete) | **DELETE** /api/v1/consent/{type} | Revoke an app-revocable patient consent type |


<a id="apiV1ConsentGet"></a>
# **apiV1ConsentGet**
> ApiV1ConsentGet200Response apiV1ConsentGet()

List latest patient consent records by type

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = ConsentApi()
try {
    val result : ApiV1ConsentGet200Response = apiInstance.apiV1ConsentGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling ConsentApi#apiV1ConsentGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling ConsentApi#apiV1ConsentGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiV1ConsentGet200Response**](ApiV1ConsentGet200Response.md)

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

<a id="apiV1ConsentPost"></a>
# **apiV1ConsentPost**
> ApiV1PatientsMeGet200Response apiV1ConsentPost(apiV1ConsentPostRequest)

Grant or update a patient consent record

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = ConsentApi()
val apiV1ConsentPostRequest : ApiV1ConsentPostRequest =  // ApiV1ConsentPostRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1ConsentPost(apiV1ConsentPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling ConsentApi#apiV1ConsentPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling ConsentApi#apiV1ConsentPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1ConsentPostRequest** | [**ApiV1ConsentPostRequest**](ApiV1ConsentPostRequest.md)|  | |

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

<a id="apiV1ConsentTypeDelete"></a>
# **apiV1ConsentTypeDelete**
> ApiV1PatientsMeGet200Response apiV1ConsentTypeDelete(type)

Revoke an app-revocable patient consent type

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = ConsentApi()
val type : kotlin.String = type_example // kotlin.String | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1ConsentTypeDelete(type)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling ConsentApi#apiV1ConsentTypeDelete")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling ConsentApi#apiV1ConsentTypeDelete")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **type** | **kotlin.String**|  | [enum: journal_sharing, data_research, ai_insights, emergency_contact] |

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

