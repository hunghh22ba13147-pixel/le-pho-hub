# Tài liệu Triển khai Chức năng Nhà trọ và Phòng - Dashboard Chủ trọ

## Tổng quan
Tài liệu này mô tả chi tiết việc triển khai chức năng quản lý Nhà trọ và Phòng trong dashboard chủ trọ, kết nối với database Supabase thay vì dữ liệu mock.

## Ngày cập nhật
18/05/2026

---

## 1. Cấu trúc Database

### Bảng chính đã sử dụng:

#### `rooms` (Nhà trọ/Tòa nhà)
- `id`: UUID - Primary key
- `owner_id`: UUID - Foreign key đến `profiles`
- `title`: TEXT - Tên nhà trọ
- `description`: TEXT - Mô tả
- `address`: TEXT - Địa chỉ chi tiết
- `city`, `district`, `ward`: TEXT - Địa chỉ hành chính
- `price`: NUMERIC - Giá thuê
- `area`: NUMERIC - Diện tích
- `status`: TEXT - Trạng thái (available, reserved, rented, hidden)
- `banner`: TEXT - URL ảnh đại diện
- `maps`: TEXT - Link Google Maps
- `created_at`: TIMESTAMP

#### `room_units` (Phòng thực tế)
- `id`: UUID - Primary key
- `room_id`: UUID - Foreign key đến `rooms`
- `name`: TEXT - Tên phòng (VD: Phòng 101)
- `status`: TEXT - Trạng thái (available, rented, maintenance)
- `current_renter_id`: UUID - Foreign key đến `profiles`
- `created_at`, `updated_at`: TIMESTAMP

#### `profiles` (Người dùng)
- `id`: UUID - Primary key
- `name`: TEXT - Họ tên
- `phone`: TEXT - Số điện thoại
- `role`: TEXT - Vai trò (owner, renter, admin)

---

## 2. Các trang đã triển khai

### 2.1. Trang Quản lý Nhà trọ (`/owner/properties`)

**File:** `src/app/owner/properties/page.tsx`

**Chức năng:**
- ✅ Hiển thị danh sách nhà trọ của chủ trọ
- ✅ Tìm kiếm nhà trọ theo tên và địa chỉ
- ✅ Thống kê tổng quan (Tổng nhà trọ, Đang hoạt động, Đã cho thuê)
- ✅ Xem chi tiết, sửa, xóa nhà trọ
- ✅ Nút thêm nhà trọ mới

**Kết nối Database:**
```typescript
// Lấy danh sách nhà trọ từ database
const allRooms = await fetchRooms();
const ownerProperties = allRooms.filter(room => room.author.id === user.id);
```

**UI/UX:**
- Grid layout responsive (1-2-3 cột)
- Card hiển thị ảnh, tên, địa chỉ, giá, diện tích
- Badge trạng thái (Hoạt động/Đã thuê)
- Actions: Xem, Sửa, Xóa

---

### 2.2. Trang Thêm Nhà trọ mới (`/owner/properties/new`)

**File:** `src/app/owner/properties/new/page.tsx`

**Chức năng:**
- ✅ Form nhập thông tin nhà trọ
- ✅ Upload ảnh đại diện (banner)
- ✅ Nhập địa chỉ chi tiết (Số nhà, Phường, Quận, Thành phố)
- ✅ Nhập giá thuê và diện tích
- ✅ Nhập link Google Maps
- ✅ Validation dữ liệu
- ✅ Lưu vào database

**Kết nối Database:**
```typescript
// Upload ảnh lên Supabase Storage
const { data } = await supabase.storage
  .from('room-images')
  .upload(fileName, bannerFile);

// Tạo nhà trọ mới
const { data, error } = await supabase
  .from('rooms')
  .insert({
    owner_id: user.id,
    title: formData.title,
    // ... các trường khác
  });
```

**Validation:**
- Tên nhà trọ: Bắt buộc
- Địa chỉ: Bắt buộc
- Giá thuê: Bắt buộc, > 0
- Diện tích: Bắt buộc, > 0

---

### 2.3. Trang Quản lý Phòng (`/owner/rooms`)

**File:** `src/app/owner/rooms/page.tsx`

**Chức năng:**
- ✅ Hiển thị danh sách phòng theo nhà trọ (Accordion)
- ✅ Filter theo nhà trọ
- ✅ Tabs filter theo trạng thái (Tất cả, Đang thuê, Trống, Bảo trì)
- ✅ Tìm kiếm phòng theo tên
- ✅ Thêm phòng mới cho nhà trọ
- ✅ Xóa phòng
- ✅ Xem chi tiết phòng

**Kết nối Database:**
```typescript
// Lấy danh sách phòng của chủ trọ
const unitsData = await fetchOwnerRoomUnits(user.id);

// Tạo phòng mới
await createRoomUnit({
  room_id: propertyId,
  name: newRoomName,
  status: 'available',
});

// Xóa phòng
await deleteRoomUnit(roomUnitId);
```

