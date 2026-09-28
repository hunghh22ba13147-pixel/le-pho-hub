# 🔧 FIX LỖI UPLOAD ẢNH: "The database schema is invalid or incompatible"

## ❌ LỖI
```
Upload ảnh mặt trước thất bại: The database schema is invalid or incompatible.
```

## 🔍 NGUYÊN NHÂN
Lỗi này xảy ra khi:
1. Bucket `id-cards` chưa được tạo trong Supabase Storage
2. Supabase client cache chưa được refresh sau khi tạo bucket
3. Storage policies chưa được thiết lập đúng

## ✅ GIẢI PHÁP (Làm theo thứ tự)

### BƯỚC 1: Chạy SQL Script
1. Mở **Supabase Dashboard** → **SQL Editor**
2. Mở file `fix_all_tenant_rls.sql` 
3. Copy toàn bộ nội dung
4. Paste vào SQL Editor
5. Click **RUN** (hoặc Ctrl+Enter)
6. Đợi đến khi thấy thông báo: `✅ ALL POLICIES CREATED SUCCESSFULLY!`

### BƯỚC 2: Kiểm Tra Bucket Đã Được Tạo
1. Trong Supabase Dashboard → **Storage**
2. Kiểm tra có bucket tên `id-cards` chưa
3. Nếu chưa có, chạy lại BƯỚC 1

### BƯỚC 3: Refresh Supabase Client Cache
**QUAN TRỌNG:** Phải làm để clear cache!

**Cách 1: Hard Refresh Trình Duyệt**
- Windows/Linux: `Ctrl + Shift + R` hoặc `Ctrl + F5`
- Mac: `Cmd + Shift + R`

**Cách 2: Clear Cache Thủ Công**
- Mở DevTools (F12)
- Right-click vào nút Refresh
- Chọn "Empty Cache and Hard Reload"

**Cách 3: Đóng Tab và Mở Lại**
- Đóng hoàn toàn tab ứng dụng
- Mở tab mới và truy cập lại

### BƯỚC 4: Thử Lại Upload
1. Mở modal "Thêm khách thuê mới"
2. Điền thông tin
3. Chọn ảnh CCCD mặt trước
4. Click "Lưu thông tin"

## 🐛 NẾU VẪN LỖI

### Kiểm Tra Console Log
1. Mở DevTools (F12) → Tab **Console**
2. Xem log khi upload:
   - `Checking if bucket "id-cards" exists...`
   - `✓ Bucket "id-cards" exists`
   - `Upload attempt 1/3 to bucket: id-cards`

### Nếu Thấy "Bucket not found"
```sql
-- Chạy lệnh này trong Supabase SQL Editor để tạo bucket thủ công
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'id-cards',
  'id-cards',
  false,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp'];
```

### Nếu Vẫn Lỗi Schema
Đây là lỗi cache của Supabase. Giải pháp:

1. **Đợi 5-10 phút** để Supabase tự động refresh schema cache
2. **Hoặc** restart Supabase project:
   - Supabase Dashboard → Settings → General
   - Click "Pause project"
   - Đợi 1 phút
   - Click "Resume project"
3. **Sau đó** hard refresh trình duyệt (Ctrl+Shift+R)

## 📝 KIỂM TRA BUCKET VÀ POLICIES

Chạy các lệnh này trong SQL Editor để kiểm tra:

```sql
-- 1. Kiểm tra bucket tồn tại
SELECT id, name, public, file_size_limit 
FROM storage.buckets 
WHERE id = 'id-cards';

-- 2. Kiểm tra storage policies
SELECT policyname, cmd 
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects' 
  AND policyname LIKE '%id cards%';

-- 3. Kiểm tra user hiện tại
SELECT id, name, role 
FROM profiles 
WHERE id = auth.uid();
```

## 🎯 KẾT QUẢ MONG ĐỢI

Sau khi làm đúng các bước trên, bạn sẽ thấy trong Console:
```
Checking if bucket "id-cards" exists...
✓ Bucket "id-cards" exists
Upload attempt 1/3 to bucket: id-cards
✓ Upload successful on attempt 1
ID card front uploaded: https://...supabase.co/storage/v1/object/public/id-cards/...
```

Và modal sẽ hiển thị: **"Thêm khách thuê thành công!"**

## 📞 HỖ TRỢ

Nếu vẫn gặp lỗi sau khi làm tất cả các bước trên, cung cấp:
1. Screenshot console log (F12 → Console)
2. Kết quả của 3 câu lệnh SQL kiểm tra ở trên
3. Screenshot Storage buckets trong Supabase Dashboard
