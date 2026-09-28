-- ============================================
-- KHÔI PHỤC TOÀN BỘ RLS POLICIES
-- Script này sẽ khôi phục lại tất cả RLS policies
-- ============================================

-- ============================================
-- 1. PROFILES TABLE
-- ============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Xóa policies cũ
DROP POLICY IF EXISTS "allow_all_select_profiles" ON profiles;
DROP POLICY IF EXISTS "allow_all_insert_profiles" ON profiles;
DROP POLICY IF EXISTS "allow_all_update_profiles" ON profiles;
DROP POLICY IF EXISTS "allow_all_delete_profiles" ON profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Owners can create renter profiles" ON profiles;
DROP POLICY IF EXISTS "Owners can read renter profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can do everything on profiles" ON profiles;

-- Tạo policies mới - ĐƠN GIẢN và AN TOÀN
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
-- 2. ROOMS TABLE (Nhà trọ)
-- ============================================

ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "owners_select_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_insert_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_update_rooms" ON rooms;
DROP POLICY IF EXISTS "owners_delete_rooms" ON rooms;
DROP POLICY IF EXISTS "public_select_rooms" ON rooms;

-- Public có thể xem rooms
CREATE POLICY "public_select_rooms" ON rooms
  FOR SELECT TO authenticated, anon
  USING (true);

-- Owner và Admin có thể thêm/sửa/xóa
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
-- 3. ROOM_UNITS TABLE (Phòng)
-- ============================================

ALTER TABLE room_units ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "owners_select_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_insert_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_update_room_units" ON room_units;
DROP POLICY IF EXISTS "owners_delete_room_units" ON room_units;
DROP POLICY IF EXISTS "public_select_room_units" ON room_units;

-- Public có thể xem room_units
CREATE POLICY "public_select_room_units" ON room_units
  FOR SELECT TO authenticated, anon
  USING (true);

-- Owner và Admin có thể thêm/sửa/xóa
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
-- 4. ROOM_AMENITIES TABLE
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
-- 5. ROOM_IMAGES TABLE
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
-- 6. TENANT_PROFILES TABLE
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
-- 7. CONTRACTS TABLE (Kiểm tra cấu trúc trước)
-- ============================================

DO $$ 
BEGIN
  -- Chỉ tạo policies nếu bảng contracts tồn tại
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contracts') THEN
    ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS "owners_select_contracts" ON contracts;
    DROP POLICY IF EXISTS "owners_insert_contracts" ON contracts;
    DROP POLICY IF EXISTS "owners_update_contracts" ON contracts;
    DROP POLICY IF EXISTS "tenants_select_contracts" ON contracts;
    
    -- Policy đơn giản: Owner và Admin có thể làm mọi thứ
    CREATE POLICY "owners_select_contracts" ON contracts
      FOR SELECT TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM room_units ru
          JOIN rooms r ON r.id = ru.room_id
          WHERE ru.id = contracts.room_unit_id
          AND (r.owner_id = auth.uid() OR EXISTS (
            SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin'
          ))
        )
      );
    
    CREATE POLICY "owners_insert_contracts" ON contracts
      FOR INSERT TO authenticated
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM profiles p
          WHERE p.id = auth.uid()
          AND p.role IN ('admin', 'owner')
        )
      );
    
    CREATE POLICY "owners_update_contracts" ON contracts
      FOR UPDATE TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM profiles p
          WHERE p.id = auth.uid()
          AND p.role IN ('admin', 'owner')
        )
      );
  END IF;
END $$;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

SELECT '✅ KHÔI PHỤC THÀNH CÔNG!' as status;
SELECT 'Tất cả RLS policies đã được khôi phục. Bạn có thể login và sử dụng bình thường.' as message;

-- Kiểm tra
SELECT 'PROFILES:' as table_name, COUNT(*) as policy_count FROM pg_policies WHERE tablename = 'profiles'
UNION ALL
SELECT 'ROOMS:', COUNT(*) FROM pg_policies WHERE tablename = 'rooms'
UNION ALL
SELECT 'ROOM_UNITS:', COUNT(*) FROM pg_policies WHERE tablename = 'room_units'
UNION ALL
SELECT 'TENANT_PROFILES:', COUNT(*) FROM pg_policies WHERE tablename = 'tenant_profiles'
UNION ALL
SELECT 'CONTRACTS:', COUNT(*) FROM pg_policies WHERE tablename = 'contracts';
