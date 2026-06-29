# AuthApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1AuthLoginPost**](AuthApi.md#apiV1AuthLoginPost) | **POST** /api/v1/auth/login | Log in as a patient or clinician |
| [**apiV1AuthMfaVerifyPost**](AuthApi.md#apiV1AuthMfaVerifyPost) | **POST** /api/v1/auth/mfa/verify | Verify a TOTP MFA code using a partial MFA token |
| [**apiV1AuthRefreshPost**](AuthApi.md#apiV1AuthRefreshPost) | **POST** /api/v1/auth/refresh | Rotate a refresh token and issue a new access token |
| [**apiV1AuthRegisterPost**](AuthApi.md#apiV1AuthRegisterPost) | **POST** /api/v1/auth/register | Register an invited patient account |


<a id="apiV1AuthLoginPost"></a>
# **apiV1AuthLoginPost**
> ApiV1AuthLoginPost200Response apiV1AuthLoginPost(apiV1AuthLoginPostRequest)

Log in as a patient or clinician

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = AuthApi()
val apiV1AuthLoginPostRequest : ApiV1AuthLoginPostRequest =  // ApiV1AuthLoginPostRequest | 
try {
    val result : ApiV1AuthLoginPost200Response = apiInstance.apiV1AuthLoginPost(apiV1AuthLoginPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling AuthApi#apiV1AuthLoginPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling AuthApi#apiV1AuthLoginPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1AuthLoginPostRequest** | [**ApiV1AuthLoginPostRequest**](ApiV1AuthLoginPostRequest.md)|  | |

### Return type

[**ApiV1AuthLoginPost200Response**](ApiV1AuthLoginPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

<a id="apiV1AuthMfaVerifyPost"></a>
# **apiV1AuthMfaVerifyPost**
> ApiV1AuthRegisterPost201Response apiV1AuthMfaVerifyPost(apiV1AuthMfaVerifyPostRequest)

Verify a TOTP MFA code using a partial MFA token

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = AuthApi()
val apiV1AuthMfaVerifyPostRequest : ApiV1AuthMfaVerifyPostRequest =  // ApiV1AuthMfaVerifyPostRequest | 
try {
    val result : ApiV1AuthRegisterPost201Response = apiInstance.apiV1AuthMfaVerifyPost(apiV1AuthMfaVerifyPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling AuthApi#apiV1AuthMfaVerifyPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling AuthApi#apiV1AuthMfaVerifyPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1AuthMfaVerifyPostRequest** | [**ApiV1AuthMfaVerifyPostRequest**](ApiV1AuthMfaVerifyPostRequest.md)|  | |

### Return type

[**ApiV1AuthRegisterPost201Response**](ApiV1AuthRegisterPost201Response.md)

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

<a id="apiV1AuthRefreshPost"></a>
# **apiV1AuthRefreshPost**
> ApiV1AuthRegisterPost201Response apiV1AuthRefreshPost(apiV1AuthRefreshPostRequest)

Rotate a refresh token and issue a new access token

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = AuthApi()
val apiV1AuthRefreshPostRequest : ApiV1AuthRefreshPostRequest =  // ApiV1AuthRefreshPostRequest | 
try {
    val result : ApiV1AuthRegisterPost201Response = apiInstance.apiV1AuthRefreshPost(apiV1AuthRefreshPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling AuthApi#apiV1AuthRefreshPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling AuthApi#apiV1AuthRefreshPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1AuthRefreshPostRequest** | [**ApiV1AuthRefreshPostRequest**](ApiV1AuthRefreshPostRequest.md)|  | |

### Return type

[**ApiV1AuthRegisterPost201Response**](ApiV1AuthRegisterPost201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

<a id="apiV1AuthRegisterPost"></a>
# **apiV1AuthRegisterPost**
> ApiV1AuthRegisterPost201Response apiV1AuthRegisterPost(apiV1AuthRegisterPostRequest)

Register an invited patient account

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = AuthApi()
val apiV1AuthRegisterPostRequest : ApiV1AuthRegisterPostRequest =  // ApiV1AuthRegisterPostRequest | 
try {
    val result : ApiV1AuthRegisterPost201Response = apiInstance.apiV1AuthRegisterPost(apiV1AuthRegisterPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling AuthApi#apiV1AuthRegisterPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling AuthApi#apiV1AuthRegisterPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1AuthRegisterPostRequest** | [**ApiV1AuthRegisterPostRequest**](ApiV1AuthRegisterPostRequest.md)|  | |

### Return type

[**ApiV1AuthRegisterPost201Response**](ApiV1AuthRegisterPost201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

