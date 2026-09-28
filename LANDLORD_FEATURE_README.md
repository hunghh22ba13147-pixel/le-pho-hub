# Tính năng Quản lý Chủ nhà (Landlord) - trohoalac.com

## Tổng quan

Hệ thống quản lý chủ nhà được xây dựng để giúp chủ trọ tại khu vực Hòa Lạc quản lý hiệu quả các hoạt động kinh doanh nhà trọ, từ quản lý phòng, hợp đồng, hóa đơn đến bảo trì.

## Cấu trúc Database

### Các bảng chính đã được tạo:

1. **room_units** - Quản lý các phòng thực tế
   - Liên kết với bảng `rooms` (đóng vai trò là tòa nhà/khu trọ)
   - Trạng thái: available, rented, maintenance
   - Lưu thông tin người thuê hiện tại

2. **contracts** - Quản lý hợp đồng thuê
   - Liên kết với room_units và profiles (người thuê)
   - Trạng thái: active, expired, terminated, pending
   - Lưu thông tin tiền cọc, tiền thuê, thời hạn

3. **services** - Quản lý dịch vụ
   - Loại: fixed (cố định) hoặc variable (theo chỉ số)
   - Lưu đơn giá và đơn vị tính

4. **invoices** - Quản lý hóa đơn
   - Liên kết với room_units và contracts
   - Trạng thái: unpaid, paid, overdue
   - Lưu thông tin thanh toán

5. **invoice_items** - Chi tiết hóa đơn
   - Liên kết với invoices và services
   - Lưu chỉ số cũ/mới, mức tiêu thụ

6. **maintenance_requests** - Yêu cầu bảo trì
   - Liên kết với room_units và profiles (người thuê)
   - Trạng thái: pending, in_progress, resolved, rejected
   - Mức độ ưu tiên: low, normal, high, urgent

7. **tenant_profiles** - Hồ sơ khách thuê mở rộng
   - Lưu CMND/CCCD, thông tin sinh viên
   - Liên hệ khẩn cấp

## Cấu trúc Code

### Services Layer (`src/lib/landlordServices.ts`)

Chứa tất cả các functions để tương tác với database:

- **Room Units**: `fetchRoomUnits`, `createRoomUnit`, `updateRoomUnit`, `deleteRoomUnit`
- **Contracts**: `fetchRoomUnitContracts`, `createContract`, `updateContract`, `terminateContract`
- **Services**: `fetchOwnerServices`, `createService`, `updateService`, `deleteService`
- **Invoices**: `fetchOwnerInvoices`, `createInvoice`, `updateInvoiceStatus`
- **Maintenance**: `fetchOwnerMaintenanceRequests`, `updateMaintenanceRequestStatus`
- **Dashboard**: `fetchOwnerDashboardStats`

### Pages

1. **Dashboard** (`/owner`) - Tổng quan
   - Thống kê tổng số phòng, phòng trống, phòng đang thuê
   - Hóa đơn chưa thu, quá hạn
   - Doanh thu tháng
   - Yêu cầu bảo trì chờ xử lý

2. **Quản lý Phòng** (`/owner/rooms`)
   - Hiển thị danh sách phòng theo từng nhà trọ
   - Thêm/xóa phòng
   - Lọc theo trạng thái (trống, đang thuê, bảo trì)
   - Tìm kiếm phòng

3. **Quản lý Khách thuê** (`/owner/tenants`)
   - Danh sách khách thuê
   - Thông tin liên hệ, CMND/CCCD
   - Trạng thái lưu trú, đăng ký tạm trú

4. **Quản lý Hợp đồng** (`/owner/contracts`)
   - Danh sách hợp đồng
   - Lọc theo trạng thái (đang hiệu lực, sắp hết hạn, đã quá hạn)
   - Tạo hợp đồng mới

5. **Quản lý Hóa đơn** (`/owner/invoices`)
   - Danh sách hóa đơn theo tháng
   - Lọc theo trạng thái (chưa thanh toán, đã thanh toán, quá hạn)
   - Đánh dấu đã thanh toán
   - Tạo hóa đơn mới

6. **Quản lý Dịch vụ** (`/owner/services`)
   - Cấu hình bảng giá điện, nước, internet, rác
   - Phân loại dịch vụ cố định và theo chỉ số
   - Thêm/sửa/xóa dịch vụ

7. **Bảo trì** (`/owner/maintenance`)
   - Danh sách yêu cầu bảo trì từ khách thuê
   - Lọc theo trạng thái và mức độ ưu tiên
   - Cập nhật trạng thái xử lý
   - Xem hình ảnh đính kèm

## Cách sử dụng

### 1. Thiết lập Database

Chạy migration file:
```sql
-- File: database-migrations/landlord.sql
```

### 2. Phân quyền User

Để truy cập dashboard chủ nhà, user cần có role là `owner` hoặc `admin` trong bảng `profiles`.

```sql
UPDATE profiles 
SET role = 'owner' 
WHERE id = 'user_id_here';
```

### 3. Truy cập Dashboard

Sau khi đăng nhập với tài khoản có role `owner`, truy cập:
```
https://trohoalac.com/owner
```

### 4. Quy trình làm việc cơ bản

#### Bước 1: Thêm nhà trọ
- Sử dụng chức năng đăng tin hiện có để tạo "nhà trọ" (bảng `rooms`)
- Mỗi nhà trọ đại diện cho một tòa nhà/khu trọ

