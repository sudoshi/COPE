# SafetyAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1SafetyMyPlanGet**](SafetyAPI.md#apiv1safetymyplanget) | **GET** /api/v1/safety/my-plan | Get authenticated patient safety plan
[**apiV1SafetyMyPlanSignPost**](SafetyAPI.md#apiv1safetymyplansignpost) | **POST** /api/v1/safety/my-plan/sign | Acknowledge authenticated patient safety plan
[**apiV1SafetyResourcesGet**](SafetyAPI.md#apiv1safetyresourcesget) | **GET** /api/v1/safety/resources | Get public crisis and safety resources


# **apiV1SafetyMyPlanGet**
```swift
    open class func apiV1SafetyMyPlanGet(completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Get authenticated patient safety plan

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// Get authenticated patient safety plan
SafetyAPI.apiV1SafetyMyPlanGet() { (response, error) in
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

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1SafetyMyPlanSignPost**
```swift
    open class func apiV1SafetyMyPlanSignPost(completion: @escaping (_ data: ApiV1SafetyMyPlanSignPost200Response?, _ error: Error?) -> Void)
```

Acknowledge authenticated patient safety plan

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// Acknowledge authenticated patient safety plan
SafetyAPI.apiV1SafetyMyPlanSignPost() { (response, error) in
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

[**ApiV1SafetyMyPlanSignPost200Response**](ApiV1SafetyMyPlanSignPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1SafetyResourcesGet**
```swift
    open class func apiV1SafetyResourcesGet(completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Get public crisis and safety resources

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// Get public crisis and safety resources
SafetyAPI.apiV1SafetyResourcesGet() { (response, error) in
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

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

