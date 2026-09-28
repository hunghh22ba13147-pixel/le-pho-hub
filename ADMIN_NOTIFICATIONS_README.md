# Admin Notifications System

Hệ thống quản lý thông báo cho admin với đầy đủ chức năng CRUD (Create, Read, Update, Delete).

## Tính năng

- ✅ Tạo thông báo mới
- ✅ Chỉnh sửa thông báo
- ✅ Xóa thông báo
- ✅ Hiển thị danh sách thông báo
- ✅ Phân loại thông báo theo loại (info, warning, success, error)
- ✅ Phân quyền đối tượng nhận (tất cả, người thuê, chủ nhà, quản trị viên)
- ✅ Bật/tắt thông báo
- ✅ Thống kê số lượng thông báo

## Cài đặt Database

### Bước 1: Chạy Migration SQL

Truy cập Supabase SQL Editor và chạy file migration:
```sql
database-migrations/notifications_table.sql
```

File này sẽ:
- Tạo bảng `notifications`
- Tạo các index để tăng hiệu suất
- Thiết lập Row Level Security (RLS) policies
- Tạo trigger tự động cập nhật `updated_at`
- Cấp quyền cho người dùng

### Bước 2: Kiểm tra

Sau khi chạy migration, kiểm tra xem bảng đã được tạo:
```sql
SELECT * FROM public.notifications;
```

## Cấu trúc Database

### Bảng `notifications`

| Cột | Kiểu | Mô tả |
|-----|------|-------|
| id | UUID | Primary key, tự động sinh |
| title | TEXT | Tiêu đề thông báo (bắt buộc) |
| content | TEXT | Nội dung thông báo (bắt buộc) |
| type | TEXT | Loại: info, warning, success, error |
| target_audience | TEXT | Đối tượng: all, renters, owners, admins |
| is_active | BOOLEAN | Trạng thái hoạt động (mặc định: true) |
| created_by | UUID | ID admin tạo thông báo |
| created_at | TIMESTAMP | Thời gian tạo (tự động) |
| updated_at | TIMESTAMP | Thời gian cập nhật (tự động) |

### RLS Policies

1. **Admins can do everything**: Admin có toàn quyền CRUD
2. **Users can read active notifications**: Người dùng chỉ đọc được thông báo active dành cho họ

## Sử dụng

### Truy cập trang Admin

1. Đăng nhập với tài khoản admin (role = 'admin')
2. Truy cập: `/admin`
3. Click vào card "Quản lý thông báo" hoặc truy cập `/admin/notifications`

### Tạo thông báo mới

1. Click nút "+ Tạo thông báo mới"
2. Điền thông tin:
   - **Tiêu đề**: Tên thông báo
   - **Nội dung**: Nội dung chi tiết
   - **Loại thông báo**: 
     - Thông tin (màu xanh)
     - Cảnh báo (màu vàng)
     - Thành công (màu xanh lá)
     - Lỗi (màu đỏ)
   - **Đối tượng**: Chọn ai sẽ nhận thông báo
   - **Kích hoạt ngay**: Checkbox để bật/tắt ngay
3. Click "Tạo thông báo"

### Chỉnh sửa thông báo

1. Trong danh sách thông báo, click "Sửa"
2. Cập nhật thông tin cần thiết
3. Click "Cập nhật"

### Xóa thông báo

1. Trong danh sách thông báo, click "Xóa"
2. Xác nhận xóa

## API Functions

### `fetchAllNotifications()`
Lấy tất cả thông báo (chỉ admin)

```typescript
const { notifications, error } = await fetchAllNotifications();
```

### `fetchActiveNotifications(userRole)`
Lấy thông báo active cho role cụ thể

```typescript
const { notifications, error } = await fetchActiveNotifications('renter');
```

### `createNotification(notification)`
Tạo thông báo mới

```typescript
const { notification, error } = await createNotification({
  title: 'Tiêu đề',
  content: 'Nội dung',
  type: 'info',
  target_audience: 'all',
  is_active: true
});
```

### `updateNotification(id, updates)`
Cập nhật thông báo

