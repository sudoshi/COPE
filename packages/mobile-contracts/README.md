# COPE Mobile Contracts

This workspace owns native client contract generation from `docs/api/openapi.json`.
Generation first filters the full API document to a patient-mobile contract at
`packages/mobile-contracts/openapi-mobile.json`.

```bash
npm run validate --workspace=@cope/mobile-contracts
npm run generate --workspace=@cope/mobile-contracts
```

Generated clients are written under `packages/mobile-contracts/generated/` and should be reviewed before being wired into `apps/android` and `apps/ios`.

Current first targets:

- Android Kotlin client: OpenAPI Generator `kotlin`, `jvm-okhttp4`.
- iOS Swift client: OpenAPI Generator `swift5`, async/await-compatible configuration.

The hand-written native health clients in `apps/android` and `apps/ios` are temporary smoke clients. They should be replaced or wrapped once the generated clients are accepted.
