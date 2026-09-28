# 🔧 Fix RLS Error - Complete Guide

## 📌 Quick Start (3 phút)

### Bước 1: SQL Script (1 phút)
```bash
1. Mở Supabase Dashboard → SQL Editor
2. Copy file: fix_rls_policies.sql
3. Paste và Run
```

### Bước 2: Storage Policies (1 phút)
```bash
1. Vào Storage → room-images → Policies
2. Tạo 3 policies (xem RLS_FIX_SUMMARY.md)
```

### Bước 3: Check Role (30 giây)
```sql
SELECT id, name, role FROM profiles WHERE id = auth.uid();
-- Nếu role != 'owner', chạy:
UPDATE profiles SET role = 'owner' WHERE id = 'YOUR_USER_ID';
```

### Bước 4: Test (30 giây)
```bash
1. Đăng xuất → Đăng nhập lại
2. Vào /owner/properties/new
3. Tạo nhà trọ mới
```

## 📚 Tài liệu

### 1. **RLS_FIX_SUMMARY.md** ⭐ BẮT ĐẦU TỪ ĐÂY
   - Tóm tắt nhanh 3 bước
   - Checklist đầy đủ
   - Quick troubleshooting

### 2. **FIX_RLS_ERROR_GUIDE.md** 📖 CHI TIẾT ĐẦY ĐỦ
   - Giải thích chi tiết từng bước
   - Troubleshooting section đầy đủ
   - Screenshots và examples

### 3. **fix_rls_policies.sql** 💾 SQL SCRIPT
   - Tạo tất cả RLS policies
   - Comments chi tiết
   - Copy và run trực tiếp

### 4. **test_rls_policies.sql** 🧪 TEST SCRIPT
   - Verify policies đã tạo đúng
   - Check permissions
   - Debug queries

### 5. **src/utils/debugRLS.ts** 🔍 DEBUG TOOLS
   - Functions để debug trong code
   - Auto-check permissions
   - Print debug info to console

## 🎯 Vấn đề và Giải pháp

### Vấn đề
```
Upload banner thất bại: new row violates row-level security policy
```

### Nguyên nhân
- ❌ RLS policies chưa được tạo cho owners
- ❌ Storage bucket policies chưa được cấu hình
- ❌ User role không phải 'owner'

### Giải pháp
- ✅ Tạo RLS policies cho tất cả tables
- ✅ Cấu hình Storage policies
- ✅ Verify user role

## 🛠️ Tools đã tạo

### 1. Debug Utilities
```typescript
import { printRLSDebugInfo, canUserCreateRooms } from '@/utils/debugRLS';

// Check permissions
const { can, reason } = await canUserCreateRooms();

// Print debug info
await printRLSDebugInfo();
```

### 2. Auto-check trong Code
Trang `/owner/properties/new` tự động:
- ✅ Check permissions khi load
- ✅ Print debug info nếu có lỗi
- ✅ Show detailed error messages

### 3. SQL Test Scripts
```sql
-- Test policies
\i test_rls_policies.sql

-- Fix policies
\i fix_rls_policies.sql
```

## 📋 Tables và Policies

### Tables cần RLS policies:
1. ✅ `rooms` - Nhà trọ chính
2. ✅ `room_amenities` - Tiện nghi
3. ✅ `room_images` - Ảnh phòng
4. ✅ `nearby_places` - Địa điểm xung quanh
5. ✅ `room_universities` - Trường học
6. ✅ `room_video_reviews` - Video đánh giá
7. ✅ `room_units` - Phòng thực tế
8. ✅ `storage.objects` (room-images bucket)

### Policies cho mỗi table:
- ✅ INSERT - Owners có thể tạo mới
- ✅ UPDATE - Owners có thể sửa của họ
- ✅ DELETE - Owners có thể xóa của họ
- ✅ SELECT - Owners xem của họ, Public xem available

## 🔍 Debug Flow

```
User tạo nhà trọ
    ↓
Check permissions (canUserCreateRooms)
    ↓
    ├─ ❌ Không có quyền → Print debug info → Show error
    └─ ✅ Có quyền → Continue
         ↓
    Upload banner
         ↓
         ├─ ❌ Storage error → Show detailed error
         └─ ✅ Success → Continue
              ↓
         Insert into rooms table
              ↓
              ├─ ❌ RLS error → Print debug info → Show error
              └─ ✅ Success → Insert related data
                   ↓
              Success → Redirect
```

## 🧪 Testing

### Test 1: SQL Level
```sql
-- Run test script
\i test_rls_policies.sql

-- Expected: All checks pass ✅
```

### Test 2: Code Level
```javascript
// Open console (F12)
import { printRLSDebugInfo } from '@/utils/debugRLS';
await printRLSDebugInfo();

// Expected output:
// 🔍 RLS Debug Information
// Authentication: ✅ Authenticated
// Role: owner
// Can Insert Rooms: ✅ Yes
```

### Test 3: UI Level
```
1. Login as owner
2. Go to /owner/properties/new
3. Fill form
4. Upload images
5. Submit
6. Expected: Success → Redirect to /owner/properties
```

## 🆘 Troubleshooting

### Lỗi: "new row violates row-level security policy"
```sql
-- Check policies exist
SELECT * FROM pg_policies WHERE tablename = 'rooms';

-- Check RLS enabled
SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'rooms';

-- Check user role
SELECT role FROM profiles WHERE id = auth.uid();
```

### Lỗi: "permission denied for table"
```sql
-- Grant permissions
GRANT ALL ON rooms TO authenticated;
GRANT ALL ON room_amenities TO authenticated;
-- ... (xem fix_rls_policies.sql)
```

### Lỗi: Storage upload failed
```
1. Check Storage → room-images → Policies
2. Verify 3 policies exist (INSERT, SELECT, DELETE)
3. Check bucket is public
```

## 📞 Support

### Cần help?
Cung cấp:
1. Console logs (F12)
2. Kết quả `test_rls_policies.sql`
3. Screenshot error
4. User ID và role

### Files để check:
- ✅ RLS_FIX_SUMMARY.md - Quick guide
- ✅ FIX_RLS_ERROR_GUIDE.md - Detailed guide
- ✅ Console logs - Auto debug info
- ✅ Supabase Dashboard - Policies UI

## ✅ Success Criteria

Sau khi fix xong, bạn có thể:
- ✅ Tạo nhà trọ mới không lỗi
- ✅ Upload banner và ảnh thành công
- ✅ Thêm amenities, universities, nearby places, videos
- ✅ Xem danh sách nhà trọ của mình
- ✅ Sửa và xóa nhà trọ của mình

## 🎉 Done!

Nếu tất cả tests pass, bạn đã fix xong RLS error! 🎊

---

**Quick Links:**
- 📖 [RLS_FIX_SUMMARY.md](./RLS_FIX_SUMMARY.md) - Start here
- 📚 [FIX_RLS_ERROR_GUIDE.md](./FIX_RLS_ERROR_GUIDE.md) - Detailed guide
- 💾 [fix_rls_policies.sql](./fix_rls_policies.sql) - SQL script
- 🧪 [test_rls_policies.sql](./test_rls_policies.sql) - Test script
