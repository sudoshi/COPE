import type { LucideIcon } from 'lucide-react';

/**
 * The ONLY icon sizes allowed in COPE. Every icon must use one of these.
 * Sizes are pixel values passed to lucide's `size` prop.
 *
 *   xs (12) — inline with --text-xs, dense badges
 *   sm (14) — buttons, table cells, search, chips
 *   md (16) — default body-adjacent icons
 *   lg (20) — sidebar nav, section headers
 *   xl (24) — page headers
 *   2xl (32) — empty-state illustrations
 *
 * Stroke convention: 1.5 default, 2 for active/emphasis (mirrors Medgnosis).
 */
export const ICON_SIZES = {
  xs: 12,
  sm: 14,
  md: 16,
  lg: 20,
  xl: 24,
  '2xl': 32,
} as const;

export type IconSize = keyof typeof ICON_SIZES;

interface IconProps {
  /** A lucide-react icon component, e.g. `Bell`, `Users`. */
  icon: LucideIcon;
  size?: IconSize;
  strokeWidth?: number;
  className?: string;
  /**
   * Accessible label. Provide ONLY when the icon conveys meaning on its own
   * (e.g. an icon-only button). Omit for decorative icons sitting next to a
   * text label — those render `aria-hidden` so screen readers skip them.
   */
  title?: string;
}

/**
 * Thin wrapper over lucide-react that enforces the COPE icon size vocabulary
 * and correct ARIA semantics. Use this instead of raw lucide icons, emoji, or
 * ad-hoc inline SVGs so every icon renders at a deterministic, consistent size.
 */
export function Icon({ icon: Glyph, size = 'md', strokeWidth = 1.5, className, title }: IconProps) {
  return (
    <Glyph
      size={ICON_SIZES[size]}
      strokeWidth={strokeWidth}
      className={className}
      aria-hidden={title ? undefined : true}
      aria-label={title}
      role={title ? 'img' : undefined}
    />
  );
}
