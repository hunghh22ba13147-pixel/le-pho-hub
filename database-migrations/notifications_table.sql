-- Create notifications table for admin notification system
-- Run this in your Supabase SQL Editor

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('info', 'warning', 'success', 'error')),
    target_audience TEXT NOT NULL CHECK (target_audience IN ('all', 'renters', 'owners', 'admins')),
    is_active BOOLEAN DEFAULT true,
    created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_notifications_is_active ON public.notifications(is_active);
CREATE INDEX IF NOT EXISTS idx_notifications_target_audience ON public.notifications(target_audience);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_created_by ON public.notifications(created_by);

-- Enable Row Level Security (RLS)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Policy: Allow admins to do everything
CREATE POLICY "Admins can do everything with notifications"
ON public.notifications
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- Policy: Allow users to read active notifications meant for them
CREATE POLICY "Users can read active notifications for their role"
ON public.notifications
FOR SELECT
USING (
    is_active = true
    AND (
        target_audience = 'all'
        OR (
            target_audience = 'renters' 
            AND EXISTS (
                SELECT 1 FROM public.profiles
                WHERE profiles.id = auth.uid()
                AND profiles.role = 'renter'
            )
        )
        OR (
            target_audience = 'owners' 
            AND EXISTS (
                SELECT 1 FROM public.profiles
                WHERE profiles.id = auth.uid()
                AND profiles.role = 'owner'
            )
        )
        OR (
            target_audience = 'admins' 
            AND EXISTS (
                SELECT 1 FROM public.profiles
                WHERE profiles.id = auth.uid()
                AND profiles.role = 'admin'
            )
        )
    )
);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_notifications_updated_at ON public.notifications;
CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT ALL ON public.notifications TO authenticated;
GRANT SELECT ON public.notifications TO anon;

-- Insert sample notifications (optional - you can remove this if you don't want sample data)
INSERT INTO public.notifications (title, content, type, target_audience, is_active, created_by)
SELECT 
    'Chào mừng đến với hệ thống!',
    'Cảm ơn bạn đã sử dụng hệ thống quản lý phòng trọ của chúng tôi. Nếu có bất kỳ câu hỏi nào, vui lòng liên hệ với chúng tôi.',
    'info',
    'all',
    true,
    id
FROM auth.users
WHERE email IN (
    SELECT email FROM public.profiles WHERE role = 'admin' LIMIT 1
)
LIMIT 1;

-- Comments for documentation
COMMENT ON TABLE public.notifications IS 'Stores system notifications for users';
COMMENT ON COLUMN public.notifications.title IS 'Notification title';
COMMENT ON COLUMN public.notifications.content IS 'Notification content/message';
COMMENT ON COLUMN public.notifications.type IS 'Notification type: info, warning, success, or error';
COMMENT ON COLUMN public.notifications.target_audience IS 'Target audience: all, renters, owners, or admins';
COMMENT ON COLUMN public.notifications.is_active IS 'Whether the notification is currently active/visible';
COMMENT ON COLUMN public.notifications.created_by IS 'Admin user who created the notification';

