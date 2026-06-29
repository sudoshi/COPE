# NotificationsAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1NotificationsPrefsGet**](NotificationsAPI.md#apiv1notificationsprefsget) | **GET** /api/v1/notifications/prefs | Get authenticated patient notification preferences
[**apiV1NotificationsPrefsPut**](NotificationsAPI.md#apiv1notificationsprefsput) | **PUT** /api/v1/notifications/prefs | Update authenticated patient notification preferences and push token
[**apiV1NotificationsPushTokenPost**](NotificationsAPI.md#apiv1notificationspushtokenpost) | **POST** /api/v1/notifications/push-token | Register or replace the authenticated patient push token


# **apiV1NotificationsPrefsGet**
```swift
    open class func apiV1NotificationsPrefsGet(completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Get authenticated patient notification preferences

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// Get authenticated patient notification preferences
NotificationsAPI.apiV1NotificationsPrefsGet() { (response, error) in
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

# **apiV1NotificationsPrefsPut**
```swift
    open class func apiV1NotificationsPrefsPut(apiV1NotificationsPrefsPutRequest: ApiV1NotificationsPrefsPutRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Update authenticated patient notification preferences and push token

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1NotificationsPrefsPutRequest = _api_v1_notifications_prefs_put_request(dailyReminderEnabled: false, dailyReminderTime: "dailyReminderTime_example", medicationReminderEnabled: false, streakNotifications: false, appointmentReminders: false, pushToken: "pushToken_example") // ApiV1NotificationsPrefsPutRequest | 

// Update authenticated patient notification preferences and push token
NotificationsAPI.apiV1NotificationsPrefsPut(apiV1NotificationsPrefsPutRequest: apiV1NotificationsPrefsPutRequest) { (response, error) in
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
 **apiV1NotificationsPrefsPutRequest** | [**ApiV1NotificationsPrefsPutRequest**](ApiV1NotificationsPrefsPutRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1NotificationsPushTokenPost**
```swift
    open class func apiV1NotificationsPushTokenPost(apiV1NotificationsPushTokenPostRequest: ApiV1NotificationsPushTokenPostRequest, completion: @escaping (_ data: ApiV1PatientsMeGet200Response?, _ error: Error?) -> Void)
```

Register or replace the authenticated patient push token

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI

let apiV1NotificationsPushTokenPostRequest = _api_v1_notifications_push_token_post_request(pushToken: "pushToken_example") // ApiV1NotificationsPushTokenPostRequest | 

// Register or replace the authenticated patient push token
NotificationsAPI.apiV1NotificationsPushTokenPost(apiV1NotificationsPushTokenPostRequest: apiV1NotificationsPushTokenPostRequest) { (response, error) in
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
 **apiV1NotificationsPushTokenPostRequest** | [**ApiV1NotificationsPushTokenPostRequest**](ApiV1NotificationsPushTokenPostRequest.md) |  | 

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

