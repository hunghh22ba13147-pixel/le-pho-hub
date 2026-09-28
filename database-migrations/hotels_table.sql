-- Create hotels table for motel/hotel listings
CREATE TABLE IF NOT EXISTS public.hotels (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    price_per_night NUMERIC NOT NULL,
    total_rooms INTEGER DEFAULT 1,
    address TEXT NOT NULL,
    city TEXT,
    district TEXT,
    ward TEXT,
    status TEXT DEFAULT 'available' CHECK (status IN ('available', 'full', 'hidden')),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    banner TEXT,
    maps TEXT,
    hotel_type TEXT DEFAULT 'motel' CHECK (hotel_type IN ('motel', 'hotel', 'resort', 'homestay'))
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_hotels_owner_id ON public.hotels(owner_id);
CREATE INDEX IF NOT EXISTS idx_hotels_status ON public.hotels(status);
CREATE INDEX IF NOT EXISTS idx_hotels_city ON public.hotels(city);
CREATE INDEX IF NOT EXISTS idx_hotels_district ON public.hotels(district);
CREATE INDEX IF NOT EXISTS idx_hotels_hotel_type ON public.hotels(hotel_type);
CREATE INDEX IF NOT EXISTS idx_hotels_created_at ON public.hotels(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.hotels ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view available hotels
CREATE POLICY "Anyone can view available hotels"
    ON public.hotels FOR SELECT
    USING (status = 'available' OR auth.uid() = owner_id);

-- Policy: Owners can insert their own hotels
CREATE POLICY "Owners can create hotels"
    ON public.hotels FOR INSERT
    WITH CHECK (auth.uid() = owner_id);

-- Policy: Owners can update their own hotels
CREATE POLICY "Owners can update their own hotels"
    ON public.hotels FOR UPDATE
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

-- Policy: Owners can delete their own hotels
CREATE POLICY "Owners can delete their own hotels"
    ON public.hotels FOR DELETE
    USING (auth.uid() = owner_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_hotel_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER set_hotel_updated_at
    BEFORE UPDATE ON public.hotels
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_hotel_updated_at();

-- Add comment to table
COMMENT ON TABLE public.hotels IS 'Hotel and motel listings';


