-- Create room_transfers table for room pass/transfer posts
CREATE TABLE IF NOT EXISTS public.room_transfers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    reason TEXT,
    contact_phone TEXT,
    contact_zalo TEXT,
    transfer_date DATE,
    price_negotiable BOOLEAN DEFAULT true,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    approved_by UUID REFERENCES public.profiles(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_room_transfers_room_id ON public.room_transfers(room_id);
CREATE INDEX IF NOT EXISTS idx_room_transfers_user_id ON public.room_transfers(user_id);
CREATE INDEX IF NOT EXISTS idx_room_transfers_status ON public.room_transfers(status);
CREATE INDEX IF NOT EXISTS idx_room_transfers_created_at ON public.room_transfers(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.room_transfers ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view approved transfers
CREATE POLICY "Anyone can view approved transfers"
    ON public.room_transfers FOR SELECT
    USING (status = 'approved' OR auth.uid() = user_id);

-- Policy: Authenticated users can create their own transfers
CREATE POLICY "Users can create transfers"
    ON public.room_transfers FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own pending transfers
CREATE POLICY "Users can update their own pending transfers"
    ON public.room_transfers FOR UPDATE
    USING (auth.uid() = user_id AND status = 'pending')
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own pending transfers
CREATE POLICY "Users can delete their own pending transfers"
    ON public.room_transfers FOR DELETE
    USING (auth.uid() = user_id AND status = 'pending');

-- Policy: Admins can view all transfers
CREATE POLICY "Admins can view all transfers"
    ON public.room_transfers FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Policy: Admins can update any transfer (for approval/rejection)
CREATE POLICY "Admins can update transfers"
    ON public.room_transfers FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_room_transfer_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER set_room_transfer_updated_at
    BEFORE UPDATE ON public.room_transfers
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_room_transfer_updated_at();

-- Add comment to table
COMMENT ON TABLE public.room_transfers IS 'Room transfer/pass posts requiring admin approval';






