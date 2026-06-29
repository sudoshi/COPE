# AuthAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1AuthLoginPost**](AuthAPI.md#apiv1authloginpost) | **POST** /api/v1/auth/login | Log in as a patient or clinician
[**apiV1AuthMfaVerifyPost**](AuthAPI.md#apiv1authmfaverifypost) | **POST** /api/v1/auth/mfa/verify | Verify a TOTP MFA code using a partial MFA token
[**apiV1AuthRefreshPost**](AuthAPI.md#apiv1authrefreshpost) | **POST** /api/v1/auth/refresh | Rotate a refresh token and issue a new access token
[**apiV1AuthRegisterPost**](AuthAPI.md#apiv1authregisterpost) | **POST** /api/v1/auth/register | Register an invited patient account


# **apiV1AuthLoginPost**
```swift
    open class func apiV1AuthLoginPost(apiV1AuthLoginPostRequest: ApiV1AuthLoginPostRequest, completion: @escaping (_ data: ApiV1AuthLoginPost200Response?, _ error: Error?) -> Void)
```

Log in as a patient or clinician

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1AuthLoginPostRequest = _api_v1_auth_login_post_request(email: "email_example", password: "password_example") // ApiV1AuthLoginPostRequest | 

// Log in as a patient or clinician
AuthAPI.apiV1AuthLoginPost(apiV1AuthLoginPostRequest: apiV1AuthLoginPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **apiV1AuthLoginPostRequest** | [**ApiV1AuthLoginPostRequest**](ApiV1AuthLoginPostRequest.md) |  | 

### Return type

[**ApiV1AuthLoginPost200Response**](ApiV1AuthLoginPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AuthMfaVerifyPost**
```swift
    open class func apiV1AuthMfaVerifyPost(apiV1AuthMfaVerifyPostRequest: ApiV1AuthMfaVerifyPostRequest, completion: @escaping (_ data: ApiV1AuthRegisterPost201Response?, _ error: Error?) -> Void)
```

Verify a TOTP MFA code using a partial MFA token

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1AuthMfaVerifyPostRequest = _api_v1_auth_mfa_verify_post_request(code: "code_example") // ApiV1AuthMfaVerifyPostRequest | 

// Verify a TOTP MFA code using a partial MFA token
AuthAPI.apiV1AuthMfaVerifyPost(apiV1AuthMfaVerifyPostRequest: apiV1AuthMfaVerifyPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **apiV1AuthMfaVerifyPostRequest** | [**ApiV1AuthMfaVerifyPostRequest**](ApiV1AuthMfaVerifyPostRequest.md) |  | 

### Return type

[**ApiV1AuthRegisterPost201Response**](ApiV1AuthRegisterPost201Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AuthRefreshPost**
```swift
    open class func apiV1AuthRefreshPost(apiV1AuthRefreshPostRequest: ApiV1AuthRefreshPostRequest, completion: @escaping (_ data: ApiV1AuthRegisterPost201Response?, _ error: Error?) -> Void)
```

Rotate a refresh token and issue a new access token

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1AuthRefreshPostRequest = _api_v1_auth_refresh_post_request(refreshToken: "refreshToken_example") // ApiV1AuthRefreshPostRequest | 

// Rotate a refresh token and issue a new access token
AuthAPI.apiV1AuthRefreshPost(apiV1AuthRefreshPostRequest: apiV1AuthRefreshPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **apiV1AuthRefreshPostRequest** | [**ApiV1AuthRefreshPostRequest**](ApiV1AuthRefreshPostRequest.md) |  | 

### Return type

[**ApiV1AuthRegisterPost201Response**](ApiV1AuthRegisterPost201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AuthRegisterPost**
```swift
    open class func apiV1AuthRegisterPost(apiV1AuthRegisterPostRequest: ApiV1AuthRegisterPostRequest, completion: @escaping (_ data: ApiV1AuthRegisterPost201Response?, _ error: Error?) -> Void)
```

Register an invited patient account

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1AuthRegisterPostRequest = _api_v1_auth_register_post_request(inviteToken: "inviteToken_example", email: "email_example", password: "password_example", firstName: "firstName_example", lastName: "lastName_example", dateOfBirth: "dateOfBirth_example", timezone: "timezone_example") // ApiV1AuthRegisterPostRequest | 

// Register an invited patient account
AuthAPI.apiV1AuthRegisterPost(apiV1AuthRegisterPostRequest: apiV1AuthRegisterPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **apiV1AuthRegisterPostRequest** | [**ApiV1AuthRegisterPostRequest**](ApiV1AuthRegisterPostRequest.md) |  | 

### Return type

[**ApiV1AuthRegisterPost201Response**](ApiV1AuthRegisterPost201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

