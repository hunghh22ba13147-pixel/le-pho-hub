-- Allow public to view images for rented rooms (still exclude hidden)
-- Run this in your Supabase SQL Editor.

ALTER TABLE IF EXISTS public.room_images ENABLE ROW LEVEL SECURITY;

-- Replace old policy (previously only allowed available rooms)
DROP POLICY IF EXISTS "Anyone can view room images" ON public.room_images;

CREATE POLICY "Anyone can view room images"
ON public.room_images
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.rooms
    WHERE rooms.id = room_images.room_id
      AND (rooms.status IN ('available', 'rented') OR rooms.owner_id = auth.uid())
  )
);

