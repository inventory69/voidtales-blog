import type { APIRoute } from "astro";
import { generateOgImageForSite } from "@/utils/generateOgImages";

export const GET: APIRoute = async () =>
  new Response(Buffer.from(await generateOgImageForSite()).buffer, {
    headers: { "Content-Type": "image/png" },
  });
