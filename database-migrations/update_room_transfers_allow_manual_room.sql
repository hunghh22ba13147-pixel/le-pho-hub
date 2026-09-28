-- Update room_transfers table to allow users to post without owning a room
-- Make room_id nullable and add manual room info fields

ALTER TABLE public.room_transfers
ALTER COLUMN room_id DROP NOT NULL;

-- Add fields for manual room information
ALTER TABLE public.room_transfers
ADD COLUMN IF NOT EXISTS room_title TEXT,
ADD COLUMN IF NOT EXISTS room_price NUMERIC,
ADD COLUMN IF NOT EXISTS room_address TEXT,
ADD COLUMN IF NOT EXISTS room_area NUMERIC,
ADD COLUMN IF NOT EXISTS room_images TEXT[]; -- Array of image URLs

-- Add constraint: must have either room_id OR manual room info
ALTER TABLE public.room_transfers
ADD CONSTRAINT room_info_check CHECK (
  (room_id IS NOT NULL) OR 
  (room_title IS NOT NULL AND room_price IS NOT NULL AND room_address IS NOT NULL)
);

COMMENT ON COLUMN public.room_transfers.room_title IS 'Manual room title if room_id is null';
COMMENT ON COLUMN public.room_transfers.room_price IS 'Manual room price if room_id is null';
COMMENT ON COLUMN public.room_transfers.room_address IS 'Manual room address if room_id is null';
COMMENT ON COLUMN public.room_transfers.room_area IS 'Manual room area if room_id is null';
COMMENT ON COLUMN public.room_transfers.room_images IS 'Array of image URLs if room_id is null';






