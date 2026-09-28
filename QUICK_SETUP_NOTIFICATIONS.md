# 🚀 Quick Setup Guide - Admin Notifications

## Bước 1: Setup Database (5 phút)

1. Mở **Supabase Dashboard**
2. Vào **SQL Editor**
3. Copy nội dung file `database-migrations/notifications_table.sql`
4. Paste và click **Run**
5. ✅ Done! Bảng `notifications` đã được tạo

## Bước 2: Kiểm tra (1 phút)

```sql
-- Chạy trong SQL Editor để kiểm tra
SELECT * FROM notifications;
```

Nếu không có lỗi → Setup thành công! 🎉

## Bước 3: Sử dụng Admin Panel (2 phút)

1. Đăng nhập với tài khoản **admin**
   - Email: [admin email của bạn]
   - Password: [password]

2. Truy cập: `http://localhost:3000/admin`

3. Click card **"Quản lý thông báo"** (màu xanh)

4. Click **"+ Tạo thông báo mới"**

5. Điền form:
   ```
   Tiêu đề: Chào mừng!
   Nội dung: Chào mừng bạn đến với hệ thống
   Loại: Thông tin
   Đối tượng: Tất cả người dùng
   ✓ Kích hoạt ngay
   ```

6. Click **"Tạo thông báo"**

7. ✅ Thông báo đầu tiên đã được tạo!

## Bước 4: Hiển thị cho Users ✅ ĐÃ TÍCH HỢP!

**Đã tự động hiển thị trong navbar!**

Thông báo được tích hợp vào dropdown thông báo (icon chuông 🔔) trên navbar. Khi admin tạo thông báo:

1. User sẽ thấy badge đỏ với số thông báo chưa đọc
2. Click vào icon chuông để xem
3. Click vào thông báo để đánh dấu đã đọc
4. Có button "Đánh dấu tất cả đã đọc"

**Vị trí:** Navbar → Icon chuông (🔔) → Bên cạnh avatar user

## 🎯 Test Checklist

- [ ] Database table created
- [ ] Admin page accessible at `/admin`
- [ ] Notifications page accessible at `/admin/notifications`
- [ ] Can create notification
- [ ] Can edit notification
- [ ] Can delete notification
- [ ] Statistics showing correctly
- [ ] ✅ NotificationBanner showing on frontend (auto-integrated!)

## 🐛 Troubleshooting

### Lỗi: "Permission denied"
- Kiểm tra user có `role = 'admin'` trong bảng `profiles`
- Chạy: 
  ```sql
  UPDATE profiles SET role = 'admin' WHERE email = 'your-email@example.com';
  ```

### Lỗi: "Table does not exist"
- Chạy lại migration SQL trong Supabase SQL Editor

### Lỗi: "Not authorized"
- Clear cache và đăng nhập lại
- Kiểm tra RLS policies đã được tạo

### Trang admin redirect về home
- Đảm bảo user đã đăng nhập
- Kiểm tra role = 'admin'

## 📚 Tài liệu đầy đủ

Xem file `ADMIN_NOTIFICATIONS_README.md` để biết:
- API documentation
- Database schema chi tiết
- Advanced usage
- Future enhancements

## 🎉 Done!

Hệ thống notifications đã sẵn sàng sử dụng!

### Routes
- `/admin` - Admin dashboard
- `/admin/notifications` - Quản lý thông báo

### Components
- `NotificationBanner` - Hiển thị thông báo cho users

### API Functions
- `fetchAllNotifications()` - Admin only
- `fetchActiveNotifications(role)` - All users
- `createNotification(data)` - Admin only
- `updateNotification(id, data)` - Admin only
- `deleteNotification(id)` - Admin only

