import {
  doublePrecision,
  integer,
  jsonb,
  pgEnum,
  real,
  snakeCase,
  text,
  timestamp,
  uuid,
} from "drizzle-orm/pg-core";
import { baseTable } from "../utils/base";
import { image } from "./image";

export const imageExifOrientation = pgEnum("image_exif_orientation", [
  "normal",
  "mirrored",
  "upside_down",
  "upside_down_mirrored",
  "left_side_top",
  "right_side_top",
  "right_side_bottom",
  "left_side_bottom",
]);

export const imageMeta = snakeCase.table("image_meta", {
  ...baseTable,
  imageId: uuid().references(() => image.id),
  widthPX: integer(),
  heightPX: integer(),
  orientation: imageExifOrientation(),
  takenAt: timestamp(),
  takenAtOffset: text(),
  uploadedAt: timestamp().notNull().defaultNow(),
  gpsLat: doublePrecision(),
  gpsLon: doublePrecision(),
  gpsAltitudeM: real(),
  cameraMake: text(),
  cameraModel: text(),
  exif: jsonb(),
});
