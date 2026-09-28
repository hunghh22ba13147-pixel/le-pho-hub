-- Quick Test Script for RLS Policies
-- Run this to verify policies are working correctly

-- ============================================
-- 1. Check if RLS is enabled on tables
-- ============================================
SELECT 
  tablename,
  rowsecurity as "RLS Enabled"
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN (
  'rooms', 
  'room_amenities', 
  'room_images', 
  'nearby_places', 
  'room_universities', 
  'room_video_reviews', 
  'room_units'
)
ORDER BY tablename;

-- ============================================
-- 2. List all policies for room-related tables
-- ============================================
SELECT 
  tablename as "Table",
  policyname as "Policy Name",
  cmd as "Command",
  roles as "Roles",
  permissive as "Type"
FROM pg_policies
WHERE tablename IN (
  'rooms', 
  'room_amenities', 
  'room_images', 
  'nearby_places', 
  'room_universities', 
  'room_video_reviews', 
  'room_units'
)
ORDER BY tablename, cmd, policyname;

-- ============================================
-- 3. Check current user info
-- ============================================
SELECT 
  auth.uid() as "User ID",
  auth.email() as "Email";

-- ============================================
-- 4. Check current user's profile and role
-- ============================================
SELECT 
  id,
  name,
  role,
  phone,
  created_at
FROM profiles 
WHERE id = auth.uid();

-- ============================================
-- 5. Count rooms by current user (if owner)
-- ============================================
SELECT 
  COUNT(*) as "My Rooms Count"
FROM rooms 
WHERE owner_id = auth.uid();

-- ============================================
-- 6. Test INSERT permission (dry run - will rollback)
-- ============================================
-- Uncomment to test (this will rollback automatically)
/*
BEGIN;
  INSERT INTO rooms (
    owner_id, 
    title, 
    address, 
    price, 
    area, 
    status
  ) VALUES (
    auth.uid(),
    'Test Room - Will Rollback',
    'Test Address',
    1000000,
    20,
    'available'
  );
  SELECT 'INSERT test passed!' as result;
ROLLBACK;
*/

-- ============================================
-- 7. Check Storage bucket policies
-- ============================================
SELECT 
  name as "Bucket Name",
  public as "Is Public",
  created_at
FROM storage.buckets
WHERE name = 'room-images';

-- ============================================
-- 8. List storage policies
-- ============================================
SELECT 
  policyname as "Policy Name",
  definition as "Definition"
FROM pg_policies
WHERE schemaname = 'storage'
AND tablename = 'objects'
ORDER BY policyname;

-- ============================================
-- EXPECTED RESULTS:
-- ============================================
-- 1. All tables should have RLS Enabled = true
-- 2. Should see policies like:
--    - owners_insert_own_rooms (INSERT)
--    - owners_update_own_rooms (UPDATE)
--    - owners_delete_own_rooms (DELETE)
--    - owners_select_own_rooms (SELECT)
--    - public_select_available_rooms (SELECT)
-- 3. Should see your user ID and email
-- 4. Should see your profile with role = 'owner'
-- 5. Should see count of your rooms (0 if new user)
-- 6. INSERT test should pass without errors
-- 7. room-images bucket should exist
-- 8. Should see storage policies for upload/view/delete
