-- Create hotel_images table for storing hotel photos
CREATE TABLE IF NOT EXISTS public.hotel_images (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    hotel_id UUID NOT NULL REFERENCES public.hotels(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_hotel_images_hotel_id ON public.hotel_images(hotel_id);

-- Enable Row Level Security
ALTER TABLE public.hotel_images ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view hotel images
CREATE POLICY "Anyone can view hotel images"
    ON public.hotel_images FOR SELECT
    USING (true);

-- Policy: Hotel owners can insert images for their hotels
CREATE POLICY "Hotel owners can insert images"
    ON public.hotel_images FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.hotels
            WHERE id = hotel_id AND owner_id = auth.uid()
        )
    );

-- Policy: Hotel owners can delete images for their hotels
CREATE POLICY "Hotel owners can delete images"
    ON public.hotel_images FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.hotels
            WHERE id = hotel_id AND owner_id = auth.uid()
        )
    );

-- Add comment to table
COMMENT ON TABLE public.hotel_images IS 'Images for hotel listings';






