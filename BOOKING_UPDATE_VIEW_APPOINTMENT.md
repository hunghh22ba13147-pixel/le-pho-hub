# 🔄 Cập Nhật: Booking → Đặt Lịch Xem Phòng

## 📋 Tổng Quan

Đã chuyển đổi hệ thống từ "Đặt phòng" (booking room) sang "Đặt lịch xem phòng" (viewing appointment) vì đây là phòng trọ, không phải khách sạn/nhà nghỉ.

## ✨ Thay Đổi Chính

### 1. Form Đặt Lịch (`BookingForm.tsx`)

#### Đã Xóa:
- ❌ Trường "Ngày trả phòng" (check_out_date)
- ❌ Tính toán tổng tiền
- ❌ Hiển thị giá phòng

#### Đã Thêm/Cập Nhật:
- ✅ Chỉ có 1 ngày: **"Ngày xem phòng"**
- ✅ Placeholder mới: "Ghi chú thời gian bạn muốn đến xem phòng..."
- ✅ Info box: "Đặt lịch xem phòng miễn phí. Chủ nhà sẽ liên hệ xác nhận lịch hẹn với bạn."
- ✅ Button text: "Đặt lịch xem phòng"
- ✅ Success message: "Đặt lịch xem phòng thành công! Chủ nhà sẽ liên hệ xác nhận với bạn sớm."

### 2. Logic Backend (`supabaseServices.ts`)

#### Thay đổi trong `createBooking()`:
```typescript
{
  check_in_date: formData.check_in_date,
  check_out_date: formData.check_in_date,  // Same as check_in for viewing
  total_price: 0,  // No price for viewing appointment
  message: formData.message,
}
```

#### Thông báo đã cập nhật:

| Sự kiện | Title Cũ | Title Mới |
|---------|----------|-----------|
| Tạo mới | Đơn đặt phòng mới | **Lịch xem phòng mới** |
| Duyệt | Đơn đặt phòng được chấp nhận | **Lịch xem phòng được xác nhận** |
| Từ chối | Đơn đặt phòng bị từ chối | **Lịch xem phòng bị từ chối** |

### 3. UI/UX Improvements

#### Form Layout:
```
┌─────────────────────────────┐
│ Đặt lịch xem phòng          │
│ [Room Title]                │
├─────────────────────────────┤
│ Ngày xem phòng: [date]      │
│ Số người ở: [number]        │
│ Lời nhắn: [textarea]        │
│ ℹ️ Đặt lịch miễn phí        │
│ [Đặt lịch xem phòng]        │
└─────────────────────────────┘
```

#### Sidebar Order:
```
1. Button: Chat qua Zalo
2. Button: Gọi điện
3. ─────────────────────
4. Form đặt lịch xem phòng
```

## 📊 Database

Database schema giữ nguyên:
- `check_in_date` → Ngày xem phòng
- `check_out_date` → Được set = check_in_date
- `total_price` → Luôn = 0

## 🎯 User Flow Mới

### User Workflow:
1. User xem chi tiết phòng
2. Điền form "Đặt lịch xem phòng"
   - Chọn ngày muốn xem
   - Nhập số người
   - Ghi chú thời gian (optional)
3. Submit → Tạo appointment (status: pending)
4. Admin/Chủ nhà nhận thông báo
5. Admin xác nhận/từ chối lịch hẹn
6. User nhận thông báo kết quả

### Admin Workflow:
1. Nhận notification: "Lịch xem phòng mới"
2. Vào `/admin/bookings`
3. Xem chi tiết lịch hẹn:
   - Ngày xem phòng
   - Số người
   - Lời nhắn của khách
4. Xác nhận hoặc từ chối
5. User nhận notification

## 🔧 Files Đã Thay Đổi

| File | Thay đổi |
|------|----------|
| `src/components/BookingForm.tsx` | Xóa check_out_date, cập nhật UI/text |
| `src/lib/supabaseServices.ts` | Cập nhật notification messages |
| `src/app/(listing-detail)/phong-tro-detail/page.tsx` | Cập nhật success alert message |

## 💡 Ưu Điểm

✅ **Phù hợp với business logic** - Phòng trọ cần xem trước khi thuê  
✅ **Đơn giản hơn** - Chỉ cần chọn 1 ngày thay vì 2  
✅ **Rõ ràng hơn** - User biết đây là lịch hẹn xem, không phải đặt thuê  
✅ **Giảm confusion** - Không hiển thị giá/tổng tiền  
✅ **UX tốt hơn** - Info box giải thích rõ "miễn phí"  

## 📱 Terminology Mapping

| Tiếng Anh (Cũ) | Tiếng Việt (Cũ) | Tiếng Việt (Mới) |
|----------------|------------------|------------------|
| Booking | Đặt phòng | Đặt lịch xem phòng |
| Check-in date | Ngày nhận phòng | Ngày xem phòng |
| Check-out date | Ngày trả phòng | (Đã xóa) |
| Total price | Tổng tiền | (Đã xóa) |
| Book now | Đặt phòng ngay | Đặt lịch xem phòng |

## 🧪 Test Cases

### ✅ Test Scenarios:

1. **User tạo lịch hẹn**
   - Chọn ngày xem phòng
   - Submit form
   - Check notification cho admin

2. **Admin xác nhận**
   - Approve appointment
   - Check notification cho user
   - Verify message: "Lịch hẹn xem phòng của bạn đã được xác nhận"

3. **Admin từ chối**
   - Reject với lý do
   - Check notification cho user
   - Verify lý do hiển thị đúng

4. **UI Display**
   - Không hiển thị total price
   - Chỉ có 1 date picker
   - Info box màu xanh hiển thị
   - Button text: "Đặt lịch xem phòng"

## 🔄 Migration Notes

**Không cần migration database** vì:
- Schema không thay đổi
- Chỉ thay đổi logic application
- `check_out_date` vẫn tồn tại nhưng = `check_in_date`
- `total_price` = 0 cho tất cả viewing appointments

## 📝 Admin Notes

Khi admin xem bookings, cần hiểu:
- `check_in_date` = Ngày khách muốn xem phòng
- `check_out_date` = Giống check_in_date (ignore)
- `total_price` = 0 (luôn luôn)
- `message` = Ghi chú thời gian khách muốn đến

## 🎨 UI Screenshots Concept

### Before (Đặt phòng):
```
┌─────────────────────────────┐
│ Đặt phòng                   │
│ Ngày nhận: [date]           │
│ Ngày trả: [date]            │
│ Tổng tiền: 5.000.000đ       │
│ [Đặt phòng ngay]            │
└─────────────────────────────┘
```

### After (Đặt lịch):
```
┌─────────────────────────────┐
│ Đặt lịch xem phòng          │
│ Ngày xem: [date]            │
│ Số người: [1]               │
│ Lời nhắn: [textarea]        │
│ ℹ️ Miễn phí                 │
│ [Đặt lịch xem phòng]        │
└─────────────────────────────┘
```

## 🚀 Rollout

### Phiên bản hiện tại:
- ✅ Form chỉ có 1 ngày
- ✅ Không hiển thị giá
- ✅ Text đã cập nhật
- ✅ Notifications phù hợp

### Có thể thêm sau:
- [ ] SMS notification cho lịch hẹn
- [ ] Google Calendar integration
- [ ] Reminder trước ngày xem phòng 1 ngày
- [ ] Review system sau khi xem phòng
- [ ] Rating cho chủ nhà về trải nghiệm xem phòng

---

**Version**: 2.0.0 (Updated from Booking to Viewing Appointment)  
**Date**: 2025-01-10  
**Type**: Major Update - Business Logic Change

