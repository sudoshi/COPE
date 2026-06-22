import { Circle } from 'lucide-react';
import { ICON_SIZES, type IconSize } from './Icon';

const clampMood = (v: number): number => Math.min(10, Math.max(1, Math.round(v)));

/**
 * Short clinical band for a 1–10 mood value. Mirrors the buckets used on the
 * dashboard (High 8–10, Good 6–7, Moderate 4–5, Low 1–3).
 */
export function moodBand(value: number): string {
  const v = clampMood(value);
  if (v >= 8) return 'High';
  if (v >= 6) return 'Good';
  if (v >= 4) return 'Moderate';
  return 'Low';
}

interface MoodGlyphProps {
  /** Mood on the 1–10 scale. */
  value: number;
  /** Show the numeric value next to the dot. Default true. */
  showValue?: boolean;
  /** Show the band label (High/Good/Moderate/Low). Default false. */
  showLabel?: boolean;
  size?: IconSize;
  className?: string;
}

/**
 * Renders a mood as a colour-coded dot + number + optional label — never a
 * bare emoji. Encoding mood by hue ALONE fails for colour-blind clinicians,
 * monochrome displays, and screen readers, so the value/label always travel
 * with the colour ("colour = signal, never decoration"). The dot colour is
 * the data-driven `--mood-N` token, which is why it is set inline.
 */
export function MoodGlyph({
  value,
  showValue = true,
  showLabel = false,
  size = 'sm',
  className,
}: MoodGlyphProps) {
  const v = clampMood(value);
  const band = moodBand(v);

  return (
    <span
      className={`mood-glyph${className ? ` ${className}` : ''}`}
      role="img"
      aria-label={`Mood ${v} of 10, ${band}`}
    >
      <Circle
        size={ICON_SIZES[size]}
        fill="currentColor"
        stroke="none"
        style={{ color: `var(--mood-${v})` }}
        aria-hidden="true"
      />
      {showValue && <span className="text-sm font-semibold">{v}</span>}
      {showLabel && <span className="text-xs text-muted">{band}</span>}
    </span>
  );
}
