
# ApiV1DailyEntriesPostRequest

## Properties
| Name | Type | Description | Notes |
| ------------ | ------------- | ------------- | ------------- |
| **entryDate** | **kotlin.String** |  |  |
| **moodScore** | **kotlin.Int** |  |  |
| **sleepHours** | [**java.math.BigDecimal**](java.math.BigDecimal.md) |  |  [optional] |
| **sleepQuality** | **kotlin.Int** |  |  [optional] |
| **exerciseMinutes** | **kotlin.Int** |  |  [optional] |
| **notes** | **kotlin.String** |  |  [optional] |
| **triggers** | [**kotlin.collections.List&lt;ApiV1DailyEntriesPostRequestTriggersInner&gt;**](ApiV1DailyEntriesPostRequestTriggersInner.md) |  |  [optional] |
| **symptoms** | [**kotlin.collections.List&lt;ApiV1DailyEntriesPostRequestSymptomsInner&gt;**](ApiV1DailyEntriesPostRequestSymptomsInner.md) |  |  [optional] |
| **strategies** | [**kotlin.collections.List&lt;ApiV1DailyEntriesPostRequestStrategiesInner&gt;**](ApiV1DailyEntriesPostRequestStrategiesInner.md) |  |  [optional] |
| **maniaScore** | **kotlin.Int** |  |  [optional] |
| **racingThoughts** | **kotlin.Boolean** |  |  [optional] |
| **decreasedSleepNeed** | **kotlin.Boolean** |  |  [optional] |
| **anxietyScore** | **kotlin.Int** |  |  [optional] |
| **somaticAnxiety** | **kotlin.Boolean** |  |  [optional] |
| **anhedoniaScore** | **kotlin.Int** |  |  [optional] |
| **suicidalIdeation** | **kotlin.Int** |  |  [optional] |
| **substanceUse** | [**inline**](#SubstanceUse) |  |  [optional] |
| **substanceQuantity** | **kotlin.Int** |  |  [optional] |
| **socialScore** | **kotlin.Int** |  |  [optional] |
| **socialAvoidance** | **kotlin.Boolean** |  |  [optional] |
| **cognitiveScore** | **kotlin.Int** |  |  [optional] |
| **brainFog** | **kotlin.Boolean** |  |  [optional] |
| **appetiteScore** | **kotlin.Int** |  |  [optional] |
| **stressScore** | **kotlin.Int** |  |  [optional] |
| **lifeEventNote** | **kotlin.String** |  |  [optional] |


<a id="SubstanceUse"></a>
## Enum: substance_use
| Name | Value |
| ---- | ----- |
| substanceUse | none, alcohol, cannabis, other,  |