```typescript
const { notification, error } = await updateNotification(notificationId, {
  title: 'Tiêu đề mới',
  is_active: false
});
```

### `deleteNotification(id)`
Xóa thông báo

```typescript
const { success, error } = await deleteNotification(notificationId);
```

## Files Created

### Backend/Services
- `src/lib/supabaseServices.ts` - Added notification CRUD functions and interfaces

### Admin Pages
- `src/app/admin/notifications/page.tsx` - Main notification management page
- `src/app/admin/notifications/AdminNotificationForm.tsx` - Create/Edit form modal
- `src/app/admin/page.tsx` - Updated with notification navigation

### User Components
- `src/components/NotificationBanner.tsx` - User-facing notification display component

### Database
- `database-migrations/notifications_table.sql` - Database migration script

### Documentation
- `ADMIN_NOTIFICATIONS_README.md` - This documentation file

## Permissions

Để sử dụng trang admin notifications, người dùng phải:
- Đã đăng nhập
- Có `role = 'admin'` trong bảng `profiles`

Người dùng thường (renter/owner) có thể xem thông báo active dành cho họ thông qua `fetchActiveNotifications()`.

## Notes

- Thông báo có thể bật/tắt mà không cần xóa
- Hệ thống tự động cập nhật timestamp khi chỉnh sửa
- Thông báo bị xóa khi admin tạo bị xóa (CASCADE)
- Có thể tích hợp hiển thị thông báo ở frontend cho user

## Hiển thị Thông báo cho User

### Navbar Dropdown (Đã tích hợp sẵn!)

Thông báo tự động hiển thị trong **dropdown thông báo trên navbar** (icon chuông 🔔).

#### Vị trí:
```
Navbar → Icon chuông (🔔) → Bên cạnh avatar user
```

#### Tính năng Notification Dropdown:

- ✅ **Badge đếm**: Hiển thị số thông báo chưa đọc (1, 2, 3... 9+)
- ✅ **Auto-load**: Tự động tải theo role của user
- ✅ **Icons màu sắc**: 
  - 🔵 Info (Thông tin) - Xanh dương
  - 🟡 Warning (Cảnh báo) - Vàng
  - 🟢 Success (Thành công) - Xanh lá
  - 🔴 Error (Lỗi) - Đỏ
- ✅ **Mark as read**: Click vào thông báo để đánh dấu đã đọc
- ✅ **Mark all as read**: Button đánh dấu tất cả đã đọc
- ✅ **Time ago**: Hiển thị thời gian (vừa xong, 5 phút trước, 2 giờ trước...)
- ✅ **Persistent state**: Lưu trạng thái đã đọc vào localStorage
- ✅ **Responsive**: Hoạt động tốt trên mobile và desktop
- ✅ **Dark mode**: Hỗ trợ dark mode
- ✅ **Loading/Empty states**: UI đẹp khi loading hoặc chưa có thông báo

#### Cách hoạt động:

1. **Admin tạo thông báo** tại `/admin/notifications`
2. **Chọn đối tượng**: all / renters / owners / admins
3. **User tự động thấy**:
   - Badge đỏ với số thông báo chưa đọc
   - Click icon chuông để xem dropdown
   - Thông báo được filter theo role
4. **User tương tác**:
   - Click thông báo → đánh dấu đã đọc
   - Click "Đánh dấu tất cả đã đọc" → tất cả read
   - State lưu vào localStorage

### NotificationBanner Component (Optional)

Nếu bạn muốn hiển thị banner thay vì/hoặc cùng với dropdown, có thể sử dụng component `NotificationBanner`:

```tsx
import NotificationBanner from "@/components/NotificationBanner";

<NotificationBanner />
```

**Lưu ý:** Hiện tại thông báo đã tích hợp sẵn trong navbar dropdown, không cần thêm banner.

## Future Enhancements

Các tính năng có thể mở rộng:
- [x] Notification component cho user frontend ✅
- [ ] Push notifications
- [ ] Email notifications
- [ ] Scheduled notifications (đặt lịch)
- [ ] Rich text editor cho content
- [ ] Notification templates
- [ ] Read/unread status tracking
- [ ] Notification history/archive
- [ ] Notification preferences (user settings)

