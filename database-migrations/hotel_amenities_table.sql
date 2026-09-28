-- Create hotel_amenities junction table
-- This table links hotels with amenities (reusing the amenities table)
CREATE TABLE IF NOT EXISTS public.hotel_amenities (
    hotel_id UUID NOT NULL REFERENCES public.hotels(id) ON DELETE CASCADE,
    amenity_id UUID NOT NULL REFERENCES public.amenities(id) ON DELETE CASCADE,
    CONSTRAINT hotel_amenities_pkey PRIMARY KEY (hotel_id, amenity_id)
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_hotel_amenities_hotel_id ON public.hotel_amenities(hotel_id);
CREATE INDEX IF NOT EXISTS idx_hotel_amenities_amenity_id ON public.hotel_amenities(amenity_id);

-- Enable Row Level Security
ALTER TABLE public.hotel_amenities ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view hotel amenities
CREATE POLICY "Anyone can view hotel amenities"
    ON public.hotel_amenities FOR SELECT
    USING (true);

-- Policy: Hotel owners can manage amenities for their hotels
CREATE POLICY "Hotel owners can manage amenities"
    ON public.hotel_amenities FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.hotels
            WHERE id = hotel_id AND owner_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.hotels
            WHERE id = hotel_id AND owner_id = auth.uid()
        )
    );

-- Add comment to table
COMMENT ON TABLE public.hotel_amenities IS 'Junction table linking hotels with amenities';






