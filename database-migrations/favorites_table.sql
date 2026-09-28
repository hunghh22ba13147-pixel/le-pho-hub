-- Create favorites/wishlist table
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_user_room_favorite UNIQUE (user_id, room_id)
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_room_id ON public.favorites(room_id);
CREATE INDEX IF NOT EXISTS idx_favorites_created_at ON public.favorites(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own favorites
CREATE POLICY "Users can view their own favorites"
    ON public.favorites FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can add their own favorites
CREATE POLICY "Users can add their own favorites"
    ON public.favorites FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own favorites
CREATE POLICY "Users can delete their own favorites"
    ON public.favorites FOR DELETE
    USING (auth.uid() = user_id);

-- Add comment to table
COMMENT ON TABLE public.favorites IS 'User favorite/wishlist rooms';

-- Sample query to get user favorites with room details
-- SELECT 
--   f.*,
--   r.title,
--   r.price,
--   r.address
-- FROM favorites f
-- JOIN rooms r ON f.room_id = r.id
-- WHERE f.user_id = 'user-id'
-- ORDER BY f.created_at DESC;

