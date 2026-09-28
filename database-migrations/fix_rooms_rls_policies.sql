-- Fix RLS policies for rooms table
-- Run this in your Supabase SQL Editor

-- Enable Row Level Security if not already enabled
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Anyone can view available rooms" ON public.rooms;
DROP POLICY IF EXISTS "Authenticated users can create rooms" ON public.rooms;
DROP POLICY IF EXISTS "Room owners can update their own rooms" ON public.rooms;
DROP POLICY IF EXISTS "Room owners can delete their own rooms" ON public.rooms;
DROP POLICY IF EXISTS "Admins can manage all rooms" ON public.rooms;

-- Policy: Anyone can view available rooms
CREATE POLICY "Anyone can view available rooms"
    ON public.rooms FOR SELECT
    USING (status = 'available' OR auth.uid() = owner_id);

-- Policy: Authenticated users can create rooms
CREATE POLICY "Authenticated users can create rooms"
    ON public.rooms FOR INSERT
    WITH CHECK (
        auth.uid() = owner_id
        AND auth.role() = 'authenticated'
    );

-- Policy: Room owners can update their own rooms
CREATE POLICY "Room owners can update their own rooms"
    ON public.rooms FOR UPDATE
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

-- Policy: Room owners can delete their own rooms
CREATE POLICY "Room owners can delete their own rooms"
    ON public.rooms FOR DELETE
    USING (auth.uid() = owner_id);

-- Policy: Admins can do everything with rooms
CREATE POLICY "Admins can manage all rooms"
    ON public.rooms FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid()
            AND profiles.role = 'admin'
        )
    );

-- Grant permissions
GRANT ALL ON public.rooms TO authenticated;
GRANT SELECT ON public.rooms TO anon;

-- Verify policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'rooms';
