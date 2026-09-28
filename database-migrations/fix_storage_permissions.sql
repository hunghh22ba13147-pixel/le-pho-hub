-- Fix storage permissions for room transfer images
-- Run this in your Supabase SQL Editor

-- 1. Create storage bucket 'rooms' if not exists (skip if already exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('rooms', 'rooms', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Set bucket to public
UPDATE storage.buckets 
SET public = true 
WHERE id = 'rooms';

-- 3. Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Allow authenticated users to upload images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public to read room images" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to delete their own uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to update their own uploads" ON storage.objects;

-- 4. Create policy to allow authenticated users to upload
CREATE POLICY "Allow authenticated users to upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'rooms' 
  AND auth.role() = 'authenticated'
);

-- 5. Create policy to allow public read access
CREATE POLICY "Allow public to read room images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'rooms');

-- 6. Create policy to allow users to delete their own uploads
CREATE POLICY "Allow users to delete their own uploads"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'rooms'
);

-- 7. Create policy to allow users to update their own uploads
CREATE POLICY "Allow users to update their own uploads"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'rooms'
)
WITH CHECK (
  bucket_id = 'rooms'
);

-- Verify bucket settings
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
WHERE id = 'rooms';

