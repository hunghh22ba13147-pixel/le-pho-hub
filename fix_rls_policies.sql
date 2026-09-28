-- Fix RLS Policies for Landlord (Owner) to create rooms
-- Run this SQL in Supabase SQL Editor

-- ============================================
-- 1. ROOMS TABLE - Allow owners to INSERT their own rooms
-- ============================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "owners_insert_own_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_update_own_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_delete_own_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_select_own_rooms" ON rooms;

-- Enable RLS on rooms table (if not already enabled)
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;

-- Policy: Owners can INSERT their own rooms
CREATE POLICY "owners_insert_own_rooms" ON rooms
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = owner_id
    AND EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'owner'
    )
  );

-- Policy: Owners can UPDATE their own rooms
CREATE POLICY "owners_update_own_rooms" ON rooms
  FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = owner_id
    AND EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'owner'
    )
  )
  WITH CHECK (
    auth.uid() = owner_id
  );

-- Policy: Owners can DELETE their own rooms
CREATE POLICY "owners_delete_own_rooms" ON rooms
  FOR DELETE
  TO authenticated
  USING (
    auth.uid() = owner_id
    AND EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'owner'
    )
  );

-- Policy: Owners can SELECT their own rooms
CREATE POLICY "owners_select_own_rooms" ON rooms
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = owner_id
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin')
    )
  );

-- Policy: Public can SELECT available rooms
DROP POLICY IF EXISTS "public_select_available_rooms" ON rooms;
CREATE POLICY "public_select_available_rooms" ON rooms
  FOR SELECT
  TO public
  USING (status IN ('available', 'reserved', 'rented'));

-- ============================================
-- 2. ROOM_AMENITIES TABLE
-- ============================================

DROP POLICY IF EXISTS "owners_insert_room_amenities" ON room_amenities;
DROP POLICY IF EXISTS "owners_delete_room_amenities" ON room_amenities;

ALTER TABLE room_amenities ENABLE ROW LEVEL SECURITY;

-- Policy: Owners can INSERT amenities for their own rooms
CREATE POLICY "owners_insert_room_amenities" ON room_amenities
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_amenities.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Owners can DELETE amenities from their own rooms
CREATE POLICY "owners_delete_room_amenities" ON room_amenities
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_amenities.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Public can SELECT room amenities
DROP POLICY IF EXISTS "public_select_room_amenities" ON room_amenities;
CREATE POLICY "public_select_room_amenities" ON room_amenities
  FOR SELECT
  TO public
  USING (true);

-- ============================================
-- 3. ROOM_IMAGES TABLE
-- ============================================

DROP POLICY IF EXISTS "owners_insert_room_images" ON room_images;
DROP POLICY IF EXISTS "owners_delete_room_images" ON room_images;

ALTER TABLE room_images ENABLE ROW LEVEL SECURITY;

-- Policy: Owners can INSERT images for their own rooms
CREATE POLICY "owners_insert_room_images" ON room_images
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_images.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Owners can DELETE images from their own rooms
CREATE POLICY "owners_delete_room_images" ON room_images
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_images.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Public can SELECT room images
DROP POLICY IF EXISTS "public_select_room_images" ON room_images;
CREATE POLICY "public_select_room_images" ON room_images
  FOR SELECT
  TO public
  USING (true);

-- ============================================
-- 4. NEARBY_PLACES TABLE
-- ============================================

DROP POLICY IF EXISTS "owners_insert_nearby_places" ON nearby_places;
DROP POLICY IF EXISTS "owners_update_nearby_places" ON nearby_places;
DROP POLICY IF EXISTS "owners_delete_nearby_places" ON nearby_places;

ALTER TABLE nearby_places ENABLE ROW LEVEL SECURITY;

-- Policy: Owners can INSERT nearby places for their own rooms
CREATE POLICY "owners_insert_nearby_places" ON nearby_places
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = nearby_places.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Owners can UPDATE nearby places for their own rooms
CREATE POLICY "owners_update_nearby_places" ON nearby_places
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = nearby_places.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Owners can DELETE nearby places from their own rooms
CREATE POLICY "owners_delete_nearby_places" ON nearby_places
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = nearby_places.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Public can SELECT nearby places
DROP POLICY IF EXISTS "public_select_nearby_places" ON nearby_places;
CREATE POLICY "public_select_nearby_places" ON nearby_places
  FOR SELECT
  TO public
  USING (true);

