// =============================================================================
// COPE — ESLint flat config (shared by all workspaces)
// Workspace lint scripts run `eslint <dir>`; ESLint 9 resolves this config by
// walking up from the linted files.
// =============================================================================

import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  {
    ignores: [
      '**/dist/**',
      '**/node_modules/**',
      '**/coverage/**',
      'apps/mobile/android/**',
      'apps/mobile/.expo/**',
      'apps/web/playwright-report/**',
      'apps/web/test-results/**',
      '**/*.config.js',
      '**/*.config.ts',
      '**/babel.config.js',
      '**/metro.config.js',
    ],
  },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      // House rules (see ~/.claude + project standards)
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      // Fire-and-forget paths intentionally use empty catch
      'no-empty': ['error', { allowEmptyCatch: true }],
    },
  },
  {
    // React Native loads static assets and optional native modules via
    // require() — that idiom is correct on mobile.
    files: ['apps/mobile/**'],
    rules: {
      '@typescript-eslint/no-require-imports': 'off',
    },
  },
  {
    // Web typography contract: inline font sizes must use --text-* tokens, not
    // raw px numbers (RN/mobile is exempt — numeric fontSize is correct there).
    // See apps/web/design/DESIGN_SYSTEM.md and scripts/check-readability.sh.
    files: ['apps/web/**/*.{ts,tsx}'],
    rules: {
      'no-restricted-syntax': [
        'error',
        {
          selector: "Property[key.name='fontSize'] > Literal[raw=/^[0-9]/]",
          message:
            "Use a typography token — fontSize: 'var(--text-*)' — not a numeric px value. See apps/web/design/DESIGN_SYSTEM.md.",
        },
      ],
    },
  },
  {
    // Plain .js files (Expo config plugins, maintenance scripts) are CommonJS
    // run directly by Node.
    files: ['**/*.js', '**/*.cjs'],
    languageOptions: {
      sourceType: 'commonjs',
      globals: {
        require: 'readonly',
        module: 'writable',
        exports: 'writable',
        process: 'readonly',
        console: 'readonly',
        __dirname: 'readonly',
        Buffer: 'readonly',
      },
    },
  },
);
