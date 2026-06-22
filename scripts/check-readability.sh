#!/usr/bin/env bash
# =============================================================================
# COPE readability gate
# Prevents regression of the icon/typography remediation (Phases 0-2).
# See apps/web/design/DESIGN_SYSTEM.md and design/READABILITY_REMEDIATION_PLAN.md.
#
# Fails (exit 1) if any of the following reappear in the web app:
#   1. Numeric inline font sizes   — use fontSize: 'var(--text-*)'
#   2. Pictographic emoji as icons — use the <Icon> primitive (lucide-react)
#   3. Raw px font-sizes for text  — use var(--text-*)
#
# Typographic glyphs (arrows → ← ↑ ↓ ↕, geometric ▲ ▼ ● ○, · — …) are allowed.
# =============================================================================
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEB="$ROOT/apps/web/src"
fail=0

section() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# 1. No numeric inline font sizes.
hits=$(grep -rnE "fontSize: ?[0-9]" --include="*.tsx" "$WEB" 2>/dev/null || true)
if [ -n "$hits" ]; then
  section "✗ Numeric inline fontSize — use fontSize: 'var(--text-*)':"
  echo "$hits"; fail=1
fi

# 2. No pictographic emoji as icons (lucide <Icon> only).
hits=$(grep -rnP '[\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}\x{2B00}-\x{2BFF}\x{FE0F}]' \
  --include="*.tsx" "$WEB" 2>/dev/null || true)
if [ -n "$hits" ]; then
  section "✗ Pictographic emoji — use <Icon> from components/ui/Icon (lucide-react):"
  echo "$hits"; fail=1
fi

# 3. No raw px font-sizes for text in component/page CSS.
#    (*-icon rules size icon glyphs, not text — exempt by tracking the selector.)
hits=$(find "$WEB/styles/components" "$WEB/styles/pages" -name '*.css' 2>/dev/null -exec awk '
  /\{/ { sel = $0 }
  /font-size:[[:space:]]*[0-9.]+px/ { if (sel !~ /icon/) printf "%s:%d:%s\n", FILENAME, FNR, $0 }
' {} + || true)
if [ -n "$hits" ]; then
  section "✗ Raw px font-size for text — use var(--text-*):"
  echo "$hits"; fail=1
fi

if [ "$fail" -eq 0 ]; then
  printf '\033[32m✓ readability gate passed\033[0m\n'
fi
exit "$fail"
