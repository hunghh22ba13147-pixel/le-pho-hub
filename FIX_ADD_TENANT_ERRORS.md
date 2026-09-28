# Fix lỗi khi thêm khách thuê

## Lỗi 1: "Bucket not found"

### Nguyên nhân
Bucket `id-cards` chưa được tạo trong Supabase Storage.

### Giải pháp

**Cách 1: Tạo qua UI (Khuyến nghị)**
1. Vào **Supabase Dashboard** → **Storage**
2. Click **New bucket**
3. Name: `id-cards`
4. Public: **Bỏ tick** (để private)
5. Click **Create bucket**

**Cách 2: Tạo bằng SQL**
1. Vào **SQL Editor**
2. Copy file `create_id_cards_bucket.sql`
3. Paste và **Run**

Sau đó chạy SQL để tạo policies:
```sql
CREATE POLICY "Allow authenticated upload id cards"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'id-cards');

CREATE POLICY "Allow authenticated read id cards"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'id-cards');

CREATE POLICY "Allow authenticated delete id cards"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'id-cards');

CREATE POLICY "Allow authenticated update id cards"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'id-cards')
WITH CHECK (bucket_id = 'id-cards');
```

---

## Lỗi 2: "Could not find the 'email' column"

### Nguyên nhân
Bảng `profiles` không có cột `email`.

### Giải pháp
✅ **Đã fix trong code!**

Email giờ được lưu vào `tenant_profiles.metadata` thay vì `profiles.email`.

**Không cần làm gì thêm.**

---

## Lỗi 3: "new row violates row-level security policy for table 'profiles'"

### Nguyên nhân
RLS policy của bảng `profiles` không cho phép owners tạo profile mới cho renters.

### Giải pháp
Chạy SQL:

```sql
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Allow owners to create renter profiles
DROP POLICY IF EXISTS "Owners can create renter profiles" ON profiles;
CREATE POLICY "Owners can create renter profiles" ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = auth.uid()
      AND p.role = 'owner'
    )
    AND role = 'renter'
  );

-- Allow owners to read renter profiles
DROP POLICY IF EXISTS "Owners can read renter profiles" ON profiles;
CREATE POLICY "Owners can read renter profiles" ON profiles
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = id
    OR
    (
      EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = auth.uid()
        AND p.role = 'owner'
      )
      AND role = 'renter'
    )
  );
```

**Hoặc chạy file:** `fix_profiles_rls.sql`

---

## Lỗi 4: "new row violates row-level security policy for table 'tenant_profiles'"

### Nguyên nhân
RLS policies chưa được tạo cho `tenant_profiles`.

### Giải pháp
Chạy SQL:

```sql
-- Enable RLS
ALTER TABLE tenant_profiles ENABLE ROW LEVEL SECURITY;

-- Allow INSERT
CREATE POLICY "owners_insert_tenant_profiles" ON tenant_profiles
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = tenant_profiles.profile_id
      AND profiles.role = 'renter'
    )
  );

-- Allow SELECT
CREATE POLICY "owners_select_tenant_profiles" ON tenant_profiles
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM contracts c
      INNER JOIN room_units ru ON c.room_unit_id = ru.id
      INNER JOIN rooms r ON ru.room_id = r.id
      WHERE c.renter_id = tenant_profiles.profile_id
      AND r.owner_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR tenant_profiles.profile_id = auth.uid()
  );
```

---

## Checklist Setup

### 1. Storage Bucket
- [ ] Tạo bucket `id-cards` (private)
- [ ] Tạo 4 storage policies (INSERT, SELECT, UPDATE, DELETE)

### 2. Database
- [ ] Chạy `setup_id_cards_storage.sql` để:
  - Thêm columns vào `tenant_profiles`
  - Tạo RLS policies

### 3. Test
- [ ] Thử thêm khách thuê mới
- [ ] Upload ảnh CCCD
- [ ] Kiểm tra data trong database
- [ ] Kiểm tra ảnh trong Storage

---

## Quick Fix Script

Chạy tất cả trong một lần:

```sql
-- 1. Create bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'id-cards',
  'id-cards',
  false,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 2. Storage policies
CREATE POLICY "Allow authenticated upload id cards"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'id-cards');

CREATE POLICY "Allow authenticated read id cards"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'id-cards');

CREATE POLICY "Allow authenticated delete id cards"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'id-cards');

CREATE POLICY "Allow authenticated update id cards"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'id-cards')
WITH CHECK (bucket_id = 'id-cards');

-- 3. Add columns to tenant_profiles
ALTER TABLE tenant_profiles 
ADD COLUMN IF NOT EXISTS metadata JSONB,
ADD COLUMN IF NOT EXISTS id_card_issue_date DATE,
ADD COLUMN IF NOT EXISTS id_card_issue_place TEXT;

-- 4. RLS policies for tenant_profiles
ALTER TABLE tenant_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "owners_insert_tenant_profiles" ON tenant_profiles;
CREATE POLICY "owners_insert_tenant_profiles" ON tenant_profiles
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = tenant_profiles.profile_id
      AND profiles.role = 'renter'
    )
  );

DROP POLICY IF EXISTS "owners_select_tenant_profiles" ON tenant_profiles;
CREATE POLICY "owners_select_tenant_profiles" ON tenant_profiles
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM contracts c
      INNER JOIN room_units ru ON c.room_unit_id = ru.id
      INNER JOIN rooms r ON ru.room_id = r.id
      WHERE c.renter_id = tenant_profiles.profile_id
      AND r.owner_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
    OR tenant_profiles.profile_id = auth.uid()
  );

-- 5. Verify
SELECT 'Bucket created' as status, * FROM storage.buckets WHERE id = 'id-cards';
SELECT 'Policies created' as status, policyname FROM pg_policies WHERE tablename = 'objects' AND policyname LIKE '%id cards%';
SELECT 'Columns added' as status, column_name FROM information_schema.columns WHERE table_name = 'tenant_profiles' AND column_name IN ('metadata', 'id_card_issue_date', 'id_card_issue_place');
```

---

## Verify Setup

```sql
-- Check bucket
SELECT id, name, public FROM storage.buckets WHERE id = 'id-cards';
-- Expected: id-cards, id-cards, false

-- Check storage policies
SELECT policyname FROM pg_policies 
WHERE schemaname = 'storage' AND policyname LIKE '%id cards%';
-- Expected: 4 policies

-- Check tenant_profiles columns
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'tenant_profiles' 
AND column_name IN ('metadata', 'id_card_issue_date', 'id_card_issue_place');
-- Expected: 3 columns

-- Check RLS policies
SELECT policyname FROM pg_policies WHERE tablename = 'tenant_profiles';
-- Expected: owners_insert_tenant_profiles, owners_select_tenant_profiles
```

---

## Đã fix trong code

✅ Email không còn insert vào `profiles.email`
✅ Email được lưu vào `tenant_profiles.metadata.email`
✅ fetchOwnerTenants lấy email từ metadata

**Không cần sửa code gì thêm!**
