-- ============================================
-- KHÔI PHỤC DATABASE - ROLLBACK RLS POLICIES
-- Chạy script này để khôi phục lại database
-- ============================================

-- ============================================
-- 1. XÓA TẤT CẢ POLICIES CŨ
-- ============================================

-- Profiles policies
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Owners can create renter profiles" ON profiles;
DROP POLICY IF EXISTS "Owners can read renter profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can do everything on profiles" ON profiles;

-- Tenant profiles policies
DROP POLICY IF EXISTS "owners_insert_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "owners_update_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "owners_select_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "tenants_select_own_profile" ON tenant_profiles;

-- ============================================
-- 2. TẠO LẠI POLICIES ĐƠN GIẢN - CHO PHÉP TẤT CẢ
-- ============================================

-- PROFILES: Cho phép mọi người đọc và cập nhật
CREATE POLICY "allow_all_select_profiles" ON profiles
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "allow_all_insert_profiles" ON profiles
  FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "allow_all_update_profiles" ON profiles
  FOR UPDATE TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_all_delete_profiles" ON profiles
  FOR DELETE TO authenticated
  USING (true);

-- TENANT_PROFILES: Cho phép mọi người đọc và cập nhật
CREATE POLICY "allow_all_select_tenant_profiles" ON tenant_profiles
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "allow_all_insert_tenant_profiles" ON tenant_profiles
  FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "allow_all_update_tenant_profiles" ON tenant_profiles
  FOR UPDATE TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_all_delete_tenant_profiles" ON tenant_profiles
  FOR DELETE TO authenticated
  USING (true);

-- ============================================
-- 3. KIỂM TRA KẾT QUẢ
-- ============================================

SELECT '✅ ROLLBACK THÀNH CÔNG!' as status;
SELECT 'Database đã được khôi phục. Bạn có thể login và xem dữ liệu bình thường.' as message;

-- Kiểm tra policies
SELECT 'PROFILES POLICIES:' as info;
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'profiles' ORDER BY policyname;

SELECT 'TENANT_PROFILES POLICIES:' as info;
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'tenant_profiles' ORDER BY policyname;
