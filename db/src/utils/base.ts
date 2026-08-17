import { uuid } from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";
import { timestamps } from "./timestamps";

export const baseTable = {
  id: uuid()
    .primaryKey()
    .default(sql`uuidv7()`),
  ...timestamps,
};
