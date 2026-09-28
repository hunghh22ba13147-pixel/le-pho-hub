-- Create bookings table for room reservation system
-- Run this in your Supabase SQL Editor

-- Create bookings table
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    guests_count INTEGER NOT NULL DEFAULT 1,
    total_price DECIMAL(15, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    message TEXT,
    rejection_reason TEXT,
    approved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_bookings_room_id ON public.bookings(room_id);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_check_in_date ON public.bookings(check_in_date);
CREATE INDEX IF NOT EXISTS idx_bookings_check_out_date ON public.bookings(check_out_date);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON public.bookings(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own bookings
CREATE POLICY "Users can view their own bookings"
ON public.bookings
FOR SELECT
USING (
    auth.uid() = user_id
    OR EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
    OR EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = bookings.room_id
        AND rooms.owner_id = auth.uid()
    )
);

-- Policy: Users can create their own bookings
CREATE POLICY "Users can create bookings"
ON public.bookings
FOR INSERT
WITH CHECK (
    auth.uid() = user_id
);

-- Policy: Users can cancel their own pending bookings
CREATE POLICY "Users can cancel their own bookings"
ON public.bookings
FOR UPDATE
USING (
    auth.uid() = user_id
    AND status = 'pending'
)
WITH CHECK (
    status = 'cancelled'
);

-- Policy: Admins can do everything with bookings
CREATE POLICY "Admins can manage all bookings"
ON public.bookings
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- Policy: Room owners can update bookings for their rooms (approve/reject)
CREATE POLICY "Room owners can manage bookings for their rooms"
ON public.bookings
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = bookings.room_id
        AND rooms.owner_id = auth.uid()
    )
);

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_bookings_updated_at
    BEFORE UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT ALL ON public.bookings TO authenticated;
GRANT SELECT ON public.bookings TO anon;

-- Comments for documentation
COMMENT ON TABLE public.bookings IS 'Stores room booking/reservation information';
COMMENT ON COLUMN public.bookings.room_id IS 'Reference to the room being booked';
COMMENT ON COLUMN public.bookings.user_id IS 'User who made the booking';
COMMENT ON COLUMN public.bookings.check_in_date IS 'Check-in date for the booking';
COMMENT ON COLUMN public.bookings.check_out_date IS 'Check-out date for the booking';
COMMENT ON COLUMN public.bookings.guests_count IS 'Number of guests';
COMMENT ON COLUMN public.bookings.total_price IS 'Total price for the booking';
COMMENT ON COLUMN public.bookings.status IS 'Booking status: pending, approved, rejected, or cancelled';
COMMENT ON COLUMN public.bookings.message IS 'Message from the user when making the booking';
COMMENT ON COLUMN public.bookings.rejection_reason IS 'Reason for rejection if booking is rejected';
COMMENT ON COLUMN public.bookings.approved_by IS 'Admin or room owner who approved/rejected the booking';
COMMENT ON COLUMN public.bookings.approved_at IS 'Timestamp when booking was approved/rejected';

