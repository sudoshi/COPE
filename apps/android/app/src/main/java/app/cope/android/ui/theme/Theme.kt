package app.cope.android.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val CopeDarkColorScheme = darkColorScheme(
    primary = CopePrimary,
    onPrimary = CopeText,
    secondary = CopeSuccess,
    background = CopeBackground,
    onBackground = CopeText,
    surface = CopeSurface,
    onSurface = CopeText,
    surfaceVariant = CopeSurfaceElevated,
    onSurfaceVariant = CopeTextMuted,
    error = CopeDanger,
)

@Composable
fun CopeTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = CopeDarkColorScheme,
        content = content,
    )
}
