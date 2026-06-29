# DailyEntriesAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1DailyEntriesIdSubmitPatch**](DailyEntriesAPI.md#apiv1dailyentriesidsubmitpatch) | **PATCH** /api/v1/daily-entries/{id}/submit | Mark a daily check-in as submitted
[**apiV1DailyEntriesPost**](DailyEntriesAPI.md#apiv1dailyentriespost) | **POST** /api/v1/daily-entries/ | Create or upsert a patient daily check-in
[**apiV1DailyEntriesTodayGet**](DailyEntriesAPI.md#apiv1dailyentriestodayget) | **GET** /api/v1/daily-entries/today | Get today&#39;s daily check-in


# **apiV1DailyEntriesIdSubmitPatch**
```swift
    open class func apiV1DailyEntriesIdSubmitPatch(id: UUID, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Mark a daily check-in as submitted

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let id = 987 // UUID | 

// Mark a daily check-in as submitted
DailyEntriesAPI.apiV1DailyEntriesIdSubmitPatch(id: id) { (response, error) in
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

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1DailyEntriesPost**
```swift
    open class func apiV1DailyEntriesPost(apiV1DailyEntriesPostRequest: ApiV1DailyEntriesPostRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Create or upsert a patient daily check-in

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1DailyEntriesPostRequest = _api_v1_daily_entries__post_request(entryDate: "entryDate_example", moodScore: 123, sleepHours: 123, sleepQuality: 123, exerciseMinutes: 123, notes: "notes_example", triggers: [_api_v1_daily_entries__post_request_triggers_inner(triggerId: 123, severity: 123)], symptoms: [_api_v1_daily_entries__post_request_symptoms_inner(symptomId: 123, severity: 123)], strategies: [_api_v1_daily_entries__post_request_strategies_inner(strategyId: 123, helped: false)], maniaScore: 123, racingThoughts: false, decreasedSleepNeed: false, anxietyScore: 123, somaticAnxiety: false, anhedoniaScore: 123, suicidalIdeation: 123, substanceUse: "substanceUse_example", substanceQuantity: 123, socialScore: 123, socialAvoidance: false, cognitiveScore: 123, brainFog: false, appetiteScore: 123, stressScore: 123, lifeEventNote: "lifeEventNote_example") // ApiV1DailyEntriesPostRequest | 

// Create or upsert a patient daily check-in
DailyEntriesAPI.apiV1DailyEntriesPost(apiV1DailyEntriesPostRequest: apiV1DailyEntriesPostRequest) { (response, error) in
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
 **apiV1DailyEntriesPostRequest** | [**ApiV1DailyEntriesPostRequest**](ApiV1DailyEntriesPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1DailyEntriesTodayGet**
```swift
    open class func apiV1DailyEntriesTodayGet(completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Get today's daily check-in

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// Get today's daily check-in
DailyEntriesAPI.apiV1DailyEntriesTodayGet() { (response, error) in
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

