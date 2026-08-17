import "dotenv/config";
import { drizzle } from "drizzle-orm/node-postgres";
import { relations } from "./relations";

const db = drizzle(process.env.DATABASE_URL!, { relations, jit: true });

db.query.image.findFirst();
