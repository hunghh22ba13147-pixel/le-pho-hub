-- Allow public to view rented rooms (still exclude hidden)
-- Run this in your Supabase SQL Editor.

ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

-- Replace old policy to include rented + available
DROP POLICY IF EXISTS "Anyone can view available rooms" ON public.rooms;

CREATE POLICY "Anyone can view available or rented rooms"
  ON public.rooms
  FOR SELECT
  USING (status IN ('available', 'rented') OR auth.uid() = owner_id);

