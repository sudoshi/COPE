# COPE API Contract

`openapi.json` is generated from the Fastify API route registry.

Generate it from the repository root with:

```bash
npm run openapi:generate --workspace=@cope/api
```

The generator provides non-secret placeholder values for required config-only
variables such as `DATABASE_URL` and `JWT_SECRET`, and route-imported BullMQ
queues use lazy Redis connections during export.
