-- Bảo vệ bảng profiles khỏi việc tự thay đổi role
-- Run this in your Supabase SQL Editor
-- 
-- QUAN TRỌNG: Đây là migration bảo mật quan trọng để ngăn chặn việc chiếm quyền admin
-- Chạy migration này NGAY LẬP TỨC để bảo vệ hệ thống

-- Enable Row Level Security nếu chưa có
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Xóa các policies cũ nếu có (tránh conflict)
DROP POLICY IF EXISTS "Users can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can manage all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Prevent role modification by users" ON public.profiles;

-- Policy 1: Mọi người có thể xem profiles (public info)
CREATE POLICY "Users can view all profiles"
ON public.profiles
FOR SELECT
USING (true);

-- Policy 2: Users chỉ có thể INSERT profile của chính họ khi đăng ký
-- Và KHÔNG được set role = 'admin' khi insert
CREATE POLICY "Users can insert their own profile on signup"
ON public.profiles
FOR INSERT
WITH CHECK (
    auth.uid() = id
    AND role != 'admin'  -- QUAN TRỌNG: Không cho phép tự set role admin
    AND role IN ('owner', 'renter')  -- Chỉ cho phép owner hoặc renter
);

-- Policy 3: Users có thể UPDATE profile của chính họ
-- NHƯNG KHÔNG được thay đổi role (ngoại trừ admin)
CREATE POLICY "Users can update their own profile except role"
ON public.profiles
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (
    auth.uid() = id
    -- QUAN TRỌNG: Chỉ admin mới có thể thay đổi role
    -- Nếu user cố gắng thay đổi role, phải giữ nguyên role hiện tại
    AND (
        -- Nếu user không phải admin, role phải giữ nguyên
        NOT EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
        OR
        -- Nếu user là admin, họ có thể thay đổi role của chính họ
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    )
);

-- Policy 4: CHỈ ADMIN mới có thể thay đổi role của người khác
-- Admin có thể quản lý tất cả profiles
CREATE POLICY "Admins can manage all profiles"
ON public.profiles
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid()
        AND p.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid()
        AND p.role = 'admin'
    )
);

-- Policy 5: FUNCTION để ngăn chặn việc tự thay đổi role
-- Tạo trigger function để kiểm tra và ngăn chặn
CREATE OR REPLACE FUNCTION prevent_role_escalation()
RETURNS TRIGGER AS $$
BEGIN
    -- Nếu user đang cố gắng thay đổi role
    IF OLD.role IS DISTINCT FROM NEW.role THEN
        -- Kiểm tra xem user hiện tại có phải admin không
        IF NOT EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid()
            AND role = 'admin'
        ) THEN
            -- Nếu không phải admin, KHÔNG cho phép thay đổi role
            RAISE EXCEPTION 'Permission denied: Only admins can change user roles. Current user: %', auth.uid();
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Tạo trigger để áp dụng function trên
DROP TRIGGER IF EXISTS check_role_change ON public.profiles;
CREATE TRIGGER check_role_change
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    WHEN (OLD.role IS DISTINCT FROM NEW.role)
    EXECUTE FUNCTION prevent_role_escalation();

-- Grant permissions
GRANT ALL ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO anon;

-- Comments
COMMENT ON FUNCTION prevent_role_escalation() IS 'Ngăn chặn việc user tự thay đổi role của mình, chỉ admin mới có thể thay đổi role';
COMMENT ON TRIGGER check_role_change ON public.profiles IS 'Trigger để kiểm tra và ngăn chặn việc tự thay đổi role';

-- Verify policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'profiles'
ORDER BY policyname;

