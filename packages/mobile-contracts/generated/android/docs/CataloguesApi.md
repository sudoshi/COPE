# CataloguesApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1CataloguesStrategiesGet**](CataloguesApi.md#apiV1CataloguesStrategiesGet) | **GET** /api/v1/catalogues/strategies | List wellness strategy catalogue options for the authenticated patient |
| [**apiV1CataloguesSymptomsGet**](CataloguesApi.md#apiV1CataloguesSymptomsGet) | **GET** /api/v1/catalogues/symptoms | List symptom catalogue options for the authenticated patient |
| [**apiV1CataloguesTriggersGet**](CataloguesApi.md#apiV1CataloguesTriggersGet) | **GET** /api/v1/catalogues/triggers | List trigger catalogue options for the authenticated patient |


<a id="apiV1CataloguesStrategiesGet"></a>
# **apiV1CataloguesStrategiesGet**
> ApiV1CataloguesStrategiesGet200Response apiV1CataloguesStrategiesGet()

List wellness strategy catalogue options for the authenticated patient

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = CataloguesApi()
try {
    val result : ApiV1CataloguesStrategiesGet200Response = apiInstance.apiV1CataloguesStrategiesGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling CataloguesApi#apiV1CataloguesStrategiesGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling CataloguesApi#apiV1CataloguesStrategiesGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiV1CataloguesStrategiesGet200Response**](ApiV1CataloguesStrategiesGet200Response.md)

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

<a id="apiV1CataloguesSymptomsGet"></a>
# **apiV1CataloguesSymptomsGet**
> ApiV1CataloguesSymptomsGet200Response apiV1CataloguesSymptomsGet()

List symptom catalogue options for the authenticated patient

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = CataloguesApi()
try {
    val result : ApiV1CataloguesSymptomsGet200Response = apiInstance.apiV1CataloguesSymptomsGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling CataloguesApi#apiV1CataloguesSymptomsGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling CataloguesApi#apiV1CataloguesSymptomsGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiV1CataloguesSymptomsGet200Response**](ApiV1CataloguesSymptomsGet200Response.md)

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

<a id="apiV1CataloguesTriggersGet"></a>
# **apiV1CataloguesTriggersGet**
> ApiV1CataloguesTriggersGet200Response apiV1CataloguesTriggersGet()

List trigger catalogue options for the authenticated patient

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = CataloguesApi()
try {
    val result : ApiV1CataloguesTriggersGet200Response = apiInstance.apiV1CataloguesTriggersGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling CataloguesApi#apiV1CataloguesTriggersGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling CataloguesApi#apiV1CataloguesTriggersGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiV1CataloguesTriggersGet200Response**](ApiV1CataloguesTriggersGet200Response.md)

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

