-- Add `is_hot` flag to rooms so admins can curate the
-- "Lựa chọn chỗ ở HOT" section on the home page.
-- Run this in the Supabase SQL Editor.

ALTER TABLE public.rooms
    ADD COLUMN IF NOT EXISTS is_hot BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN public.rooms.is_hot IS
    'If true, this room is pinned to the "HOT" section on the home page (curated by admin).';

-- Partial index: speeds up filtering WHERE is_hot = true AND status = 'available'
CREATE INDEX IF NOT EXISTS idx_rooms_is_hot_available
    ON public.rooms (created_at DESC)
    WHERE is_hot = TRUE AND status = 'available';
