-- Create nearby_places table for room listings
CREATE TABLE IF NOT EXISTS public.nearby_places (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL, -- 'university', 'school', 'hospital', 'supermarket', 'mall', 'park', 'bus_stop', 'metro', 'restaurant', 'cafe', 'gym', 'other'
    distance_km DECIMAL(5,2) NOT NULL, -- Distance in kilometers (e.g., 2.5, 6.5)
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_nearby_places_room_id ON public.nearby_places(room_id);
CREATE INDEX IF NOT EXISTS idx_nearby_places_category ON public.nearby_places(category);
CREATE INDEX IF NOT EXISTS idx_nearby_places_distance ON public.nearby_places(distance_km);

-- Enable Row Level Security
ALTER TABLE public.nearby_places ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read nearby places
CREATE POLICY "Anyone can view nearby places"
    ON public.nearby_places FOR SELECT
    USING (true);

-- Policy: Authenticated users can insert nearby places for their own rooms
CREATE POLICY "Users can create nearby places for their rooms"
    ON public.nearby_places FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.rooms
            WHERE rooms.id = nearby_places.room_id
            AND rooms.owner_id = auth.uid()
        )
    );

-- Policy: Users can update nearby places for their own rooms
CREATE POLICY "Users can update nearby places for their rooms"
    ON public.nearby_places FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.rooms
            WHERE rooms.id = nearby_places.room_id
            AND rooms.owner_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.rooms
            WHERE rooms.id = nearby_places.room_id
            AND rooms.owner_id = auth.uid()
        )
    );

-- Policy: Users can delete nearby places for their own rooms
CREATE POLICY "Users can delete nearby places for their rooms"
    ON public.nearby_places FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.rooms
            WHERE rooms.id = nearby_places.room_id
            AND rooms.owner_id = auth.uid()
        )
    );

-- Create trigger for updated_at
CREATE TRIGGER set_nearby_places_updated_at
    BEFORE UPDATE ON public.nearby_places
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Add comment to table
COMMENT ON TABLE public.nearby_places IS 'Nearby places and landmarks for room listings';

-- Sample data (optional - for testing)
-- INSERT INTO public.nearby_places (room_id, name, category, distance_km, description) VALUES
-- ('your-room-id', 'Đại học FPT', 'university', 2.5, 'Trường đại học công nghệ hàng đầu'),
-- ('your-room-id', 'Trường Đại học Công nghệ TP.HCM', 'university', 6.5, 'Trường đại học kỹ thuật'),
-- ('your-room-id', 'Siêu thị Co.opmart', 'supermarket', 0.8, 'Siêu thị lớn'),
-- ('your-room-id', 'Bệnh viện Đa khoa', 'hospital', 1.2, 'Bệnh viện đa khoa');

