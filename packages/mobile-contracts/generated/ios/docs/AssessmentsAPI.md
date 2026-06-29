# AssessmentsAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1AssessmentsPendingGet**](AssessmentsAPI.md#apiv1assessmentspendingget) | **GET** /api/v1/assessments/pending | List assessment scales due for the authenticated patient
[**apiV1AssessmentsPost**](AssessmentsAPI.md#apiv1assessmentspost) | **POST** /api/v1/assessments/ | Submit a completed validated assessment scale
[**apiV1AssessmentsScaleResponsesPost**](AssessmentsAPI.md#apiv1assessmentsscaleresponsespost) | **POST** /api/v1/assessments/{scale}/responses | Submit a completed validated assessment scale using the scale path parameter


# **apiV1AssessmentsPendingGet**
```swift
    open class func apiV1AssessmentsPendingGet(completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

List assessment scales due for the authenticated patient

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// List assessment scales due for the authenticated patient
AssessmentsAPI.apiV1AssessmentsPendingGet() { (response, error) in
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

# **apiV1AssessmentsPost**
```swift
    open class func apiV1AssessmentsPost(apiV1AssessmentsPostRequest: ApiV1AssessmentsPostRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Submit a completed validated assessment scale

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1AssessmentsPostRequest = _api_v1_assessments__post_request(scale: "scale_example", score: 123, itemResponses: "TODO", notes: "notes_example") // ApiV1AssessmentsPostRequest | 

// Submit a completed validated assessment scale
AssessmentsAPI.apiV1AssessmentsPost(apiV1AssessmentsPostRequest: apiV1AssessmentsPostRequest) { (response, error) in
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
 **apiV1AssessmentsPostRequest** | [**ApiV1AssessmentsPostRequest**](ApiV1AssessmentsPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1AssessmentsScaleResponsesPost**
```swift
    open class func apiV1AssessmentsScaleResponsesPost(scale: Scale_apiV1AssessmentsScaleResponsesPost, apiV1AssessmentsScaleResponsesPostRequest: ApiV1AssessmentsScaleResponsesPostRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Submit a completed validated assessment scale using the scale path parameter

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let scale = "scale_example" // String | 
let apiV1AssessmentsScaleResponsesPostRequest = _api_v1_assessments__scale__responses_post_request(score: 123, itemResponses: "TODO", notes: "notes_example") // ApiV1AssessmentsScaleResponsesPostRequest | 

// Submit a completed validated assessment scale using the scale path parameter
AssessmentsAPI.apiV1AssessmentsScaleResponsesPost(scale: scale, apiV1AssessmentsScaleResponsesPostRequest: apiV1AssessmentsScaleResponsesPostRequest) { (response, error) in
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
 **scale** | **String** |  | 
 **apiV1AssessmentsScaleResponsesPostRequest** | [**ApiV1AssessmentsScaleResponsesPostRequest**](ApiV1AssessmentsScaleResponsesPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

