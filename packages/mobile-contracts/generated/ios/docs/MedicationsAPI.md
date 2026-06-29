# MedicationsAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1MedicationsIdLogsGet**](MedicationsAPI.md#apiv1medicationsidlogsget) | **GET** /api/v1/medications/{id}/logs | List adherence history for a medication
[**apiV1MedicationsIdLogsPost**](MedicationsAPI.md#apiv1medicationsidlogspost) | **POST** /api/v1/medications/{id}/logs | Log or upsert patient medication adherence
[**apiV1MedicationsPost**](MedicationsAPI.md#apiv1medicationspost) | **POST** /api/v1/medications/ | Add a patient medication
[**apiV1MedicationsTodayGet**](MedicationsAPI.md#apiv1medicationstodayget) | **GET** /api/v1/medications/today | Get today&#39;s active medications and adherence status


# **apiV1MedicationsIdLogsGet**
```swift
    open class func apiV1MedicationsIdLogsGet(id: UUID, page: Int? = nil, limit: Int? = nil, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

List adherence history for a medication

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let id = 987 // UUID | 
let page = 987 // Int |  (optional) (default to 1)
let limit = 987 // Int |  (optional) (default to 20)

// List adherence history for a medication
MedicationsAPI.apiV1MedicationsIdLogsGet(id: id, page: page, limit: limit) { (response, error) in
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
 **id** | **UUID** |  | 
 **page** | **Int** |  | [optional] [default to 1]
 **limit** | **Int** |  | [optional] [default to 20]

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1MedicationsIdLogsPost**
```swift
    open class func apiV1MedicationsIdLogsPost(id: UUID, apiV1MedicationsIdLogsPostRequest: ApiV1MedicationsIdLogsPostRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Log or upsert patient medication adherence

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let id = 987 // UUID | 
let apiV1MedicationsIdLogsPostRequest = _api_v1_medications__id__logs_post_request(entryDate: "entryDate_example", taken: false, takenAt: Date(), notes: "notes_example") // ApiV1MedicationsIdLogsPostRequest | 

// Log or upsert patient medication adherence
MedicationsAPI.apiV1MedicationsIdLogsPost(id: id, apiV1MedicationsIdLogsPostRequest: apiV1MedicationsIdLogsPostRequest) { (response, error) in
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
 **id** | **UUID** |  | 
 **apiV1MedicationsIdLogsPostRequest** | [**ApiV1MedicationsIdLogsPostRequest**](ApiV1MedicationsIdLogsPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1MedicationsPost**
```swift
    open class func apiV1MedicationsPost(apiV1MedicationsPostRequest: ApiV1MedicationsPostRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Add a patient medication

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1MedicationsPostRequest = _api_v1_medications__post_request(medicationName: "medicationName_example", dose: 123, doseUnit: "doseUnit_example", frequency: "frequency_example", frequencyOther: "frequencyOther_example", instructions: "instructions_example", prescribedAt: "prescribedAt_example", showInApp: false) // ApiV1MedicationsPostRequest | 

// Add a patient medication
MedicationsAPI.apiV1MedicationsPost(apiV1MedicationsPostRequest: apiV1MedicationsPostRequest) { (response, error) in
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
 **apiV1MedicationsPostRequest** | [**ApiV1MedicationsPostRequest**](ApiV1MedicationsPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1MedicationsTodayGet**
```swift
    open class func apiV1MedicationsTodayGet(completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Get today's active medications and adherence status

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// Get today's active medications and adherence status
MedicationsAPI.apiV1MedicationsTodayGet() { (response, error) in
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

