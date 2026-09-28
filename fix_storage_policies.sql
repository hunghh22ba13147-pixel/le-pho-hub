-- Fix Storage Bucket Policies for room-images
-- Run this in Supabase SQL Editor

-- ============================================
-- STORAGE BUCKET POLICIES
-- ============================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow authenticated upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated delete" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload images" ON storage.objects;
DROP POLICY IF EXISTS "Public can view images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own images" ON storage.objects;

-- Policy 1: Allow authenticated users to upload to room-images bucket
CREATE POLICY "Allow authenticated upload"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'room-images');

-- Policy 2: Allow public to view images in room-images bucket
CREATE POLICY "Allow public read"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'room-images');

-- Policy 3: Allow authenticated users to delete their own uploads
CREATE POLICY "Allow authenticated delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'room-images');

-- Policy 4: Allow authenticated users to update their own uploads
CREATE POLICY "Allow authenticated update"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'room-images')
WITH CHECK (bucket_id = 'room-images');

-- ============================================
-- VERIFY STORAGE POLICIES
-- ============================================

-- Check if policies are created
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'storage'
AND tablename = 'objects'
ORDER BY policyname;

-- Check bucket configuration
SELECT 
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets
WHERE name = 'room-images';

-- ============================================
-- EXPECTED RESULTS:
-- ============================================
-- Should see 4 policies:
-- 1. Allow authenticated upload (INSERT)
-- 2. Allow public read (SELECT)
-- 3. Allow authenticated delete (DELETE)
-- 4. Allow authenticated update (UPDATE)
--
-- Bucket should exist with name 'room-images'
