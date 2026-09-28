-- Allow public to view images for reserved rooms (available + reserved + rented; exclude hidden)
-- Run this in your Supabase SQL Editor.

ALTER TABLE IF EXISTS public.room_images ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view room images" ON public.room_images;

CREATE POLICY "Anyone can view room images"
ON public.room_images
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.rooms
    WHERE rooms.id = room_images.room_id
      AND (rooms.status IN ('available', 'reserved', 'rented') OR rooms.owner_id = auth.uid())
  )
);

