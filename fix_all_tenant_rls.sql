-- Fix ALL RLS Policies for Add Tenant Feature
-- Run this ONCE in Supabase SQL Editor to fix all issues

-- ============================================
-- 1. PROFILES TABLE - Allow owners to create renters
-- ============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Owners can create renter profiles" ON profiles;
DROP POLICY IF EXISTS "Owners can read renter profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can do everything on profiles" ON profiles;

-- Users can read their own profile
CREATE POLICY "Users can read own profile" ON profiles
  FOR SELECT TO authenticated
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Owners can create renter profiles
CREATE POLICY "Owners can create renter profiles" ON profiles
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role = 'owner'
    )
    AND role = 'renter'
  );

-- Owners can read renter profiles
CREATE POLICY "Owners can read renter profiles" ON profiles
  FOR SELECT TO authenticated
  USING (
    auth.uid() = id
    OR (
      EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid()
        AND p.role = 'owner'
      )
      AND role = 'renter'
    )
  );

-- Admins can do everything
CREATE POLICY "Admins can do everything on profiles" ON profiles
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role = 'admin'
    )
  );

-- ============================================
-- 2. TENANT_PROFILES TABLE - Allow owners to create/read
-- ============================================

ALTER TABLE tenant_profiles ENABLE ROW LEVEL SECURITY;

-- Add columns if not exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tenant_profiles' AND column_name = 'metadata'
  ) THEN
    ALTER TABLE tenant_profiles ADD COLUMN metadata JSONB;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tenant_profiles' AND column_name = 'id_card_issue_date'
  ) THEN
    ALTER TABLE tenant_profiles ADD COLUMN id_card_issue_date DATE;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tenant_profiles' AND column_name = 'id_card_issue_place'
  ) THEN
    ALTER TABLE tenant_profiles ADD COLUMN id_card_issue_place TEXT;
  END IF;
END $$;

DROP POLICY IF EXISTS "owners_insert_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "owners_update_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "owners_select_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "tenants_select_own_profile" ON tenant_profiles;

-- Owners can INSERT tenant profiles
CREATE POLICY "owners_insert_tenant_profiles" ON tenant_profiles
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role IN ('owner', 'admin')
    )
  );

-- Owners can UPDATE tenant profiles
CREATE POLICY "owners_update_tenant_profiles" ON tenant_profiles
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role IN ('owner', 'admin')
    )
  );

-- Owners can SELECT tenant profiles
CREATE POLICY "owners_select_tenant_profiles" ON tenant_profiles
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role IN ('owner', 'admin')
    )
    OR tenant_profiles.profile_id = auth.uid()
  );

-- Tenants can view their own profile
CREATE POLICY "tenants_select_own_profile" ON tenant_profiles
  FOR SELECT TO authenticated
  USING (tenant_profiles.profile_id = auth.uid());

-- ============================================
-- 3. STORAGE BUCKET - Create id-cards bucket
-- ============================================

-- Create bucket if not exists
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'id-cards',
  'id-cards',
  false,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
DROP POLICY IF EXISTS "Allow authenticated upload id cards" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated read id cards" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated delete id cards" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated update id cards" ON storage.objects;

CREATE POLICY "Allow authenticated upload id cards"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'id-cards');

CREATE POLICY "Allow authenticated read id cards"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'id-cards');

CREATE POLICY "Allow authenticated delete id cards"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'id-cards');

CREATE POLICY "Allow authenticated update id cards"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'id-cards')
WITH CHECK (bucket_id = 'id-cards');

-- ============================================
-- 4. VERIFY EVERYTHING
-- ============================================

-- Check profiles policies
SELECT 'PROFILES POLICIES:' as info;
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'profiles' ORDER BY policyname;

-- Check tenant_profiles policies
SELECT 'TENANT_PROFILES POLICIES:' as info;
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'tenant_profiles' ORDER BY policyname;

-- Check storage policies
SELECT 'STORAGE POLICIES:' as info;
SELECT policyname, cmd FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname LIKE '%id cards%'
ORDER BY policyname;

-- Check bucket
SELECT 'STORAGE BUCKET:' as info;
SELECT id, name, public, file_size_limit FROM storage.buckets WHERE id = 'id-cards';

-- Check tenant_profiles columns
SELECT 'TENANT_PROFILES COLUMNS:' as info;
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'tenant_profiles' 
AND column_name IN ('metadata', 'id_card_issue_date', 'id_card_issue_place')
ORDER BY column_name;

-- Check current user
SELECT 'CURRENT USER:' as info;
SELECT id, name, role FROM profiles WHERE id = auth.uid();

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT '✅ ALL POLICIES CREATED SUCCESSFULLY!' as status;
SELECT 'You can now add tenants without RLS errors' as message;
