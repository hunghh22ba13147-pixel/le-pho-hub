-- Add 'reserved' to rooms.status check constraint
-- Run this in your Supabase SQL Editor.

ALTER TABLE public.rooms
  DROP CONSTRAINT IF EXISTS rooms_status_check;

ALTER TABLE public.rooms
  ADD CONSTRAINT rooms_status_check
  CHECK (status IN ('available', 'reserved', 'rented', 'hidden'));

