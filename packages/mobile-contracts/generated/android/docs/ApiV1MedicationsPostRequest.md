
# ApiV1MedicationsPostRequest

## Properties
| Name | Type | Description | Notes |
| ------------ | ------------- | ------------- | ------------- |
| **medicationName** | **kotlin.String** |  |  |
| **frequency** | [**inline**](#Frequency) |  |  |
| **dose** | [**java.math.BigDecimal**](java.math.BigDecimal.md) |  |  [optional] |
| **doseUnit** | **kotlin.String** |  |  [optional] |
| **frequencyOther** | **kotlin.String** |  |  [optional] |
| **instructions** | **kotlin.String** |  |  [optional] |
| **prescribedAt** | **kotlin.String** |  |  [optional] |
| **showInApp** | **kotlin.Boolean** |  |  [optional] |


<a id="Frequency"></a>
## Enum: frequency
| Name | Value |
| ---- | ----- |
| frequency | once_daily_morning, once_daily_evening, once_daily_bedtime, twice_daily, three_times_daily, as_needed, weekly, other |



