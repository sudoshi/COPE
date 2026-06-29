# SafetyApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1SafetyMyPlanGet**](SafetyApi.md#apiV1SafetyMyPlanGet) | **GET** /api/v1/safety/my-plan | Get authenticated patient safety plan |
| [**apiV1SafetyResourcesGet**](SafetyApi.md#apiV1SafetyResourcesGet) | **GET** /api/v1/safety/resources | Get public crisis and safety resources |


<a id="apiV1SafetyMyPlanGet"></a>
# **apiV1SafetyMyPlanGet**
> ApiV1PatientsMeGet200Response apiV1SafetyMyPlanGet()

Get authenticated patient safety plan

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = SafetyApi()
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1SafetyMyPlanGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling SafetyApi#apiV1SafetyMyPlanGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling SafetyApi#apiV1SafetyMyPlanGet")
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

<a id="apiV1SafetyResourcesGet"></a>
# **apiV1SafetyResourcesGet**
> ApiV1PatientsMeGet200Response apiV1SafetyResourcesGet()

Get public crisis and safety resources

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = SafetyApi()
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1SafetyResourcesGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling SafetyApi#apiV1SafetyResourcesGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling SafetyApi#apiV1SafetyResourcesGet")
    e.printStackTrace()
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

