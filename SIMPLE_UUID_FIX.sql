-- Chỉ cần chạy 2 lệnh này:

-- 1. Xóa foreign key constraint
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- 2. Đặt default UUID
ALTER TABLE profiles ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- Kiểm tra
SELECT column_name, column_default 
FROM information_schema.columns 
WHERE table_name = 'profiles' AND column_name = 'id';
