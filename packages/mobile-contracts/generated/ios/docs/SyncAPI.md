# SyncAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1SyncPullGet**](SyncAPI.md#apiv1syncpullget) | **GET** /api/v1/sync/pull | Pull WatermelonDB-compatible offline changes
[**apiV1SyncPushPost**](SyncAPI.md#apiv1syncpushpost) | **POST** /api/v1/sync/push | Push WatermelonDB-compatible offline changes


# **apiV1SyncPullGet**
```swift
    open class func apiV1SyncPullGet(lastPulledAt: String? = nil, completion: @escaping (_ data: ApiV1SyncPullGet200Response?, _ error: Error?) -> Void)
```

Pull WatermelonDB-compatible offline changes

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let lastPulledAt = "lastPulledAt_example" // String |  (optional)

// Pull WatermelonDB-compatible offline changes
SyncAPI.apiV1SyncPullGet(lastPulledAt: lastPulledAt) { (response, error) in
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
 **lastPulledAt** | **String** |  | [optional] 

### Return type

[**ApiV1SyncPullGet200Response**](ApiV1SyncPullGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1SyncPushPost**
```swift
    open class func apiV1SyncPushPost(apiV1SyncPushPostRequest: ApiV1SyncPushPostRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Push WatermelonDB-compatible offline changes

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1SyncPushPostRequest = _api_v1_sync_push_post_request(changes: _api_v1_sync_push_post_request_changes(dailyEntries: _api_v1_sync_pull_get_200_response_data_changes_daily_entries(created: [_api_v1_sync_pull_get_200_response_data_changes_daily_entries_created_inner(id: 123, serverId: 123, patientId: 123, entryDate: "entryDate_example", moodScore: 123, sleepHours: 123, exerciseMinutes: 123, notes: "notes_example", isComplete: false, completionPct: 123, coreComplete: false, wellnessComplete: false, triggersComplete: false, symptomsComplete: false, journalComplete: false, maniaScore: 123, racingThoughts: false, decreasedSleepNeed: false, anxietyScore: 123, somaticAnxiety: false, anhedoniaScore: 123, suicidalIdeation: 123, substanceUse: "substanceUse_example", substanceQuantity: 123, socialScore: 123, socialAvoidance: false, cognitiveScore: 123, brainFog: false, appetiteScore: 123, stressScore: 123, lifeEventNote: "lifeEventNote_example", submittedAt: Date(), syncedAt: 123, isDirty: false, createdAt: _api_v1_sync_pull_get_200_response_data_changes_daily_entries_created_inner_created_at(), updatedAt: nil)], updated: [nil], deleted: ["deleted_example"]), dailyEntryTriggers: _api_v1_sync_pull_get_200_response_data_changes_daily_entry_triggers(created: ["TODO"], updated: ["TODO"], deleted: ["deleted_example"]), dailyEntrySymptoms: nil, dailyEntryStrategies: nil, journalEntries: nil), lastPulledAt: 123) // ApiV1SyncPushPostRequest | 

// Push WatermelonDB-compatible offline changes
SyncAPI.apiV1SyncPushPost(apiV1SyncPushPostRequest: apiV1SyncPushPostRequest) { (response, error) in
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
 **apiV1SyncPushPostRequest** | [**ApiV1SyncPushPostRequest**](ApiV1SyncPushPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

