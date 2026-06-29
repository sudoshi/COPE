# PatientsAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1PatientsMeGet**](PatientsAPI.md#apiv1patientsmeget) | **GET** /api/v1/patients/me | Get the authenticated patient profile
[**apiV1PatientsMeIntakePatch**](PatientsAPI.md#apiv1patientsmeintakepatch) | **PATCH** /api/v1/patients/me/intake | Update authenticated patient onboarding intake fields
[**apiV1PatientsMePatch**](PatientsAPI.md#apiv1patientsmepatch) | **PATCH** /api/v1/patients/me | Update authenticated patient profile preferences
[**apiV1PatientsMeStrategiesGet**](PatientsAPI.md#apiv1patientsmestrategiesget) | **GET** /api/v1/patients/me/strategies | List authenticated patient tracked wellness strategies
[**apiV1PatientsMeStrategiesPost**](PatientsAPI.md#apiv1patientsmestrategiespost) | **POST** /api/v1/patients/me/strategies | Add a wellness strategy to authenticated patient tracking
[**apiV1PatientsMeStrategiesStrategyIdDelete**](PatientsAPI.md#apiv1patientsmestrategiesstrategyiddelete) | **DELETE** /api/v1/patients/me/strategies/{strategyId} | Remove a wellness strategy from authenticated patient tracking
[**apiV1PatientsMeSymptomsGet**](PatientsAPI.md#apiv1patientsmesymptomsget) | **GET** /api/v1/patients/me/symptoms | List authenticated patient tracked symptoms
[**apiV1PatientsMeSymptomsPost**](PatientsAPI.md#apiv1patientsmesymptomspost) | **POST** /api/v1/patients/me/symptoms | Add a symptom to authenticated patient tracking
[**apiV1PatientsMeSymptomsSymptomIdDelete**](PatientsAPI.md#apiv1patientsmesymptomssymptomiddelete) | **DELETE** /api/v1/patients/me/symptoms/{symptomId} | Remove a symptom from authenticated patient tracking
[**apiV1PatientsMeTriggersGet**](PatientsAPI.md#apiv1patientsmetriggersget) | **GET** /api/v1/patients/me/triggers | List authenticated patient tracked triggers
[**apiV1PatientsMeTriggersPost**](PatientsAPI.md#apiv1patientsmetriggerspost) | **POST** /api/v1/patients/me/triggers | Add a trigger to authenticated patient tracking
[**apiV1PatientsMeTriggersTriggerIdDelete**](PatientsAPI.md#apiv1patientsmetriggerstriggeriddelete) | **DELETE** /api/v1/patients/me/triggers/{triggerId} | Remove a trigger from authenticated patient tracking


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

# **apiV1PatientsMeStrategiesGet**
```swift
    open class func apiV1PatientsMeStrategiesGet(completion: @escaping (_ data: ApiV1PatientsMeStrategiesGet200Response?, _ error: Error?) -> Void)
```

List authenticated patient tracked wellness strategies

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// List authenticated patient tracked wellness strategies
PatientsAPI.apiV1PatientsMeStrategiesGet() { (response, error) in
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

[**ApiV1PatientsMeStrategiesGet200Response**](ApiV1PatientsMeStrategiesGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PatientsMeStrategiesPost**
```swift
    open class func apiV1PatientsMeStrategiesPost(apiV1PatientsMeSymptomsPostRequest: ApiV1PatientsMeSymptomsPostRequest, completion: @escaping (_ data: ApiV1PatientsMeSymptomsPost201Response?, _ error: Error?) -> Void)
```

Add a wellness strategy to authenticated patient tracking

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1PatientsMeSymptomsPostRequest = _api_v1_patients_me_symptoms_post_request(id: 123) // ApiV1PatientsMeSymptomsPostRequest | 

// Add a wellness strategy to authenticated patient tracking
PatientsAPI.apiV1PatientsMeStrategiesPost(apiV1PatientsMeSymptomsPostRequest: apiV1PatientsMeSymptomsPostRequest) { (response, error) in
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
 **apiV1PatientsMeSymptomsPostRequest** | [**ApiV1PatientsMeSymptomsPostRequest**](ApiV1PatientsMeSymptomsPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeSymptomsPost201Response**](ApiV1PatientsMeSymptomsPost201Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PatientsMeStrategiesStrategyIdDelete**
```swift
    open class func apiV1PatientsMeStrategiesStrategyIdDelete(strategyId: UUID, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Remove a wellness strategy from authenticated patient tracking

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let strategyId = 987 // UUID | 

// Remove a wellness strategy from authenticated patient tracking
PatientsAPI.apiV1PatientsMeStrategiesStrategyIdDelete(strategyId: strategyId) { (response, error) in
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
 **strategyId** | **UUID** |  | 

### Return type

Void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PatientsMeSymptomsGet**
```swift
    open class func apiV1PatientsMeSymptomsGet(completion: @escaping (_ data: ApiV1PatientsMeSymptomsGet200Response?, _ error: Error?) -> Void)
```

List authenticated patient tracked symptoms

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// List authenticated patient tracked symptoms
PatientsAPI.apiV1PatientsMeSymptomsGet() { (response, error) in
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

[**ApiV1PatientsMeSymptomsGet200Response**](ApiV1PatientsMeSymptomsGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PatientsMeSymptomsPost**
```swift
    open class func apiV1PatientsMeSymptomsPost(apiV1PatientsMeSymptomsPostRequest: ApiV1PatientsMeSymptomsPostRequest, completion: @escaping (_ data: ApiV1PatientsMeSymptomsPost201Response?, _ error: Error?) -> Void)
```

Add a symptom to authenticated patient tracking

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1PatientsMeSymptomsPostRequest = _api_v1_patients_me_symptoms_post_request(id: 123) // ApiV1PatientsMeSymptomsPostRequest | 

// Add a symptom to authenticated patient tracking
PatientsAPI.apiV1PatientsMeSymptomsPost(apiV1PatientsMeSymptomsPostRequest: apiV1PatientsMeSymptomsPostRequest) { (response, error) in
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
 **apiV1PatientsMeSymptomsPostRequest** | [**ApiV1PatientsMeSymptomsPostRequest**](ApiV1PatientsMeSymptomsPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeSymptomsPost201Response**](ApiV1PatientsMeSymptomsPost201Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PatientsMeSymptomsSymptomIdDelete**
```swift
    open class func apiV1PatientsMeSymptomsSymptomIdDelete(symptomId: UUID, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Remove a symptom from authenticated patient tracking

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let symptomId = 987 // UUID | 

// Remove a symptom from authenticated patient tracking
PatientsAPI.apiV1PatientsMeSymptomsSymptomIdDelete(symptomId: symptomId) { (response, error) in
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
 **symptomId** | **UUID** |  | 

### Return type

Void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PatientsMeTriggersGet**
```swift
    open class func apiV1PatientsMeTriggersGet(completion: @escaping (_ data: ApiV1PatientsMeTriggersGet200Response?, _ error: Error?) -> Void)
```

List authenticated patient tracked triggers

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// List authenticated patient tracked triggers
PatientsAPI.apiV1PatientsMeTriggersGet() { (response, error) in
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

[**ApiV1PatientsMeTriggersGet200Response**](ApiV1PatientsMeTriggersGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PatientsMeTriggersPost**
```swift
    open class func apiV1PatientsMeTriggersPost(apiV1PatientsMeSymptomsPostRequest: ApiV1PatientsMeSymptomsPostRequest, completion: @escaping (_ data: ApiV1PatientsMeSymptomsPost201Response?, _ error: Error?) -> Void)
```

Add a trigger to authenticated patient tracking

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1PatientsMeSymptomsPostRequest = _api_v1_patients_me_symptoms_post_request(id: 123) // ApiV1PatientsMeSymptomsPostRequest | 

// Add a trigger to authenticated patient tracking
PatientsAPI.apiV1PatientsMeTriggersPost(apiV1PatientsMeSymptomsPostRequest: apiV1PatientsMeSymptomsPostRequest) { (response, error) in
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
 **apiV1PatientsMeSymptomsPostRequest** | [**ApiV1PatientsMeSymptomsPostRequest**](ApiV1PatientsMeSymptomsPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeSymptomsPost201Response**](ApiV1PatientsMeSymptomsPost201Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1PatientsMeTriggersTriggerIdDelete**
```swift
    open class func apiV1PatientsMeTriggersTriggerIdDelete(triggerId: UUID, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Remove a trigger from authenticated patient tracking

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let triggerId = 987 // UUID | 

// Remove a trigger from authenticated patient tracking
PatientsAPI.apiV1PatientsMeTriggersTriggerIdDelete(triggerId: triggerId) { (response, error) in
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
 **triggerId** | **UUID** |  | 

### Return type

Void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

