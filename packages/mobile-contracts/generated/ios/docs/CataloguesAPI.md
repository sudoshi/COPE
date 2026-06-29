# CataloguesAPI

All URIs are relative to *http://localhost:3000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1CataloguesStrategiesGet**](CataloguesAPI.md#apiv1cataloguesstrategiesget) | **GET** /api/v1/catalogues/strategies | List wellness strategy catalogue options for the authenticated patient
[**apiV1CataloguesSymptomsGet**](CataloguesAPI.md#apiv1cataloguessymptomsget) | **GET** /api/v1/catalogues/symptoms | List symptom catalogue options for the authenticated patient
[**apiV1CataloguesTriggersGet**](CataloguesAPI.md#apiv1cataloguestriggersget) | **GET** /api/v1/catalogues/triggers | List trigger catalogue options for the authenticated patient


# **apiV1CataloguesStrategiesGet**
```swift
    open class func apiV1CataloguesStrategiesGet(completion: @escaping (_ data: ApiV1CataloguesStrategiesGet200Response?, _ error: Error?) -> Void)
```

List wellness strategy catalogue options for the authenticated patient

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// List wellness strategy catalogue options for the authenticated patient
CataloguesAPI.apiV1CataloguesStrategiesGet() { (response, error) in
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

[**ApiV1CataloguesStrategiesGet200Response**](ApiV1CataloguesStrategiesGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1CataloguesSymptomsGet**
```swift
    open class func apiV1CataloguesSymptomsGet(completion: @escaping (_ data: ApiV1CataloguesSymptomsGet200Response?, _ error: Error?) -> Void)
```

List symptom catalogue options for the authenticated patient

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// List symptom catalogue options for the authenticated patient
CataloguesAPI.apiV1CataloguesSymptomsGet() { (response, error) in
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

[**ApiV1CataloguesSymptomsGet200Response**](ApiV1CataloguesSymptomsGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1CataloguesTriggersGet**
```swift
    open class func apiV1CataloguesTriggersGet(completion: @escaping (_ data: ApiV1CataloguesTriggersGet200Response?, _ error: Error?) -> Void)
```

List trigger catalogue options for the authenticated patient

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import COPEOpenAPI


// List trigger catalogue options for the authenticated patient
CataloguesAPI.apiV1CataloguesTriggersGet() { (response, error) in
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

[**ApiV1CataloguesTriggersGet200Response**](ApiV1CataloguesTriggersGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

