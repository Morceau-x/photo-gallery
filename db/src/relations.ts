import { defineRelations } from "drizzle-orm";
import { image } from "./schemas/image";
import { imageMeta } from "./schemas/imageMeta";

export const relations = defineRelations({ image, imageMeta }, (r) => ({
  image: {
    meta: r.one.imageMeta({
      from: r.image.id,
      to: r.imageMeta.imageId,
    }),
  },
}));
