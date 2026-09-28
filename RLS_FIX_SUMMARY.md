# Tóm tắt Fix lỗi RLS "new row violates row-level security policy"

## 🔴 Vấn đề
Khi chủ trọ tạo nhà trọ mới, gặp lỗi:
```
Upload banner thất bại: new row violates row-level security policy
```

## ✅ Giải pháp (3 bước đơn giản)

### Bước 1: Chạy SQL Script
1. Mở **Supabase Dashboard** → **SQL Editor**
2. Copy toàn bộ file `fix_rls_policies.sql`
3. Paste và click **Run**

### Bước 2: Cấu hình Storage Policies
1. Vào **Storage** → **room-images** → **Policies**
2. Tạo 3 policies:

**Policy 1: Upload**
```sql
CREATE POLICY "Authenticated users can upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'room-images');
```

**Policy 2: View**
```sql
CREATE POLICY "Public can view images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'room-images');
```

**Policy 3: Delete**
```sql
CREATE POLICY "Users can delete their own images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'room-images' AND auth.uid()::text = owner);
```

### Bước 3: Kiểm tra Role
```sql
-- Kiểm tra role của user
SELECT id, name, role FROM profiles WHERE id = auth.uid();

-- Nếu role không phải 'owner', update:
UPDATE profiles SET role = 'owner' WHERE id = 'YOUR_USER_ID';
```

## 📁 Files đã tạo

1. **fix_rls_policies.sql** - SQL script để tạo tất cả RLS policies
2. **test_rls_policies.sql** - Script test để verify policies
3. **FIX_RLS_ERROR_GUIDE.md** - Hướng dẫn chi tiết đầy đủ
4. **src/utils/debugRLS.ts** - Debug utilities trong code
5. **RLS_FIX_SUMMARY.md** - File này (tóm tắt nhanh)

## 🧪 Test sau khi fix

### Test 1: Chạy test script
```sql
-- Copy và chạy file test_rls_policies.sql trong SQL Editor
-- Kiểm tra kết quả:
-- ✅ RLS Enabled = true cho tất cả tables
-- ✅ Có đầy đủ policies (INSERT, UPDATE, DELETE, SELECT)
-- ✅ User role = 'owner'
```

### Test 2: Test trong app
1. Đăng xuất và đăng nhập lại
2. Mở Console (F12)
3. Vào `/owner/properties/new`
4. Kiểm tra console log - sẽ thấy:
   ```
   🔍 RLS Debug Information
   Authentication: ✅ Authenticated
   Role: owner
   Can Insert Rooms: ✅ Yes
   ```
5. Thử tạo nhà trọ mới

### Test 3: Debug trong code
```javascript
// Trong browser console, chạy:
import { printRLSDebugInfo } from '@/utils/debugRLS';
await printRLSDebugInfo();
```

## 🔍 Debug Tools

### Console Logs
Khi vào trang tạo nhà trọ, code sẽ tự động:
- ✅ Kiểm tra permissions
- ✅ In debug info nếu có lỗi
- ✅ Hiển thị error message chi tiết

### Error Messages
Nếu gặp lỗi, alert sẽ hiển thị:
```
Không thể tạo nhà trọ: [lý do]

Vui lòng kiểm tra console để biết thêm chi tiết 
và xem file FIX_RLS_ERROR_GUIDE.md
```

## 📋 Checklist

- [ ] Chạy `fix_rls_policies.sql` trong Supabase SQL Editor
- [ ] Tạo 3 Storage policies cho bucket `room-images`
- [ ] Kiểm tra user role = 'owner' trong bảng profiles
- [ ] Chạy `test_rls_policies.sql` để verify
- [ ] Đăng xuất và đăng nhập lại
- [ ] Test tạo nhà trọ mới
- [ ] Kiểm tra console logs không có lỗi

## 🆘 Vẫn gặp lỗi?

### Kiểm tra nhanh:
```sql
-- 1. RLS có enabled không?
SELECT tablename, rowsecurity FROM pg_tables 
WHERE tablename = 'rooms';

-- 2. Policies có tồn tại không?
SELECT policyname FROM pg_policies 
WHERE tablename = 'rooms';

-- 3. Role của user là gì?
SELECT role FROM profiles WHERE id = auth.uid();

-- 4. User có authenticated không?
SELECT auth.uid(), auth.email();
```

### Xem chi tiết:
- **FIX_RLS_ERROR_GUIDE.md** - Hướng dẫn đầy đủ với troubleshooting
- Console logs - Debug info tự động
- Supabase Dashboard → Authentication → Users - Kiểm tra user info

## 📞 Support

Nếu vẫn gặp vấn đề, cung cấp:
1. ✅ Screenshot error message
2. ✅ Console logs (F12)
3. ✅ Kết quả của `test_rls_policies.sql`
4. ✅ User ID và role từ profiles table
5. ✅ Screenshot policies trong Supabase Dashboard

## 🎯 Kết quả mong đợi

Sau khi fix xong:
- ✅ Chủ trọ có thể tạo nhà trọ mới
- ✅ Upload banner và ảnh thành công
- ✅ Thêm amenities, universities, nearby places, videos
- ✅ Không có lỗi RLS
- ✅ Redirect về `/owner/properties` sau khi tạo thành công
