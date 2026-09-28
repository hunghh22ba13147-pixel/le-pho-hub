-- Setup Storage Bucket for ID Cards
-- Run this in Supabase SQL Editor or Dashboard

-- ============================================
-- 1. CREATE STORAGE BUCKET (if not exists)
-- ============================================
-- Go to Storage → Create bucket → Name: "id-cards" → Public: Yes

-- ============================================
-- 2. STORAGE BUCKET POLICIES
-- ============================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow authenticated upload id cards" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read id cards" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated delete id cards" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated update id cards" ON storage.objects;

-- Policy 1: Allow authenticated users to upload to id-cards bucket
CREATE POLICY "Allow authenticated upload id cards"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'id-cards');

-- Policy 2: Allow authenticated users to view images in id-cards bucket
-- Note: ID cards should NOT be public, only authenticated users can view
CREATE POLICY "Allow authenticated read id cards"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'id-cards');

-- Policy 3: Allow authenticated users to delete their own uploads
CREATE POLICY "Allow authenticated delete id cards"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'id-cards');

-- Policy 4: Allow authenticated users to update their own uploads
CREATE POLICY "Allow authenticated update id cards"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'id-cards')
WITH CHECK (bucket_id = 'id-cards');

-- ============================================
-- 3. UPDATE TENANT_PROFILES TABLE (if needed)
-- ============================================

-- Add metadata column if not exists (for storing additional info like gender, occupation)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tenant_profiles' 
    AND column_name = 'metadata'
  ) THEN
    ALTER TABLE tenant_profiles ADD COLUMN metadata JSONB;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tenant_profiles' 
    AND column_name = 'id_card_issue_date'
  ) THEN
    ALTER TABLE tenant_profiles ADD COLUMN id_card_issue_date DATE;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tenant_profiles' 
    AND column_name = 'id_card_issue_place'
  ) THEN
    ALTER TABLE tenant_profiles ADD COLUMN id_card_issue_place TEXT;
  END IF;
END $$;

-- ============================================
-- 4. RLS POLICIES FOR TENANT_PROFILES
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "owners_insert_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "owners_update_tenant_profiles" ON tenant_profiles;
DROP POLICY IF EXISTS "owners_select_tenant_profiles" ON tenant_profiles;

-- Enable RLS
ALTER TABLE tenant_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Owners can INSERT tenant profiles for their tenants
CREATE POLICY "owners_insert_tenant_profiles" ON tenant_profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (
    -- Allow if the profile_id is a renter
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = tenant_profiles.profile_id
      AND profiles.role = 'renter'
    )
  );

-- Policy: Owners can UPDATE tenant profiles for their tenants
CREATE POLICY "owners_update_tenant_profiles" ON tenant_profiles
  FOR UPDATE
  TO authenticated
  USING (
    -- Allow if user is owner and tenant has contract with owner's room
    EXISTS (
      SELECT 1 FROM contracts c
      INNER JOIN room_units ru ON c.room_unit_id = ru.id
      INNER JOIN rooms r ON ru.room_id = r.id
      WHERE c.renter_id = tenant_profiles.profile_id
      AND r.owner_id = auth.uid()
    )
    OR
    -- Or if user is admin
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Policy: Owners can SELECT tenant profiles for their tenants
CREATE POLICY "owners_select_tenant_profiles" ON tenant_profiles
  FOR SELECT
  TO authenticated
  USING (
    -- Allow if user is owner and tenant has contract with owner's room
    EXISTS (
      SELECT 1 FROM contracts c
      INNER JOIN room_units ru ON c.room_unit_id = ru.id
      INNER JOIN rooms r ON ru.room_id = r.id
      WHERE c.renter_id = tenant_profiles.profile_id
      AND r.owner_id = auth.uid()
    )
    OR
    -- Or if user is admin
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR
    -- Or if user is the tenant themselves
    tenant_profiles.profile_id = auth.uid()
  );

-- ============================================
-- 5. VERIFY SETUP
-- ============================================

-- Check storage policies
SELECT 
  policyname,
  cmd
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
AND policyname LIKE '%id cards%';

-- Check tenant_profiles policies
SELECT 
  policyname,
  cmd
FROM pg_policies 
WHERE tablename = 'tenant_profiles';

-- Check tenant_profiles columns
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tenant_profiles'
ORDER BY ordinal_position;

-- ============================================
-- EXPECTED RESULTS:
-- ============================================
-- Storage policies:
-- - Allow authenticated upload id cards (INSERT)
-- - Allow authenticated read id cards (SELECT)
-- - Allow authenticated delete id cards (DELETE)
-- - Allow authenticated update id cards (UPDATE)
--
-- Tenant profiles policies:
-- - owners_insert_tenant_profiles (INSERT)
-- - owners_update_tenant_profiles (UPDATE)
-- - owners_select_tenant_profiles (SELECT)
--
-- Tenant profiles columns should include:
-- - metadata (jsonb)
-- - id_card_issue_date (date)
-- - id_card_issue_place (text)