#### Bước 2: Tạo phòng
- Vào `/owner/rooms`
- Chọn nhà trọ và thêm các phòng (101, 102, 103...)
- Mỗi phòng là một `room_unit`

#### Bước 3: Cấu hình dịch vụ
- Vào `/owner/services`
- Thêm các dịch vụ: Điện (theo kWh), Nước (theo m³), Internet (cố định), Rác (cố định)

#### Bước 4: Tạo hợp đồng
- Vào `/owner/contracts`
- Tạo hợp đồng cho khách thuê
- Hệ thống tự động cập nhật trạng thái phòng thành "đang thuê"

#### Bước 5: Tạo hóa đơn hàng tháng
- Vào `/owner/invoices`
- Tạo hóa đơn mới, nhập chỉ số điện/nước
- Hệ thống tự động tính toán dựa trên bảng giá dịch vụ

#### Bước 6: Xử lý yêu cầu bảo trì
- Khách thuê gửi yêu cầu (tính năng này sẽ được phát triển)
- Chủ nhà xem và xử lý tại `/owner/maintenance`

## Tính năng đã hoàn thành

✅ Database schema hoàn chỉnh
✅ Services layer với đầy đủ CRUD operations
✅ Dashboard với thống kê real-time
✅ Quản lý phòng (thêm, xóa, lọc)
✅ Quản lý dịch vụ (thêm, sửa, xóa)
✅ Quản lý hóa đơn (xem, đánh dấu đã thanh toán)
✅ Quản lý bảo trì (xem, cập nhật trạng thái)
✅ UI/UX responsive, dark mode support

## Tính năng cần phát triển tiếp

### Giai đoạn 2 (Ưu tiên cao):

1. **Tạo hóa đơn tự động**
   - Form nhập chỉ số điện/nước
   - Tự động tính toán dựa trên services
   - Xuất hóa đơn dạng PDF/ảnh

2. **Tạo hợp đồng điện tử**
   - Form tạo hợp đồng với template
   - Upload ảnh CMND/CCCD
   - Lưu trữ file hợp đồng

3. **Thông báo tự động**
   - Nhắc hợp đồng sắp hết hạn (30 ngày)
   - Nhắc hóa đơn chưa thanh toán
   - Thông báo yêu cầu bảo trì mới

4. **Tích hợp thanh toán**
   - Tạo mã QR VietQR động
   - Webhook nhận thông báo thanh toán
   - Tự động cập nhật trạng thái hóa đơn

### Giai đoạn 3 (Tính năng nâng cao):

1. **Báo cáo & Thống kê**
   - Biểu đồ doanh thu theo tháng
   - Tỷ lệ lấp đầy phòng
   - Báo cáo công nợ
   - Export Excel

2. **Tính năng cho Khách thuê**
   - Portal cho khách thuê xem hóa đơn
   - Gửi yêu cầu bảo trì kèm ảnh
   - Xem lịch sử thanh toán

3. **Tìm người ở ghép**
   - Chủ nhà đăng tin tìm bạn cùng phòng
   - Khách thuê hiện tại giới thiệu bạn

4. **Quản lý nội thất**
   - Danh sách nội thất theo phòng
   - Theo dõi tình trạng
   - Lịch sử sửa chữa/thay thế

## API Endpoints (Cần phát triển)

Để hỗ trợ mobile app hoặc tích hợp bên thứ 3:

```
POST   /api/owner/room-units
GET    /api/owner/room-units
PUT    /api/owner/room-units/:id
DELETE /api/owner/room-units/:id

POST   /api/owner/contracts
GET    /api/owner/contracts
PUT    /api/owner/contracts/:id

POST   /api/owner/invoices
GET    /api/owner/invoices
PUT    /api/owner/invoices/:id/status

GET    /api/owner/services
POST   /api/owner/services
PUT    /api/owner/services/:id
DELETE /api/owner/services/:id

GET    /api/owner/maintenance-requests
PUT    /api/owner/maintenance-requests/:id/status

GET    /api/owner/dashboard/stats
```

## Bảo mật

- ✅ Row Level Security (RLS) policies cần được thêm vào Supabase
- ✅ Chỉ owner có thể xem/sửa dữ liệu của mình
- ✅ Validation input ở cả client và server
- ⚠️ Cần thêm rate limiting cho API
- ⚠️ Cần encrypt thông tin nhạy cảm (CMND/CCCD)

## Testing

Cần viết tests cho:
- [ ] Services layer functions
- [ ] Dashboard calculations
- [ ] Invoice calculations
- [ ] Contract status transitions
- [ ] RLS policies

## Performance

Các điểm cần tối ưu:
- [ ] Index cho các foreign keys
- [ ] Cache dashboard stats
- [ ] Pagination cho danh sách lớn
- [ ] Lazy loading images
- [ ] Optimize queries với proper joins

## Deployment

1. Chạy migrations trên production database
2. Update RLS policies
3. Deploy frontend code
4. Test với tài khoản owner thật
5. Monitor logs và performance

## Support

Nếu có vấn đề, liên hệ:
- Email: support@trohoalac.com
- Zalo: [số điện thoại]

---

**Phiên bản:** 1.0.0  
**Ngày cập nhật:** 18/05/2026  
**Tác giả:** trohoalac.com Development Team
