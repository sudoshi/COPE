// =============================================================================
// COPE API - BullMQ queue factory
// =============================================================================

import { Queue, type QueueOptions } from 'bullmq';

function isOpenApiExport(): boolean {
  return process.env['OPENAPI_EXPORT'] === 'true';
}

export function createQueue<
  DataTypeOrJob = unknown,
  DefaultResultType = unknown,
  DefaultNameType extends string = string,
>(
  name: string,
  options: QueueOptions,
): Queue<DataTypeOrJob, DefaultResultType, DefaultNameType> {
  if (!isOpenApiExport()) {
    return new Queue<DataTypeOrJob, DefaultResultType, DefaultNameType>(name, options);
  }

  return {
    name,
    add: async () => {
      throw new Error(`Queue ${name} is unavailable during OpenAPI export`);
    },
    close: async () => undefined,
  } as unknown as Queue<DataTypeOrJob, DefaultResultType, DefaultNameType>;
}
