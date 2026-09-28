-- ============================================
-- KHÔI PHỤC ĐỠN GIẢN - CHỈ CÁC BẢNG CƠ BẢN
-- Chạy script này nếu RESTORE_ALL_RLS.sql bị lỗi
-- ============================================

-- ============================================
-- 1. PROFILES - Cho phép user đọc profile của mình
-- ============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Xóa tất cả policies cũ
DROP POLICY IF EXISTS "allow_all_select_profiles" ON profiles;
DROP POLICY IF EXISTS "allow_all_insert_profiles" ON profiles;
DROP POLICY IF EXISTS "allow_all_update_profiles" ON profiles;
DROP POLICY IF EXISTS "allow_all_delete_profiles" ON profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Owners can create renter profiles" ON profiles;
DROP POLICY IF EXISTS "Owners can read renter profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can do everything on profiles" ON profiles;
DROP POLICY IF EXISTS "profiles_select_policy" ON profiles;
DROP POLICY IF EXISTS "profiles_insert_policy" ON profiles;
DROP POLICY IF EXISTS "profiles_update_policy" ON profiles;

-- Tạo policies MỚI - ĐƠN GIẢN
CREATE POLICY "profiles_select_policy" ON profiles
  FOR SELECT TO authenticated
  USING (
    auth.uid() = id 
    OR EXISTS (
      SELECT 1 FROM profiles p 
      WHERE p.id = auth.uid() 
      AND p.role IN ('admin', 'owner')
    )
  );

CREATE POLICY "profiles_insert_policy" ON profiles
  FOR INSERT TO authenticated
  WITH CHECK (
    auth.uid() = id
    OR EXISTS (
      SELECT 1 FROM profiles p 
      WHERE p.id = auth.uid() 
      AND p.role IN ('admin', 'owner')
    )
  );

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
-- 2. ROOMS - Cho phép public xem, owner quản lý
-- ============================================

ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "owners_select_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_insert_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_update_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_delete_rooms" ON rooms;
DROP POLICY IF EXISTS "public_select_rooms" ON rooms;

CREATE POLICY "public_select_rooms" ON rooms
  FOR SELECT TO authenticated, anon
  USING (true);

CREATE POLICY "owners_insert_rooms" ON rooms
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role IN ('owner', 'admin')
    )
  );

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
-- 3. ROOM_UNITS - Cho phép public xem, owner quản lý
-- ============================================

ALTER TABLE room_units ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "owners_select_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_insert_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_update_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_delete_room_units" ON room_units;
DROP POLICY IF EXISTS "public_select_room_units" ON room_units;

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
-- 6. TENANT_PROFILES (KHÔNG TẠO POLICIES PHỨC TạP)
-- ============================================

ALTER TABLE tenant_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_all_select_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "allow_all_insert_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "allow_all_update_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "allow_all_delete_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "owners_insert_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "owners_update_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "owners_select_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "tenants_select_own_profile" ON tenant_profiles;
DROP POLICY IF EXISTS "tenant_profiles_select_policy" ON tenant_profiles;
DROP POLICY IF EXISTS "tenant_profiles_insert_policy" ON tenant_profiles;
DROP POLICY IF EXISTS "tenant_profiles_update_policy" ON tenant_profiles;

-- Cho phép owner và admin làm mọi thứ với tenant_profiles
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

-- ============================================
-- SUCCESS
-- ============================================

SELECT '✅ KHÔI PHỤC THÀNH CÔNG!' as status;
SELECT 'Database đã được khôi phục. Hãy refresh trang (Ctrl+Shift+R) và đăng nhập lại.' as message;

-- Kiểm tra policies
SELECT tablename, COUNT(*) as policy_count 
FROM pg_policies 
WHERE tablename IN ('profiles', 'rooms', 'room_units', 'room_amenities', 'room_images', 'tenant_profiles')
GROUP BY tablename
ORDER BY tablename;
