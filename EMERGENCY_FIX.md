# 🚨 KHẨN CẤP - KHÔI PHỤC DATABASE

## ❌ VẤN ĐỀ
- Không login được
- Dữ liệu hiển thị trắng
- Lỗi RLS policies

## ✅ GIẢI PHÁP NHANH (Làm ngay!)

### BƯỚC 1: Chạy Script Khôi Phục
1. Mở **Supabase Dashboard** → **SQL Editor**
2. Mở file `RESTORE_ALL_RLS.sql`
3. Copy toàn bộ nội dung
4. Paste vào SQL Editor
5. Click **RUN** (Ctrl+Enter)
6. Đợi thấy: `✅ KHÔI PHỤC THÀNH CÔNG!`

### BƯỚC 2: Clear Cache Trình Duyệt
- **Windows/Linux:** `Ctrl + Shift + R` hoặc `Ctrl + F5`
- **Mac:** `Cmd + Shift + R`

### BƯỚC 3: Đăng Nhập Lại
1. Logout khỏi ứng dụng (nếu có thể)
2. Đóng tất cả tab
3. Mở tab mới
4. Truy cập lại ứng dụng
5. Đăng nhập

## 🔍 KIỂM TRA

Sau khi chạy script, kiểm tra bằng SQL:

```sql
-- Kiểm tra user hiện tại
SELECT id, name, role, phone FROM profiles WHERE id = auth.uid();

-- Kiểm tra có thể đọc profiles không
SELECT COUNT(*) FROM profiles;

-- Kiểm tra có thể đọc rooms không
SELECT COUNT(*) FROM rooms;

-- Kiểm tra policies
SELECT tablename, COUNT(*) as policy_count 
FROM pg_policies 
WHERE tablename IN ('profiles', 'rooms', 'room_units', 'tenant_profiles')
GROUP BY tablename;
```

## 📋 NGUYÊN NHÂN

Script `fix_all_tenant_rls.sql` đã tạo policies quá chặt chẽ, khiến:
- User không thể đọc profile của chính mình
- Owner không thể xem rooms của mình
- Dữ liệu bị chặn bởi RLS

## 🎯 SCRIPT KHÔI PHỤC LÀM GÌ?

`RESTORE_ALL_RLS.sql` sẽ:
1. ✅ Xóa tất cả policies cũ (bị lỗi)
2. ✅ Tạo lại policies ĐƠN GIẢN và AN TOÀN:
   - User có thể đọc profile của mình
   - Owner/Admin có thể đọc tất cả profiles
   - Owner có thể quản lý rooms của mình
   - Admin có thể làm mọi thứ
3. ✅ Khôi phục policies cho: profiles, rooms, room_units, tenant_profiles, contracts

## ⚠️ SAU KHI KHÔI PHỤC

**KHÔNG CHẠY LẠI** `fix_all_tenant_rls.sql` nữa!

Để thêm tenant với upload ảnh, tôi sẽ tạo giải pháp khác AN TOÀN hơn.

## 🆘 NẾU VẪN KHÔNG ĐƯỢC

### Phương án 1: Tắt RLS tạm thời (CHỈ để test)
```sql
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE rooms DISABLE ROW LEVEL SECURITY;
ALTER TABLE room_units DISABLE ROW LEVEL SECURITY;
```

### Phương án 2: Tạo policy siêu đơn giản
```sql
-- Cho phép TẤT CẢ authenticated users làm MỌI THỨ (CHỈ để test)
CREATE POLICY "temp_allow_all" ON profiles
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);
```

### Phương án 3: Restore từ backup
Nếu có backup database, restore lại trước khi chạy `fix_all_tenant_rls.sql`

## 📞 BÁO CÁO

Sau khi chạy `RESTORE_ALL_RLS.sql`, cho tôi biết:
1. ✅ Đã login được chưa?
2. ✅ Dữ liệu hiển thị chưa?
3. ✅ Kết quả của các câu lệnh SQL kiểm tra ở trên
