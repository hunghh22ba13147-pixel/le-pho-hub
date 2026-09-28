-- Create feedbacks/reviews table for room listings
CREATE TABLE IF NOT EXISTS public.feedbacks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT unique_user_room_feedback UNIQUE (room_id, user_id)
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_feedbacks_room_id ON public.feedbacks(room_id);
CREATE INDEX IF NOT EXISTS idx_feedbacks_user_id ON public.feedbacks(user_id);
CREATE INDEX IF NOT EXISTS idx_feedbacks_created_at ON public.feedbacks(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read feedbacks
CREATE POLICY "Anyone can view feedbacks"
    ON public.feedbacks FOR SELECT
    USING (true);

-- Policy: Authenticated users can insert their own feedbacks
CREATE POLICY "Users can create their own feedbacks"
    ON public.feedbacks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own feedbacks
CREATE POLICY "Users can update their own feedbacks"
    ON public.feedbacks FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own feedbacks
CREATE POLICY "Users can delete their own feedbacks"
    ON public.feedbacks FOR DELETE
    USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.feedbacks
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Add comment to table
COMMENT ON TABLE public.feedbacks IS 'User feedbacks and reviews for room listings';

