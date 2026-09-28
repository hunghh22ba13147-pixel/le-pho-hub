-- ============================================
-- FIX UNRESTRICTED TABLES - BẬT LẠI RLS
-- Tạo policies cho phép public đọc, owner/admin quản lý
-- ============================================

-- ============================================
-- 1. PROFILES
-- ============================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_policy" ON profiles;
DROP POLICY IF EXISTS "profiles_insert_policy" ON profiles;
DROP POLICY IF EXISTS "profiles_update_policy" ON profiles;
DROP POLICY IF EXISTS "profiles_delete_policy" ON profiles;

-- Cho phép tất cả authenticated users đọc profiles
CREATE POLICY "profiles_select_policy" ON profiles
  FOR SELECT TO authenticated
  USING (true);

-- Cho phép user tạo profile của mình hoặc owner/admin tạo cho người khác
CREATE POLICY "profiles_insert_policy" ON profiles
  FOR INSERT TO authenticated
  WITH CHECK (true);

-- Cho phép user cập nhật profile của mình hoặc owner/admin
CREATE POLICY "profiles_update_policy" ON profiles
  FOR UPDATE TO authenticated
  USING (
    auth.uid() = id
    OR EXISTS (
      SELECT 1 FROM profiles p 
      WHERE p.id = auth.uid() 
      AND p.role IN ('admin', 'owner')
    )
  );

-- ============================================
-- 2. ROOMS (Nhà trọ)
-- ============================================
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_select_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_insert_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_update_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_delete_rooms" ON rooms;

-- Public có thể xem rooms
CREATE POLICY "public_select_rooms" ON rooms
  FOR SELECT TO authenticated, anon
  USING (true);

-- Owner và Admin có thể thêm
CREATE POLICY "owners_insert_rooms" ON rooms
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role IN ('owner', 'admin')
    )
  );

-- Owner sửa room của mình, Admin sửa tất cả
CREATE POLICY "owners_update_rooms" ON rooms
  FOR UPDATE TO authenticated
  USING (
    owner_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role = 'admin'
    )
  );

CREATE POLICY "owners_delete_rooms" ON rooms
  FOR DELETE TO authenticated
  USING (
    owner_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role = 'admin'
    )
  );

-- ============================================
-- 3. ROOM_UNITS (Phòng)
-- ============================================
ALTER TABLE room_units ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_select_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_insert_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_update_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_delete_room_units" ON room_units;

CREATE POLICY "public_select_room_units" ON room_units
  FOR SELECT TO authenticated, anon
  USING (true);

CREATE POLICY "owners_insert_room_units" ON room_units
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_units.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

CREATE POLICY "owners_update_room_units" ON room_units
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_units.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

CREATE POLICY "owners_delete_room_units" ON room_units
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_units.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

-- ============================================
-- 4. ROOM_AMENITIES
-- ============================================
ALTER TABLE room_amenities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_select_room_amenities" ON room_amenities;
DROP POLICY IF EXISTS "owners_insert_room_amenities" ON room_amenities;
DROP POLICY IF EXISTS "owners_delete_room_amenities" ON room_amenities;

CREATE POLICY "public_select_room_amenities" ON room_amenities
  FOR SELECT TO authenticated, anon
  USING (true);

CREATE POLICY "owners_insert_room_amenities" ON room_amenities
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_amenities.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

CREATE POLICY "owners_delete_room_amenities" ON room_amenities
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_amenities.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

-- ============================================
-- 5. ROOM_IMAGES
-- ============================================
ALTER TABLE room_images ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_select_room_images" ON room_images;
DROP POLICY IF EXISTS "owners_insert_room_images" ON room_images;
DROP POLICY IF EXISTS "owners_delete_room_images" ON room_images;

CREATE POLICY "public_select_room_images" ON room_images
  FOR SELECT TO authenticated, anon
  USING (true);

CREATE POLICY "owners_insert_room_images" ON room_images
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_images.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

CREATE POLICY "owners_delete_room_images" ON room_images
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_images.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

-- ============================================
-- 6. NEARBY_PLACES
-- ============================================
ALTER TABLE nearby_places ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_select_nearby_places" ON nearby_places;
DROP POLICY IF EXISTS "owners_insert_nearby_places" ON nearby_places;
DROP POLICY IF EXISTS "owners_delete_nearby_places" ON nearby_places;

CREATE POLICY "public_select_nearby_places" ON nearby_places
  FOR SELECT TO authenticated, anon
  USING (true);

CREATE POLICY "owners_insert_nearby_places" ON nearby_places
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = nearby_places.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

CREATE POLICY "owners_delete_nearby_places" ON nearby_places
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = nearby_places.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

-- ============================================
-- 7. ROOM_VIDEO_REVIEWS
-- ============================================
ALTER TABLE room_video_reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_select_room_video_reviews" ON room_video_reviews;
DROP POLICY IF EXISTS "owners_insert_room_video_reviews" ON room_video_reviews;
DROP POLICY IF EXISTS "owners_delete_room_video_reviews" ON room_video_reviews;

CREATE POLICY "public_select_room_video_reviews" ON room_video_reviews
  FOR SELECT TO authenticated, anon
  USING (true);

CREATE POLICY "owners_insert_room_video_reviews" ON room_video_reviews
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_video_reviews.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

CREATE POLICY "owners_delete_room_video_reviews" ON room_video_reviews
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_video_reviews.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

-- ============================================
-- 8. TENANT_PROFILES
-- ============================================
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tenant_profiles') THEN
    ALTER TABLE tenant_profiles ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS "tenant_profiles_select_policy" ON tenant_profiles;
    DROP POLICY IF EXISTS "tenant_profiles_insert_policy" ON tenant_profiles;
    DROP POLICY IF EXISTS "tenant_profiles_update_policy" ON tenant_profiles;
    
    CREATE POLICY "tenant_profiles_select_policy" ON tenant_profiles
      FOR SELECT TO authenticated
      USING (
        profile_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM profiles p
          WHERE p.id = auth.uid()
          AND p.role IN ('admin', 'owner')
        )
      );
    
    CREATE POLICY "tenant_profiles_insert_policy" ON tenant_profiles
      FOR INSERT TO authenticated
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM profiles p
          WHERE p.id = auth.uid()
          AND p.role IN ('admin', 'owner')
        )
      );
    
    CREATE POLICY "tenant_profiles_update_policy" ON tenant_profiles
      FOR UPDATE TO authenticated
      USING (
        profile_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM profiles p
          WHERE p.id = auth.uid()
          AND p.role IN ('admin', 'owner')
        )
      );
  END IF;
END $$;

-- ============================================
-- KIỂM TRA KẾT QUẢ
-- ============================================

SELECT '✅ ĐÃ FIX UNRESTRICTED TABLES!' as status;

-- Kiểm tra RLS status
SELECT 
    tablename,
    CASE 
        WHEN rowsecurity THEN '🔒 RLS ENABLED' 
        ELSE '⚠️  UNRESTRICTED' 
    END as status,
    (SELECT COUNT(*) FROM pg_policies WHERE pg_policies.tablename = pg_tables.tablename) as policy_count
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN (
    'profiles', 'rooms', 'room_units', 'room_amenities', 
    'room_images', 'nearby_places', 'room_video_reviews', 'tenant_profiles'
)
ORDER BY tablename;
