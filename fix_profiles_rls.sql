-- Fix RLS Policies for profiles table to allow owners to create renters
-- Run this in Supabase SQL Editor

-- ============================================
-- PROFILES TABLE RLS POLICIES
-- ============================================

-- Enable RLS on profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Owners can create renter profiles" ON profiles;
DROP POLICY IF EXISTS "Owners can read renter profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can do everything" ON profiles;

-- Policy 1: Users can read their own profile
CREATE POLICY "Users can read own profile" ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Policy 2: Users can update their own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Policy 3: Owners can create renter profiles
CREATE POLICY "Owners can create renter profiles" ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (
    -- Allow if the user creating is an owner
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role = 'owner'
    )
    -- And the profile being created is a renter
    AND role = 'renter'
  );

-- Policy 4: Owners can read renter profiles (their tenants)
CREATE POLICY "Owners can read renter profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    -- Allow if user is reading their own profile
    auth.uid() = id
    OR
    -- Or if user is owner and profile is a renter with contract
    (
      EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid()
        AND p.role = 'owner'
      )
      AND role = 'renter'
    )
  );

-- Policy 5: Admins can do everything
CREATE POLICY "Admins can do everything" ON profiles
  FOR ALL
  TO authenticated
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
-- VERIFY POLICIES
-- ============================================

-- Check policies for profiles table
SELECT 
  policyname,
  cmd,
  roles,
  permissive
FROM pg_policies
WHERE tablename = 'profiles'
ORDER BY policyname;

-- Check current user's role
SELECT id, name, role FROM profiles WHERE id = auth.uid();

-- ============================================
-- EXPECTED RESULTS:
-- ============================================
-- Should see 5 policies:
-- 1. Users can read own profile (SELECT)
-- 2. Users can update own profile (UPDATE)
-- 3. Owners can create renter profiles (INSERT)
-- 4. Owners can read renter profiles (SELECT)
-- 5. Admins can do everything (ALL)
--
-- Current user should have role = 'owner'
