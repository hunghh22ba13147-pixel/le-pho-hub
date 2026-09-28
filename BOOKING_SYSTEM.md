# Hệ Thống Đặt Phòng (Booking System)

## 📋 Tổng Quan

Hệ thống đặt phòng cho phép người dùng đặt phòng trọ trực tuyến và admin có thể duyệt/từ chối các đơn đặt phòng. Khi đơn được duyệt hoặc từ chối, người dùng sẽ nhận được thông báo.

## 🗄️ Cấu Trúc Database

### Bảng `bookings`

```sql
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY,
    room_id UUID REFERENCES rooms(id),
    user_id UUID REFERENCES auth.users(id),
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    guests_count INTEGER DEFAULT 1,
    total_price DECIMAL(15, 2),
    status TEXT CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    message TEXT,
    rejection_reason TEXT,
    approved_by UUID REFERENCES auth.users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
);
```

### Trạng Thái Booking

- **pending**: Đơn đang chờ duyệt
- **approved**: Đơn đã được chấp nhận
- **rejected**: Đơn bị từ chối
- **cancelled**: Người dùng đã hủy đơn

## 🚀 Cài Đặt

### Bước 1: Chạy Database Migration

Truy cập Supabase SQL Editor và chạy file migration:

```bash
database-migrations/bookings_table.sql
```

### Bước 2: Kiểm Tra Row Level Security (RLS)

Đảm bảo các policies sau đã được tạo:
- Users có thể xem booking của mình
- Users có thể tạo booking mới
- Users có thể hủy booking đang pending
- Admins có toàn quyền quản lý bookings
- Room owners có thể quản lý bookings cho phòng của họ

## 📱 Tính Năng

### Cho Người Dùng

#### 1. Đặt Phòng

**Component**: `src/components/BookingForm.tsx`

Người dùng có thể:
- Chọn ngày nhận phòng và trả phòng
- Nhập số người ở
- Thêm lời nhắn cho chủ nhà
- Xem tổng tiền tự động tính toán

**Validation**:
- Ngày nhận phòng không thể là quá khứ
- Ngày trả phòng phải sau ngày nhận phòng
- Kiểm tra phòng không bị trùng booking

#### 2. Xem Lịch Sử Đặt Phòng

**Route**: `/account/bookings`

**File**: `src/app/(account-pages)/account-bookings/page.tsx`

Người dùng có thể:
- Xem tất cả đơn đặt phòng của mình
- Xem trạng thái từng đơn
- Hủy đơn đang chờ duyệt
- Xem lý do từ chối (nếu có)

### Cho Admin

#### 1. Quản Lý Đơn Đặt Phòng

**Route**: `/admin/bookings`

**File**: `src/app/admin/bookings/page.tsx`

Admin có thể:
- Xem tất cả đơn đặt phòng
- Lọc theo trạng thái (chờ duyệt / tất cả)
- Duyệt đơn đặt phòng
- Từ chối đơn với lý do cụ thể
- Xem thông tin chi tiết khách hàng

## 🔔 Hệ Thống Thông Báo

### Khi Tạo Booking Mới

```typescript
await createNotification({
  title: 'Đơn đặt phòng mới',
  content: `Có một đơn đặt phòng mới cần được duyệt`,
  type: 'info',
  target_audience: 'admins'
});
```

### Khi Duyệt Booking

```typescript
await createNotification({
  title: 'Đơn đặt phòng được chấp nhận',
  content: `Đơn đặt phòng của bạn đã được chấp nhận. Vui lòng liên hệ chủ nhà để hoàn tất thủ tục.`,
  type: 'success',
  target_audience: 'renters'
});
```

### Khi Từ Chối Booking

```typescript
await createNotification({
  title: 'Đơn đặt phòng bị từ chối',
  content: `Đơn đặt phòng của bạn đã bị từ chối. Lý do: ${rejectionReason}`,
  type: 'warning',
  target_audience: 'renters'
});
```

## 🛠️ API Functions

### Service Functions (`src/lib/supabaseServices.ts`)

#### `createBooking()`
Tạo đơn đặt phòng mới

```typescript
const { success, bookingId, error } = await createBooking({
  room_id: string,
  check_in_date: string,
  check_out_date: string,
  guests_count: number,
  total_price: number,
  message?: string
});
```

#### `fetchMyBookings()`
Lấy danh sách booking của user hiện tại

```typescript
const { bookings, error } = await fetchMyBookings();
```

#### `fetchAllBookings()`
Lấy tất cả bookings (admin only)

```typescript
const { bookings, error } = await fetchAllBookings();
```

#### `fetchPendingBookings()`
Lấy bookings đang chờ duyệt (admin only)

```typescript
const { bookings, error } = await fetchPendingBookings();
```

#### `approveBooking()`
Duyệt booking (admin only)

```typescript
const { success, error } = await approveBooking(bookingId);
```

#### `rejectBooking()`
Từ chối booking (admin only)

