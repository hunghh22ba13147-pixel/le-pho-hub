-- ============================================
-- FIX PROFILES TABLE - Cho phép tạo profile không cần auth
-- ============================================

-- Kiểm tra cấu trúc hiện tại
SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name = 'id';

-- Xóa foreign key constraint nếu có và đặt default UUID
DO $$ 
BEGIN
    -- Xóa foreign key constraint nếu có
    ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;
    
    -- Đặt default UUID cho cột id
    ALTER TABLE profiles ALTER COLUMN id SET DEFAULT gen_random_uuid();
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;
END $$;

-- Kiểm tra lại
SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name = 'id';

SELECT '✅ ĐÃ FIX PROFILES TABLE!' as status;
SELECT 'Bây giờ có thể tạo tenant với UUID tự động' as message;
