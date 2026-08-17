CREATE TYPE "image_exif_orientation" AS ENUM('normal', 'mirrored', 'upside_down', 'upside_down_mirrored', 'left_side_top', 'right_side_top', 'right_side_bottom', 'left_side_bottom');--> statement-breakpoint
CREATE TABLE "image" (
	"id" uuid PRIMARY KEY DEFAULT uuidv7
      (),
	"updated_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"deleted_at" timestamp,
	"storage_key" text NOT NULL,
	"bucket" text NOT NULL,
	"original_filename" text,
	"mime_type" text NOT NULL,
	"size_bytes" bigint NOT NULL,
	"checksum_sha256" bytea NOT NULL
);
--> statement-breakpoint
CREATE TABLE "image_meta" (
	"id" uuid PRIMARY KEY DEFAULT uuidv7
      (),
	"updated_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"deleted_at" timestamp,
	"image_id" uuid,
	"width_px" integer,
	"height_px" integer,
	"orientation" "image_exif_orientation",
	"taken_at" timestamp
);
--> statement-breakpoint
ALTER TABLE "image_meta" ADD CONSTRAINT "image_meta_image_id_image_id_fkey" FOREIGN KEY ("image_id") REFERENCES "image"("id");