```typescript
const { success, error } = await rejectBooking(bookingId, rejectionReason);
```

#### `cancelBooking()`
Hủy booking (user only, cho pending bookings)

```typescript
const { success, error } = await cancelBooking(bookingId);
```

## 📍 Routes

### User Routes

| Route | Mô tả |
|-------|-------|
| `/account/bookings` | Lịch sử đặt phòng của user |
| `/phong-tro-detail?id={roomId}` | Chi tiết phòng với form đặt phòng |

### Admin Routes

| Route | Mô tả |
|-------|-------|
| `/admin/bookings` | Quản lý tất cả đơn đặt phòng |
| `/admin` | Dashboard admin (có link đến bookings) |

## 🎨 UI Components

### `BookingForm.tsx`

Component form đặt phòng với các tính năng:
- Date picker cho check-in/check-out
- Input số người
- Textarea cho lời nhắn
- Tính toán tổng tiền tự động
- Validation form
- Xử lý success/error states

### Admin Booking Page

Trang quản lý với các tính năng:
- Filter tabs (Chờ duyệt / Tất cả)
- Card hiển thị chi tiết booking
- Status badges màu sắc
- Actions buttons (Duyệt / Từ chối)
- Modal nhập lý do từ chối

### User Booking History Page

Trang lịch sử với các tính năng:
- List tất cả bookings của user
- Status indicators
- Link đến room detail
- Button hủy cho pending bookings
- Hiển thị lý do từ chối

## 🔒 Bảo Mật

### Row Level Security (RLS)

- **Users** chỉ xem được bookings của mình
- **Admins** có toàn quyền với tất cả bookings
- **Room Owners** có thể quản lý bookings cho phòng của họ
- **Users** chỉ có thể hủy booking đang pending

### Validation

- Check phòng còn available
- Check không trùng booking trong cùng thời gian
- Validate dates (không cho phép quá khứ)
- Validate quyền truy cập

## 📝 Workflow

### User Workflow

1. User xem chi tiết phòng
2. User điền form đặt phòng
3. System validate và tạo booking (status: pending)
4. Admin nhận thông báo
5. User chờ admin duyệt
6. User nhận thông báo kết quả

### Admin Workflow

1. Admin nhận thông báo có booking mới
2. Admin vào trang `/admin/bookings`
3. Admin xem chi tiết booking
4. Admin duyệt hoặc từ chối
5. User nhận thông báo kết quả

## 🧪 Testing

### Test Cases Cần Kiểm Tra

1. **Tạo booking thành công**
   - User đăng nhập
   - Phòng available
   - Dates hợp lệ
   - Không trùng booking

2. **Validation errors**
   - Ngày quá khứ
   - Check-out trước check-in
   - Phòng đã có booking

3. **Admin approve**
   - Thông báo được tạo
   - Status chuyển sang approved
   - User nhận được thông báo

4. **Admin reject**
   - Phải nhập lý do
   - Status chuyển sang rejected
   - User nhận được thông báo với lý do

5. **User cancel**
   - Chỉ cancel được pending
   - Status chuyển sang cancelled

## 📊 Database Indexes

Các indexes đã được tạo để tối ưu performance:
- `idx_bookings_room_id`
- `idx_bookings_user_id`
- `idx_bookings_status`
- `idx_bookings_check_in_date`
- `idx_bookings_check_out_date`
- `idx_bookings_created_at`

## 🔄 Tích Hợp

### Thêm BookingForm vào Room Detail Page

```tsx
import BookingForm from "@/components/BookingForm";

// Trong component
<BookingForm
  roomId={room.id}
  roomTitle={room.title}
  roomPrice={room.price}
  onSuccess={() => {
    // Handle success
  }}
/>
```

### Kiểm Tra Bookings trong Admin

```tsx
import { fetchPendingBookings } from "@/lib/supabaseServices";

const { bookings, error } = await fetchPendingBookings();
const pendingCount = bookings.length;
```

## 🐛 Troubleshooting

### Lỗi "Không tìm thấy phòng"
- Kiểm tra room_id có tồn tại
- Kiểm tra phòng chưa bị xóa

### Lỗi "Phòng đã có người đặt"
- Có booking pending/approved trùng thời gian
- User cần chọn ngày khác

### Không thấy notification
- Kiểm tra target_audience đúng với user role
- Kiểm tra notification có is_active = true

## 🎯 Future Enhancements

- [ ] Email notification khi booking được duyệt/từ chối
- [ ] SMS notification
- [ ] Tự động hủy booking sau X ngày không duyệt
- [ ] Payment integration
- [ ] Calendar view cho admin
- [ ] Export bookings report
- [ ] Review system sau khi check-out

## 📞 Support

Nếu có vấn đề, vui lòng kiểm tra:
1. Database migration đã chạy chưa
2. RLS policies đã được tạo đúng
3. User có role phù hợp
4. Console logs để debug

---

**Version**: 1.0.0  
**Last Updated**: 2025-01-10