**UI/UX:**
- Accordion cho mỗi nhà trọ
- Hiển thị tổng số phòng của mỗi nhà trọ
- Card phòng với thông tin: Tên, Trạng thái, Người thuê (nếu có)
- Badge trạng thái màu sắc khác nhau
- Modal thêm phòng nhanh

---

### 2.4. Trang Chi tiết Phòng (`/owner/rooms/[id]`)

**File:** `src/app/owner/rooms/[id]/page.tsx`

**Chức năng:**
- ✅ Hiển thị thông tin chi tiết phòng
- ✅ Hiển thị thông tin nhà trọ
- ✅ Hiển thị người thuê hiện tại (nếu có)
- ✅ Đổi trạng thái phòng (Modal)
- ✅ Thống kê nhanh (Hợp đồng, Hóa đơn, Bảo trì)
- ✅ Quick actions (Tạo hợp đồng, Tạo hóa đơn)

**Kết nối Database:**
```typescript
// Lấy thông tin phòng
const { data } = await supabase
  .from('room_units')
  .select(`
    *,
    rooms:room_id (id, title, address, banner, price, area),
    current_renter:current_renter_id (id, name, phone)
  `)
  .eq('id', roomUnitId)
  .single();

// Cập nhật trạng thái
await updateRoomUnit(roomUnit.id, { status: newStatus });
```

**UI/UX:**
- Layout 2 cột (Thông tin chính + Actions)
- Card thông tin nhà trọ với ảnh
- Card người thuê hiện tại
- Modal đổi trạng thái với radio buttons
- Quick action buttons

---

## 3. Services đã sử dụng

### 3.1. `supabaseServices.ts`

**Functions:**
- `fetchRooms()`: Lấy danh sách tất cả nhà trọ
- `fetchRoomById(id)`: Lấy thông tin 1 nhà trọ

### 3.2. `landlordServices.ts`

**Functions:**
- `fetchOwnerRoomUnits(ownerId)`: Lấy tất cả phòng của chủ trọ
- `createRoomUnit(data)`: Tạo phòng mới
- `updateRoomUnit(id, updates)`: Cập nhật thông tin phòng
- `deleteRoomUnit(id)`: Xóa phòng
- `fetchOwnerDashboardStats(ownerId)`: Lấy thống kê dashboard

---

## 4. Luồng xử lý chính

### 4.1. Luồng thêm nhà trọ mới

```
1. User vào /owner/properties
2. Click "Thêm nhà trọ mới"
3. Điền form tại /owner/properties/new
4. Upload ảnh (nếu có) → Supabase Storage
5. Submit form → Insert vào bảng `rooms`
6. Redirect về /owner/properties
```

### 4.2. Luồng thêm phòng

```
1. User vào /owner/rooms
2. Chọn nhà trọ hoặc expand accordion
3. Click "Thêm phòng"
4. Nhập tên phòng trong modal
5. Submit → Insert vào bảng `room_units`
6. Reload danh sách phòng
```

### 4.3. Luồng đổi trạng thái phòng

```
1. User vào /owner/rooms/[id]
2. Click "Đổi trạng thái"
3. Chọn trạng thái mới trong modal
4. Submit → Update bảng `room_units`
5. Reload thông tin phòng
```

---

## 5. Tính năng đã hoàn thành

### ✅ Quản lý Nhà trọ
- [x] Xem danh sách nhà trọ
- [x] Thêm nhà trọ mới
- [x] Upload ảnh nhà trọ
- [x] Tìm kiếm nhà trọ
- [x] Thống kê tổng quan
- [ ] Sửa thông tin nhà trọ (TODO)
- [ ] Xóa nhà trọ (TODO)

### ✅ Quản lý Phòng
- [x] Xem danh sách phòng theo nhà trọ
- [x] Thêm phòng mới
- [x] Xóa phòng
- [x] Filter theo trạng thái
- [x] Tìm kiếm phòng
- [x] Xem chi tiết phòng
- [x] Đổi trạng thái phòng
- [x] Hiển thị người thuê hiện tại

---

## 6. Tính năng cần phát triển tiếp

### 🔄 Giai đoạn tiếp theo

#### 6.1. Quản lý Hợp đồng
- [ ] Tạo hợp đồng mới
- [ ] Xem danh sách hợp đồng
- [ ] Upload file hợp đồng PDF
- [ ] Lưu thông tin CCCD khách thuê
- [ ] Thông báo hợp đồng sắp hết hạn
- [ ] Kết thúc hợp đồng

#### 6.2. Quản lý Hóa đơn
- [ ] Tạo hóa đơn tháng
- [ ] Nhập chỉ số điện/nước
- [ ] Tính toán tự động
- [ ] Xuất hóa đơn PDF/Ảnh
- [ ] Gửi hóa đơn qua Zalo/Email
- [ ] Đánh dấu đã thanh toán
- [ ] Thống kê công nợ

#### 6.3. Quản lý Dịch vụ
- [ ] Tạo dịch vụ (Điện, Nước, Wifi, Rác...)
- [ ] Cài đặt đơn giá
- [ ] Gán dịch vụ cho phòng
- [ ] Lịch sử thay đổi giá

