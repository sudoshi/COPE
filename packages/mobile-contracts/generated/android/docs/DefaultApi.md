# DefaultApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1AssessmentsGet**](DefaultApi.md#apiV1AssessmentsGet) | **GET** /api/v1/assessments/ |  |
| [**apiV1DailyEntriesGet**](DefaultApi.md#apiV1DailyEntriesGet) | **GET** /api/v1/daily-entries/ |  |
| [**apiV1MedicationsGet**](DefaultApi.md#apiV1MedicationsGet) | **GET** /api/v1/medications/ |  |
| [**healthGet**](DefaultApi.md#healthGet) | **GET** /health |  |


<a id="apiV1AssessmentsGet"></a>
# **apiV1AssessmentsGet**
> apiV1AssessmentsGet()



### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = DefaultApi()
try {
    apiInstance.apiV1AssessmentsGet()
} catch (e: ClientException) {
    println("4xx response calling DefaultApi#apiV1AssessmentsGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling DefaultApi#apiV1AssessmentsGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

null (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

<a id="apiV1DailyEntriesGet"></a>
# **apiV1DailyEntriesGet**
> apiV1DailyEntriesGet()



### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = DefaultApi()
try {
    apiInstance.apiV1DailyEntriesGet()
} catch (e: ClientException) {
    println("4xx response calling DefaultApi#apiV1DailyEntriesGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling DefaultApi#apiV1DailyEntriesGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

null (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

<a id="apiV1MedicationsGet"></a>
# **apiV1MedicationsGet**
> apiV1MedicationsGet()



### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = DefaultApi()
try {
    apiInstance.apiV1MedicationsGet()
} catch (e: ClientException) {
    println("4xx response calling DefaultApi#apiV1MedicationsGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling DefaultApi#apiV1MedicationsGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

null (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

<a id="healthGet"></a>
# **healthGet**
> healthGet()



### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = DefaultApi()
try {
    apiInstance.healthGet()
} catch (e: ClientException) {
    println("4xx response calling DefaultApi#healthGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling DefaultApi#healthGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

null (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

