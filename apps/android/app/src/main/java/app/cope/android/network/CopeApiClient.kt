package app.cope.android.network

import app.cope.android.BuildConfig
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL

data class HealthResponse(
    val status: String,
    val rawBody: String,
)

class CopeApiClient(
    baseUrl: String = BuildConfig.COPE_API_BASE_URL,
) {
    private val normalizedBaseUrl = baseUrl.trimEnd('/')

    fun getHealth(): HealthResponse {
        val connection = URL("$normalizedBaseUrl/health").openConnection() as HttpURLConnection
        connection.requestMethod = "GET"
        connection.connectTimeout = 10_000
        connection.readTimeout = 10_000

        return try {
            val code = connection.responseCode
            val stream = if (code in 200..299) connection.inputStream else connection.errorStream
            val body = stream?.bufferedReader()?.use { it.readText() }.orEmpty()
            if (code !in 200..299) {
                throw IOException("Health check failed with HTTP $code")
            }
            HealthResponse(status = extractStatus(body), rawBody = body)
        } finally {
            connection.disconnect()
        }
    }

    private fun extractStatus(body: String): String =
        """"status"\s*:\s*"([^"]+)"""".toRegex()
            .find(body)
            ?.groupValues
            ?.getOrNull(1)
            ?: "unknown"
}
