-- ============================================
-- KHẨN CẤP: TẮT RLS ĐỂ KHÔI PHỤC NGAY
-- Chạy script này để TẮT RLS và xem lại dữ liệu
-- ============================================

-- TẮT RLS cho tất cả các bảng
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE rooms DISABLE ROW LEVEL SECURITY;
ALTER TABLE room_units DISABLE ROW LEVEL SECURITY;
ALTER TABLE room_amenities DISABLE ROW LEVEL SECURITY;
ALTER TABLE room_images DISABLE ROW LEVEL SECURITY;
ALTER TABLE room_universities DISABLE ROW LEVEL SECURITY;
ALTER TABLE nearby_places DISABLE ROW LEVEL SECURITY;
ALTER TABLE room_video_reviews DISABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_profiles DISABLE ROW LEVEL SECURITY;

-- Xóa tất cả policies cũ
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT schemaname, tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
            r.policyname, r.schemaname, r.tablename);
    END LOOP;
END $$;

-- Kiểm tra
SELECT '✅ ĐÃ TẮT RLS!' as status;
SELECT 'Bây giờ bạn có thể đăng nhập và xem dữ liệu bình thường.' as message;
SELECT 'Refresh trang (Ctrl+Shift+R) và đăng nhập lại.' as instruction;

-- Kiểm tra RLS status
SELECT 
    tablename,
    CASE 
        WHEN rowsecurity THEN '🔒 RLS ENABLED' 
        ELSE '✅ RLS DISABLED' 
    END as status
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('profiles', 'rooms', 'room_units', 'tenant_profiles')
ORDER BY tablename;
