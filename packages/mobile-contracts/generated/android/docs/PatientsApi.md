# PatientsApi

All URIs are relative to *http://localhost:3000*

| Method | HTTP request | Description |
| ------------- | ------------- | ------------- |
| [**apiV1PatientsMeGet**](PatientsApi.md#apiV1PatientsMeGet) | **GET** /api/v1/patients/me | Get the authenticated patient profile |
| [**apiV1PatientsMeIntakePatch**](PatientsApi.md#apiV1PatientsMeIntakePatch) | **PATCH** /api/v1/patients/me/intake | Update authenticated patient onboarding intake fields |
| [**apiV1PatientsMePatch**](PatientsApi.md#apiV1PatientsMePatch) | **PATCH** /api/v1/patients/me | Update authenticated patient profile preferences |
| [**apiV1PatientsMeStrategiesGet**](PatientsApi.md#apiV1PatientsMeStrategiesGet) | **GET** /api/v1/patients/me/strategies | List authenticated patient tracked wellness strategies |
| [**apiV1PatientsMeStrategiesPost**](PatientsApi.md#apiV1PatientsMeStrategiesPost) | **POST** /api/v1/patients/me/strategies | Add a wellness strategy to authenticated patient tracking |
| [**apiV1PatientsMeStrategiesStrategyIdDelete**](PatientsApi.md#apiV1PatientsMeStrategiesStrategyIdDelete) | **DELETE** /api/v1/patients/me/strategies/{strategyId} | Remove a wellness strategy from authenticated patient tracking |
| [**apiV1PatientsMeSymptomsGet**](PatientsApi.md#apiV1PatientsMeSymptomsGet) | **GET** /api/v1/patients/me/symptoms | List authenticated patient tracked symptoms |
| [**apiV1PatientsMeSymptomsPost**](PatientsApi.md#apiV1PatientsMeSymptomsPost) | **POST** /api/v1/patients/me/symptoms | Add a symptom to authenticated patient tracking |
| [**apiV1PatientsMeSymptomsSymptomIdDelete**](PatientsApi.md#apiV1PatientsMeSymptomsSymptomIdDelete) | **DELETE** /api/v1/patients/me/symptoms/{symptomId} | Remove a symptom from authenticated patient tracking |
| [**apiV1PatientsMeTriggersGet**](PatientsApi.md#apiV1PatientsMeTriggersGet) | **GET** /api/v1/patients/me/triggers | List authenticated patient tracked triggers |
| [**apiV1PatientsMeTriggersPost**](PatientsApi.md#apiV1PatientsMeTriggersPost) | **POST** /api/v1/patients/me/triggers | Add a trigger to authenticated patient tracking |
| [**apiV1PatientsMeTriggersTriggerIdDelete**](PatientsApi.md#apiV1PatientsMeTriggersTriggerIdDelete) | **DELETE** /api/v1/patients/me/triggers/{triggerId} | Remove a trigger from authenticated patient tracking |


<a id="apiV1PatientsMeGet"></a>
# **apiV1PatientsMeGet**
> ApiV1PatientsMeGet200Response apiV1PatientsMeGet()

Get the authenticated patient profile

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1PatientsMeGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeGet")
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

<a id="apiV1PatientsMeIntakePatch"></a>
# **apiV1PatientsMeIntakePatch**
> ApiV1PatientsMeGet200Response apiV1PatientsMeIntakePatch(apiV1PatientsMeIntakePatchRequest)

Update authenticated patient onboarding intake fields

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
val apiV1PatientsMeIntakePatchRequest : ApiV1PatientsMeIntakePatchRequest =  // ApiV1PatientsMeIntakePatchRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1PatientsMeIntakePatch(apiV1PatientsMeIntakePatchRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeIntakePatch")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeIntakePatch")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1PatientsMeIntakePatchRequest** | [**ApiV1PatientsMeIntakePatchRequest**](ApiV1PatientsMeIntakePatchRequest.md)|  | |

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

<a id="apiV1PatientsMePatch"></a>
# **apiV1PatientsMePatch**
> ApiV1PatientsMeGet200Response apiV1PatientsMePatch(apiV1PatientsMePatchRequest)

Update authenticated patient profile preferences

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
val apiV1PatientsMePatchRequest : ApiV1PatientsMePatchRequest =  // ApiV1PatientsMePatchRequest | 
try {
    val result : ApiV1PatientsMeGet200Response = apiInstance.apiV1PatientsMePatch(apiV1PatientsMePatchRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMePatch")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMePatch")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1PatientsMePatchRequest** | [**ApiV1PatientsMePatchRequest**](ApiV1PatientsMePatchRequest.md)|  | |

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

<a id="apiV1PatientsMeStrategiesGet"></a>
# **apiV1PatientsMeStrategiesGet**
> ApiV1PatientsMeStrategiesGet200Response apiV1PatientsMeStrategiesGet()

List authenticated patient tracked wellness strategies

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
try {
    val result : ApiV1PatientsMeStrategiesGet200Response = apiInstance.apiV1PatientsMeStrategiesGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeStrategiesGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeStrategiesGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiV1PatientsMeStrategiesGet200Response**](ApiV1PatientsMeStrategiesGet200Response.md)

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

<a id="apiV1PatientsMeStrategiesPost"></a>
# **apiV1PatientsMeStrategiesPost**
> ApiV1PatientsMeSymptomsPost201Response apiV1PatientsMeStrategiesPost(apiV1PatientsMeSymptomsPostRequest)

Add a wellness strategy to authenticated patient tracking

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
val apiV1PatientsMeSymptomsPostRequest : ApiV1PatientsMeSymptomsPostRequest =  // ApiV1PatientsMeSymptomsPostRequest | 
try {
    val result : ApiV1PatientsMeSymptomsPost201Response = apiInstance.apiV1PatientsMeStrategiesPost(apiV1PatientsMeSymptomsPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeStrategiesPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeStrategiesPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1PatientsMeSymptomsPostRequest** | [**ApiV1PatientsMeSymptomsPostRequest**](ApiV1PatientsMeSymptomsPostRequest.md)|  | |

### Return type

[**ApiV1PatientsMeSymptomsPost201Response**](ApiV1PatientsMeSymptomsPost201Response.md)

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

<a id="apiV1PatientsMeStrategiesStrategyIdDelete"></a>
# **apiV1PatientsMeStrategiesStrategyIdDelete**
> apiV1PatientsMeStrategiesStrategyIdDelete(strategyId)

Remove a wellness strategy from authenticated patient tracking

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
val strategyId : java.util.UUID = 38400000-8cf0-11bd-b23e-10b96e4ef00d // java.util.UUID | 
try {
    apiInstance.apiV1PatientsMeStrategiesStrategyIdDelete(strategyId)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeStrategiesStrategyIdDelete")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeStrategiesStrategyIdDelete")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **strategyId** | **java.util.UUID**|  | |

### Return type

null (empty response body)

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

<a id="apiV1PatientsMeSymptomsGet"></a>
# **apiV1PatientsMeSymptomsGet**
> ApiV1PatientsMeSymptomsGet200Response apiV1PatientsMeSymptomsGet()

List authenticated patient tracked symptoms

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
try {
    val result : ApiV1PatientsMeSymptomsGet200Response = apiInstance.apiV1PatientsMeSymptomsGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeSymptomsGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeSymptomsGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiV1PatientsMeSymptomsGet200Response**](ApiV1PatientsMeSymptomsGet200Response.md)

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

<a id="apiV1PatientsMeSymptomsPost"></a>
# **apiV1PatientsMeSymptomsPost**
> ApiV1PatientsMeSymptomsPost201Response apiV1PatientsMeSymptomsPost(apiV1PatientsMeSymptomsPostRequest)

Add a symptom to authenticated patient tracking

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
val apiV1PatientsMeSymptomsPostRequest : ApiV1PatientsMeSymptomsPostRequest =  // ApiV1PatientsMeSymptomsPostRequest | 
try {
    val result : ApiV1PatientsMeSymptomsPost201Response = apiInstance.apiV1PatientsMeSymptomsPost(apiV1PatientsMeSymptomsPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeSymptomsPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeSymptomsPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1PatientsMeSymptomsPostRequest** | [**ApiV1PatientsMeSymptomsPostRequest**](ApiV1PatientsMeSymptomsPostRequest.md)|  | |

### Return type

[**ApiV1PatientsMeSymptomsPost201Response**](ApiV1PatientsMeSymptomsPost201Response.md)

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

<a id="apiV1PatientsMeSymptomsSymptomIdDelete"></a>
# **apiV1PatientsMeSymptomsSymptomIdDelete**
> apiV1PatientsMeSymptomsSymptomIdDelete(symptomId)

Remove a symptom from authenticated patient tracking

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
val symptomId : java.util.UUID = 38400000-8cf0-11bd-b23e-10b96e4ef00d // java.util.UUID | 
try {
    apiInstance.apiV1PatientsMeSymptomsSymptomIdDelete(symptomId)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeSymptomsSymptomIdDelete")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeSymptomsSymptomIdDelete")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **symptomId** | **java.util.UUID**|  | |

### Return type

null (empty response body)

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

<a id="apiV1PatientsMeTriggersGet"></a>
# **apiV1PatientsMeTriggersGet**
> ApiV1PatientsMeTriggersGet200Response apiV1PatientsMeTriggersGet()

List authenticated patient tracked triggers

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
try {
    val result : ApiV1PatientsMeTriggersGet200Response = apiInstance.apiV1PatientsMeTriggersGet()
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeTriggersGet")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeTriggersGet")
    e.printStackTrace()
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ApiV1PatientsMeTriggersGet200Response**](ApiV1PatientsMeTriggersGet200Response.md)

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

<a id="apiV1PatientsMeTriggersPost"></a>
# **apiV1PatientsMeTriggersPost**
> ApiV1PatientsMeSymptomsPost201Response apiV1PatientsMeTriggersPost(apiV1PatientsMeSymptomsPostRequest)

Add a trigger to authenticated patient tracking

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
val apiV1PatientsMeSymptomsPostRequest : ApiV1PatientsMeSymptomsPostRequest =  // ApiV1PatientsMeSymptomsPostRequest | 
try {
    val result : ApiV1PatientsMeSymptomsPost201Response = apiInstance.apiV1PatientsMeTriggersPost(apiV1PatientsMeSymptomsPostRequest)
    println(result)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeTriggersPost")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeTriggersPost")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **apiV1PatientsMeSymptomsPostRequest** | [**ApiV1PatientsMeSymptomsPostRequest**](ApiV1PatientsMeSymptomsPostRequest.md)|  | |

### Return type

[**ApiV1PatientsMeSymptomsPost201Response**](ApiV1PatientsMeSymptomsPost201Response.md)

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

<a id="apiV1PatientsMeTriggersTriggerIdDelete"></a>
# **apiV1PatientsMeTriggersTriggerIdDelete**
> apiV1PatientsMeTriggersTriggerIdDelete(triggerId)

Remove a trigger from authenticated patient tracking

### Example
```kotlin
// Import classes:
//import app.cope.contracts.infrastructure.*
//import app.cope.contracts.models.*

val apiInstance = PatientsApi()
val triggerId : java.util.UUID = 38400000-8cf0-11bd-b23e-10b96e4ef00d // java.util.UUID | 
try {
    apiInstance.apiV1PatientsMeTriggersTriggerIdDelete(triggerId)
} catch (e: ClientException) {
    println("4xx response calling PatientsApi#apiV1PatientsMeTriggersTriggerIdDelete")
    e.printStackTrace()
} catch (e: ServerException) {
    println("5xx response calling PatientsApi#apiV1PatientsMeTriggersTriggerIdDelete")
    e.printStackTrace()
}
```

### Parameters
| Name | Type | Description  | Notes |
| ------------- | ------------- | ------------- | ------------- |
| **triggerId** | **java.util.UUID**|  | |

### Return type

null (empty response body)

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

