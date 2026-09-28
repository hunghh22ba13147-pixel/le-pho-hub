-- ============================================
-- FIX RLS cho universities và room_universities
-- Cho phép public xem
-- ============================================

-- 1. Universities - cho phép TẤT CẢ xem
ALTER TABLE universities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_select_universities" ON universities;
DROP POLICY IF EXISTS "admin_all_universities" ON universities;

CREATE POLICY "public_select_universities" ON universities
  FOR SELECT TO authenticated, anon
  USING (true);

CREATE POLICY "admin_all_universities" ON universities
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role IN ('admin', 'owner')
    )
  );

-- 2. Room Universities - cho phép TẤT CẢ xem
ALTER TABLE room_universities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_select_room_universities" ON room_universities;
DROP POLICY IF EXISTS "owners_insert_room_universities" ON room_universities;
DROP POLICY IF EXISTS "owners_delete_room_universities" ON room_universities;

CREATE POLICY "public_select_room_universities" ON room_universities
  FOR SELECT TO authenticated, anon
  USING (true);

CREATE POLICY "owners_insert_room_universities" ON room_universities
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_universities.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

CREATE POLICY "owners_delete_room_universities" ON room_universities
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM rooms r
      JOIN profiles p ON p.id = auth.uid()
      WHERE r.id = room_universities.room_id
      AND (r.owner_id = auth.uid() OR p.role = 'admin')
    )
  );

-- Kiểm tra dữ liệu
SELECT '=== UNIVERSITIES ===' as info;
SELECT id, short_name, name FROM universities ORDER BY short_name;

SELECT '=== ROOM_UNIVERSITIES ===' as info;
SELECT COUNT(*) as total FROM room_universities;

SELECT '✅ ĐÃ FIX RLS UNIVERSITIES!' as status;
