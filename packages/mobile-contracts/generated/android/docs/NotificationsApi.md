# NotificationsApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1NotificationsPrefsGet**](NotificationsApi.md#apiV1NotificationsPrefsGet) | **GET** /api/v1/notifications/prefs | Get authenticated patient notification preferences |
| [**apiV1NotificationsPrefsPut**](NotificationsApi.md#apiV1NotificationsPrefsPut) | **PUT** /api/v1/notifications/prefs | Update authenticated patient notification preferences and push token |
| [**apiV1NotificationsPushTokenPost**](NotificationsApi.md#apiV1NotificationsPushTokenPost) | **POST** /api/v1/notifications/push-token | Register or replace the authenticated patient push token |


<a id="apiV1NotificationsPrefsGet"></a>
# **apiV1NotificationsPrefsGet**
> ApiV1PatientsMeGet200Response apiV1NotificationsPrefsGet()

Get authenticated patient notification preferences

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = NotificationsApi()
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1NotificationsPrefsGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling NotificationsApi#apiV1NotificationsPrefsGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling NotificationsApi#apiV1NotificationsPrefsGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization


Configure bearerAuth statically:
```kotlin
ApiClient.accessToken = ""
```
Configure bearerAuth dynamically:
```kotlin
apiInstance.accessTokenProvider = { "" }
```

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

<a id="apiV1NotificationsPrefsPut"></a>
# **apiV1NotificationsPrefsPut**
> ApiV1PatientsMeGet200Response apiV1NotificationsPrefsPut(apiV1NotificationsPrefsPutRequest)

Update authenticated patient notification preferences and push token

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = NotificationsApi()
val apiV1NotificationsPrefsPutRequest : ApiV1NotificationsPrefsPutRequest =  // ApiV1NotificationsPrefsPutRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1NotificationsPrefsPut(apiV1NotificationsPrefsPutRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling NotificationsApi#apiV1NotificationsPrefsPut")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling NotificationsApi#apiV1NotificationsPrefsPut")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1NotificationsPrefsPutRequest** | [**ApiV1NotificationsPrefsPutRequest**](ApiV1NotificationsPrefsPutRequest.md)|  | |

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization


Configure bearerAuth statically:
```kotlin
ApiClient.accessToken = ""
```
Configure bearerAuth dynamically:
```kotlin
apiInstance.accessTokenProvider = { "" }
```

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

<a id="apiV1NotificationsPushTokenPost"></a>
# **apiV1NotificationsPushTokenPost**
> ApiV1PatientsMeGet200Response apiV1NotificationsPushTokenPost(apiV1NotificationsPushTokenPostRequest)

Register or replace the authenticated patient push token

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = NotificationsApi()
val apiV1NotificationsPushTokenPostRequest : ApiV1NotificationsPushTokenPostRequest =  // ApiV1NotificationsPushTokenPostRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1NotificationsPushTokenPost(apiV1NotificationsPushTokenPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling NotificationsApi#apiV1NotificationsPushTokenPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling NotificationsApi#apiV1NotificationsPushTokenPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1NotificationsPushTokenPostRequest** | [**ApiV1NotificationsPushTokenPostRequest**](ApiV1NotificationsPushTokenPostRequest.md)|  | |

### Return type

[**ApiV1PatientsMeGet200Response**](ApiV1PatientsMeGet200Response.md)

### Authorization


Configure bearerAuth statically:
```kotlin
ApiClient.accessToken = ""
```
Configure bearerAuth dynamically:
```kotlin
apiInstance.accessTokenProvider = { "" }
```

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

