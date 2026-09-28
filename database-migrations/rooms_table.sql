-- Create rooms table with RLS policies
-- Run this in your Supabase SQL Editor

-- Create rooms table if not exists
CREATE TABLE IF NOT EXISTS public.rooms (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL,
    area NUMERIC,
    address TEXT NOT NULL,
    city TEXT,
    district TEXT,
    ward TEXT,
    status TEXT DEFAULT 'available' CHECK (status IN ('available', 'rented', 'hidden')),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    banner TEXT,
    maps TEXT
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_rooms_owner_id ON public.rooms(owner_id);
CREATE INDEX IF NOT EXISTS idx_rooms_status ON public.rooms(status);
CREATE INDEX IF NOT EXISTS idx_rooms_city ON public.rooms(city);
CREATE INDEX IF NOT EXISTS idx_rooms_district ON public.rooms(district);
CREATE INDEX IF NOT EXISTS idx_rooms_ward ON public.rooms(ward);
CREATE INDEX IF NOT EXISTS idx_rooms_created_at ON public.rooms(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_rooms_price ON public.rooms(price);

-- Enable Row Level Security
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view available rooms
CREATE POLICY "Anyone can view available rooms"
    ON public.rooms FOR SELECT
    USING (status = 'available' OR auth.uid() = owner_id);

-- Policy: Authenticated users can create rooms
CREATE POLICY "Authenticated users can create rooms"
    ON public.rooms FOR INSERT
    WITH CHECK (
        auth.uid() = owner_id
        AND auth.role() = 'authenticated'
    );

-- Policy: Room owners can update their own rooms
CREATE POLICY "Room owners can update their own rooms"
    ON public.rooms FOR UPDATE
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

-- Policy: Room owners can delete their own rooms
CREATE POLICY "Room owners can delete their own rooms"
    ON public.rooms FOR DELETE
    USING (auth.uid() = owner_id);

-- Policy: Admins can do everything with rooms
CREATE POLICY "Admins can manage all rooms"
    ON public.rooms FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid()
            AND profiles.role = 'admin'
        )
    );

-- Grant permissions
GRANT ALL ON public.rooms TO authenticated;
GRANT SELECT ON public.rooms TO anon;

-- Comments for documentation
COMMENT ON TABLE public.rooms IS 'Stores room rental listings';
COMMENT ON COLUMN public.rooms.owner_id IS 'User who owns this room';
COMMENT ON COLUMN public.rooms.title IS 'Room title/name';
COMMENT ON COLUMN public.rooms.price IS 'Monthly rental price';
COMMENT ON COLUMN public.rooms.area IS 'Room area in square meters';
COMMENT ON COLUMN public.rooms.status IS 'Room availability status';
