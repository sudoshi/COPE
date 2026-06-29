# ConsentAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1ConsentGet**](ConsentAPI.md#apiv1consentget) | **GET** /api/v1/consent/ | List latest patient consent records by type
[**apiV1ConsentPost**](ConsentAPI.md#apiv1consentpost) | **POST** /api/v1/consent/ | Grant or update a patient consent record
[**apiV1ConsentTypeDelete**](ConsentAPI.md#apiv1consenttypedelete) | **DELETE** /api/v1/consent/{type} | Revoke an app-revocable patient consent type


# **apiV1ConsentGet**
```swift
    open class func apiV1ConsentGet(completion: @escaping (_ data: ApiV1ConsentGet200Response?, _ error: Error?) -> Void)
```

List latest patient consent records by type

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// List latest patient consent records by type
ConsentAPI.apiV1ConsentGet() { (response, error) in
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
This endpoint does not need any parameter.

### Return type

[**ApiV1ConsentGet200Response**](ApiV1ConsentGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ConsentPost**
```swift
    open class func apiV1ConsentPost(apiV1ConsentPostRequest: ApiV1ConsentPostRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Grant or update a patient consent record

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1ConsentPostRequest = _api_v1_consent__post_request(consentType: "consentType_example", granted: false) // ApiV1ConsentPostRequest | 

// Grant or update a patient consent record
ConsentAPI.apiV1ConsentPost(apiV1ConsentPostRequest: apiV1ConsentPostRequest) { (response, error) in
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
 **apiV1ConsentPostRequest** | [**ApiV1ConsentPostRequest**](ApiV1ConsentPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1ConsentTypeDelete**
```swift
    open class func apiV1ConsentTypeDelete(type: ModelType_apiV1ConsentTypeDelete, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Revoke an app-revocable patient consent type

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let type = "type_example" // String | 

// Revoke an app-revocable patient consent type
ConsentAPI.apiV1ConsentTypeDelete(type: type) { (response, error) in
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
 **type** | **String** |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

