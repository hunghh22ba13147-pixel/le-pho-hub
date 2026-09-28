-- Allow public to view reserved rooms (available + reserved + rented; exclude hidden)
-- Run this in your Supabase SQL Editor.

ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view available or rented rooms" ON public.rooms;
DROP POLICY IF EXISTS "Anyone can view available rooms" ON public.rooms;

CREATE POLICY "Anyone can view available/reserved/rented rooms"
  ON public.rooms
  FOR SELECT
  USING (status IN ('available', 'reserved', 'rented') OR auth.uid() = owner_id);