#### 6.4. Quản lý Bảo trì
- [ ] Xem yêu cầu bảo trì từ khách
- [ ] Cập nhật trạng thái xử lý
- [ ] Upload ảnh trước/sau sửa chữa
- [ ] Ghi chú chi phí sửa chữa

#### 6.5. Báo cáo & Thống kê
- [ ] Biểu đồ doanh thu theo tháng
- [ ] Tỷ lệ lấp đầy phòng
- [ ] Báo cáo công nợ
- [ ] Xuất Excel

---

## 7. Cấu trúc thư mục

```
src/app/owner/
├── page.tsx                    # Dashboard tổng quan
├── layout.tsx                  # Layout chung
├── properties/
│   ├── page.tsx               # Danh sách nhà trọ ✅
│   ├── new/
│   │   └── page.tsx          # Thêm nhà trọ mới ✅
│   └── [id]/
│       ├── page.tsx          # Chi tiết nhà trọ (TODO)
│       └── edit/
│           └── page.tsx      # Sửa nhà trọ (TODO)
├── rooms/
│   ├── page.tsx               # Danh sách phòng ✅
│   └── [id]/
│       └── page.tsx          # Chi tiết phòng ✅
├── contracts/                 # Quản lý hợp đồng (TODO)
├── invoices/                  # Quản lý hóa đơn (TODO)
├── services/                  # Quản lý dịch vụ (TODO)
├── maintenance/               # Quản lý bảo trì (TODO)
└── tenants/                   # Quản lý khách thuê (TODO)
```

---

## 8. API Endpoints (Supabase)

### Đã sử dụng:
- `GET /rooms` - Lấy danh sách nhà trọ
- `POST /rooms` - Tạo nhà trọ mới
- `GET /room_units` - Lấy danh sách phòng
- `POST /room_units` - Tạo phòng mới
- `PATCH /room_units/:id` - Cập nhật phòng
- `DELETE /room_units/:id` - Xóa phòng
- `POST /storage/room-images` - Upload ảnh

### Cần phát triển:
- `PATCH /rooms/:id` - Cập nhật nhà trọ
- `DELETE /rooms/:id` - Xóa nhà trọ
- `GET /contracts` - Lấy danh sách hợp đồng
- `POST /contracts` - Tạo hợp đồng
- `GET /invoices` - Lấy danh sách hóa đơn
- `POST /invoices` - Tạo hóa đơn

---

## 9. Ghi chú kỹ thuật

### 9.1. Authentication
- Sử dụng `useAuth()` context để lấy thông tin user
- Kiểm tra `user.id` trước khi gọi API
- Filter dữ liệu theo `owner_id`

### 9.2. Image Upload
- Storage bucket: `room-images`
- Path format: `{user_id}/{timestamp}.{ext}`
- Public URL được tạo tự động

### 9.3. Status Management
- Room status: `available`, `rented`, `maintenance`
- Property status: `available`, `reserved`, `rented`, `hidden`
- Contract status: `active`, `expired`, `terminated`, `pending`
- Invoice status: `unpaid`, `paid`, `overdue`

### 9.4. Responsive Design
- Mobile-first approach
- Breakpoints: sm (640px), md (768px), lg (1024px)
- Grid layout tự động điều chỉnh

---

## 10. Testing Checklist

### ✅ Đã test:
- [x] Hiển thị danh sách nhà trọ
- [x] Thêm nhà trọ mới
- [x] Upload ảnh nhà trọ
- [x] Hiển thị danh sách phòng
- [x] Thêm phòng mới
- [x] Xóa phòng
- [x] Xem chi tiết phòng
- [x] Đổi trạng thái phòng

### 🔄 Cần test:
- [ ] Sửa thông tin nhà trọ
- [ ] Xóa nhà trọ
- [ ] Performance với nhiều nhà trọ/phòng
- [ ] Error handling
- [ ] Loading states

---

## 11. Known Issues

1. **Xóa nhà trọ**: Chưa implement, cần xử lý cascade delete
2. **Sửa nhà trọ**: Chưa có trang edit
3. **Validation**: Cần thêm validation phía server
4. **Error handling**: Cần cải thiện thông báo lỗi
5. **Loading states**: Một số action chưa có loading indicator

---

## 12. Performance Optimization

### Đã áp dụng:
- Lazy loading images
- Debounce search input
- Pagination (chuẩn bị)

### Cần cải thiện:
- Cache danh sách nhà trọ
- Optimize query với select specific fields
- Add indexes cho search

---

## Kết luận

Chức năng Nhà trọ và Phòng đã được triển khai cơ bản với kết nối database thực. Các tính năng CRUD cơ bản đã hoạt động tốt. Giai đoạn tiếp theo sẽ tập trung vào Hợp đồng và Hóa đơn để hoàn thiện luồng quản lý cho chủ trọ.

---

**Người thực hiện:** Kiro AI Assistant  
**Ngày hoàn thành:** 18/05/2026  
**Version:** 1.0
