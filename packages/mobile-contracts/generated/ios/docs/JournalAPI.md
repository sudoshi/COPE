# JournalAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1JournalGet**](JournalAPI.md#apiv1journalget) | **GET** /api/v1/journal/ | List authenticated patient journal entries
[**apiV1JournalPost**](JournalAPI.md#apiv1journalpost) | **POST** /api/v1/journal/ | Create or upsert today journal entry


# **apiV1JournalGet**
```swift
    open class func apiV1JournalGet(page: Int? = nil, limit: Int? = nil, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

List authenticated patient journal entries

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let page = 987 // Int |  (optional) (default to 1)
let limit = 987 // Int |  (optional) (default to 20)

// List authenticated patient journal entries
JournalAPI.apiV1JournalGet(page: page, limit: limit) { (response, error) in
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

# **apiV1JournalPost**
```swift
    open class func apiV1JournalPost(apiV1JournalPostRequest: ApiV1JournalPostRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Create or upsert today journal entry

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1JournalPostRequest = _api_v1_journal__post_request(title: "title_example", body: "body_example", moodAtWriting: 123, isSharedWithCareTeam: false, tags: ["tags_example"]) // ApiV1JournalPostRequest | 

// Create or upsert today journal entry
JournalAPI.apiV1JournalPost(apiV1JournalPostRequest: apiV1JournalPostRequest) { (response, error) in
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
 **apiV1JournalPostRequest** | [**ApiV1JournalPostRequest**](ApiV1JournalPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

