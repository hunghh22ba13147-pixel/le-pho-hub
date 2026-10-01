/**
 * Supabase Image Loader for Next.js
 * Le Pho Hub — returns Supabase storage URLs as-is
 */

/** @type {import('next/image').ImageLoader} */
export default function supabaseImageLoader({ src, width, quality }) {
  // For Supabase storage URLs, pass through with optional width/quality params
  if (src && src.includes('.supabase.co/storage/v1/')) {
    const url = new URL(src);
    if (width) url.searchParams.set('width', String(width));
    if (quality) url.searchParams.set('quality', String(quality || 75));
    return url.toString();
  }
  // For all other URLs, return as-is
  return src;
}
