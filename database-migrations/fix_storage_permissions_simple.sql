-- SIMPLE VERSION - Fix storage permissions for room transfer images
-- Run this in your Supabase SQL Editor

-- Step 1: Set bucket to public
UPDATE storage.buckets 
SET public = true 
WHERE id = 'rooms';

-- Step 2: Drop old policies (if any)
DROP POLICY IF EXISTS "Allow authenticated users to upload images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public to read room images" ON storage.objects;

-- Step 3: Allow authenticated users to upload
CREATE POLICY "Allow authenticated users to upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'rooms');

-- Step 4: Allow everyone to view images
CREATE POLICY "Allow public to read room images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'rooms');

-- Done! Verify it worked:
SELECT id, name, public FROM storage.buckets WHERE id = 'rooms';