-- ============================================
-- 5. ROOM_UNIVERSITIES TABLE
-- ============================================

DROP POLICY IF EXISTS "owners_insert_room_universities" ON room_universities;
DROP POLICY IF EXISTS "owners_delete_room_universities" ON room_universities;

ALTER TABLE room_universities ENABLE ROW LEVEL SECURITY;

-- Policy: Owners can INSERT university associations for their own rooms
CREATE POLICY "owners_insert_room_universities" ON room_universities
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_universities.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Owners can DELETE university associations from their own rooms
CREATE POLICY "owners_delete_room_universities" ON room_universities
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_universities.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Public can SELECT room universities
DROP POLICY IF EXISTS "public_select_room_universities" ON room_universities;
CREATE POLICY "public_select_room_universities" ON room_universities
  FOR SELECT
  TO public
  USING (true);

-- ============================================
-- 6. ROOM_VIDEO_REVIEWS TABLE
-- ============================================

DROP POLICY IF EXISTS "owners_insert_room_video_reviews" ON room_video_reviews;
DROP POLICY IF EXISTS "owners_update_room_video_reviews" ON room_video_reviews;
DROP POLICY IF EXISTS "owners_delete_room_video_reviews" ON room_video_reviews;

ALTER TABLE room_video_reviews ENABLE ROW LEVEL SECURITY;

-- Policy: Owners can INSERT video reviews for their own rooms
CREATE POLICY "owners_insert_room_video_reviews" ON room_video_reviews
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_video_reviews.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Owners can UPDATE video reviews for their own rooms
CREATE POLICY "owners_update_room_video_reviews" ON room_video_reviews
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_video_reviews.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Owners can DELETE video reviews from their own rooms
CREATE POLICY "owners_delete_room_video_reviews" ON room_video_reviews
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_video_reviews.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Public can SELECT room video reviews
DROP POLICY IF EXISTS "public_select_room_video_reviews" ON room_video_reviews;
CREATE POLICY "public_select_room_video_reviews" ON room_video_reviews
  FOR SELECT
  TO public
  USING (true);

-- ============================================
-- 7. ROOM_UNITS TABLE (for landlord's actual room units)
-- ============================================

DROP POLICY IF EXISTS "owners_insert_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_update_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_delete_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_select_room_units" ON room_units;

ALTER TABLE room_units ENABLE ROW LEVEL SECURITY;

-- Policy: Owners can INSERT room units for their own properties
CREATE POLICY "owners_insert_room_units" ON room_units
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_units.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Owners can UPDATE their own room units
CREATE POLICY "owners_update_room_units" ON room_units
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_units.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Owners can DELETE their own room units
CREATE POLICY "owners_delete_room_units" ON room_units
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_units.room_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- Policy: Owners can SELECT their own room units
CREATE POLICY "owners_select_room_units" ON room_units
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms
      WHERE rooms.id = room_units.room_id
      AND rooms.owner_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- ============================================
-- 8. STORAGE BUCKET POLICIES (room-images)
-- ============================================

-- Allow authenticated users to upload images
-- Note: Run this in Supabase Dashboard > Storage > room-images > Policies

-- INSERT policy for room-images bucket:
-- Name: "Authenticated users can upload images"
-- Policy: 
-- CREATE POLICY "Authenticated users can upload images"
-- ON storage.objects FOR INSERT
-- TO authenticated
-- WITH CHECK (bucket_id = 'room-images');

-- SELECT policy for room-images bucket:
-- Name: "Public can view images"
-- Policy:
-- CREATE POLICY "Public can view images"
-- ON storage.objects FOR SELECT
-- TO public
-- USING (bucket_id = 'room-images');

-- DELETE policy for room-images bucket:
-- Name: "Users can delete their own images"
-- Policy:
-- CREATE POLICY "Users can delete their own images"
-- ON storage.objects FOR DELETE
-- TO authenticated
-- USING (bucket_id = 'room-images' AND auth.uid()::text = owner);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check if policies are created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('rooms', 'room_amenities', 'room_images', 'nearby_places', 'room_universities', 'room_video_reviews', 'room_units')
ORDER BY tablename, policyname;

-- Check current user's role
SELECT id, name, role FROM profiles WHERE id = auth.uid();
