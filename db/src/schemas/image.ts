import { bigint, bytea, snakeCase, text } from "drizzle-orm/pg-core";
import { baseTable } from "../utils/base";

export const image = snakeCase.table("image", {
  ...baseTable,
  storageKey: text().notNull(),
  bucket: text().notNull(),
  originalFilename: text(),
  mimeType: text().notNull(),
  sizeBytes: bigint({ mode: "number" }).notNull(),
  checksumSha256: bytea().notNull(),
});
