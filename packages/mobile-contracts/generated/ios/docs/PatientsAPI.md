# PatientsAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1PatientsMeGet**](PatientsAPI.md#apiv1patientsmeget) | **GET** /api/v1/patients/me | Get the authenticated patient profile
[**apiV1PatientsMeIntakePatch**](PatientsAPI.md#apiv1patientsmeintakepatch) | **PATCH** /api/v1/patients/me/intake | Update authenticated patient onboarding intake fields
[**apiV1PatientsMePatch**](PatientsAPI.md#apiv1patientsmepatch) | **PATCH** /api/v1/patients/me | Update authenticated patient profile preferences


# **apiV1PatientsMeGet**
```swift
    open class func apiV1PatientsMeGet(completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Get the authenticated patient profile

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// Get the authenticated patient profile
PatientsAPI.apiV1PatientsMeGet() { (response, error) in
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

# **apiV1PatientsMeIntakePatch**
```swift
    open class func apiV1PatientsMeIntakePatch(apiV1PatientsMeIntakePatchRequest: ApiV1PatientsMeIntakePatchRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Update authenticated patient onboarding intake fields

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1PatientsMeIntakePatchRequest = _api_v1_patients_me_intake_patch_request(primaryConcern: "primaryConcern_example", emergencyContactName: "emergencyContactName_example", emergencyContactPhone: "emergencyContactPhone_example", emergencyContactRelationship: "emergencyContactRelationship_example", markComplete: false) // ApiV1PatientsMeIntakePatchRequest | 

// Update authenticated patient onboarding intake fields
PatientsAPI.apiV1PatientsMeIntakePatch(apiV1PatientsMeIntakePatchRequest: apiV1PatientsMeIntakePatchRequest) { (response, error) in
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
 **apiV1PatientsMeIntakePatchRequest** | [**ApiV1PatientsMeIntakePatchRequest**](ApiV1PatientsMeIntakePatchRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PatientsMePatch**
```swift
    open class func apiV1PatientsMePatch(apiV1PatientsMePatchRequest: ApiV1PatientsMePatchRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Update authenticated patient profile preferences

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1PatientsMePatchRequest = _api_v1_patients_me_patch_request(preferredName: "preferredName_example", timezone: "timezone_example") // ApiV1PatientsMePatchRequest | 

// Update authenticated patient profile preferences
PatientsAPI.apiV1PatientsMePatch(apiV1PatientsMePatchRequest: apiV1PatientsMePatchRequest) { (response, error) in
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
 **apiV1PatientsMePatchRequest** | [**ApiV1PatientsMePatchRequest**](ApiV1PatientsMePatchRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

