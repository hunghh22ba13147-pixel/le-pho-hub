# ✅ Hoàn thành chức năng Khách thuê với dữ liệu thật

## Tổng quan

Đã chuyển trang **Khách thuê** (`/owner/tenants`) từ mock data sang dữ liệu thật từ database.

## Tính năng đã hoàn thành

### 1. **Hiển thị danh sách khách thuê**
- ✅ Load tất cả khách thuê của chủ trọ từ database
- ✅ Hiển thị thông tin: Tên, SĐT, Email, CMND, Phòng hiện tại
- ✅ Hiển thị trạng thái lưu trú (Đang thuê, Chưa thuê, Đã rời đi)
- ✅ Hiển thị trạng thái đăng ký tạm trú
- ✅ Avatar với chữ cái đầu tên

### 2. **Tìm kiếm và lọc**
- ✅ Tìm kiếm theo: Tên, SĐT, CMND
- ✅ Lọc theo trạng thái lưu trú (Tất cả, Đang thuê, Chưa thuê, Đã rời đi)
- ✅ Lọc theo đăng ký tạm trú (Tất cả, Đã đăng ký, Chưa đăng ký)
- ✅ Real-time filtering

### 3. **Thống kê**
- ✅ Tổng số khách thuê
- ✅ Số khách đang thuê
- ✅ Số khách đã đăng ký tạm trú
- ✅ Số khách chưa đăng ký

### 4. **Quản lý khách thuê**
- ✅ Xóa khách thuê (có kiểm tra hợp đồng active)
- ✅ Loading state
- ✅ Empty state
- ⏳ Thêm mới khách thuê (UI đã có, chưa implement)
- ⏳ Sửa thông tin khách thuê (UI đã có, chưa implement)

## Database Structure

### Bảng `profiles`
```sql
- id (uuid, PK)
- name (text)
- phone (text)
- email (text)
- role (text) -- 'renter', 'owner', 'admin'
- DoB (date)
- avatar (text)
```

### Bảng `tenant_profiles`
```sql
- id (uuid, PK)
- profile_id (uuid, FK -> profiles.id)
- id_card_number (text)
- id_card_front_url (text)
- id_card_back_url (text)
- university_id (uuid)
- student_id (text)
- hometown (text)
- emergency_contact_name (text)
- emergency_contact_phone (text)
```

### Bảng `contracts`
```sql
- id (uuid, PK)
- renter_id (uuid, FK -> profiles.id)
- room_unit_id (uuid, FK -> room_units.id)
- start_date (date)
- end_date (date)
- status (text) -- 'active', 'expired', 'terminated'
```

## Services đã tạo

### File: `src/lib/landlordServices.ts`

#### 1. `fetchOwnerTenants(ownerId: string)`
Lấy tất cả khách thuê của chủ trọ (người có/đã có hợp đồng với phòng của chủ trọ)

**Returns:**
```typescript
TenantWithDetails[] {
  id: string;
  name: string;
  phone: string;
  email?: string;
  DoB?: string;
  tenant_profile?: TenantProfile;
  current_contract?: {
    id: string;
    room_unit: {
      name: string;
      room: {
        title: string;
        address: string;
      };
    };
  };
  has_temporary_residence: boolean;
  stay_status: 'not_rented' | 'renting' | 'moved_out';
}
```

#### 2. `createTenant(data)`
Tạo khách thuê mới

**Parameters:**
```typescript
{
  name: string;
  phone: string;
  email?: string;
  DoB?: string;
  id_card_number?: string;
  hometown?: string;
  emergency_contact_name?: string;
  emergency_contact_phone?: string;
}
```

#### 3. `updateTenant(tenantId, data)`
Cập nhật thông tin khách thuê

#### 4. `deleteTenant(tenantId)`
Xóa khách thuê (chỉ xóa được nếu không có hợp đồng active)

## Logic xử lý

### Xác định trạng thái lưu trú:
```typescript
- 'renting': Có hợp đồng status = 'active'
- 'moved_out': Đã có hợp đồng nhưng không còn active
- 'not_rented': Chưa có hợp đồng nào
```

### Xác định đăng ký tạm trú:
```typescript
has_temporary_residence = !!tenant_profile?.id_card_number
```

## UI Components

### Trang `/owner/tenants`

**Layout:**
- Action bar (Nhập dữ liệu, Thêm mới)
- Filter section (Tìm kiếm, Lọc lưu trú, Lọc tạm trú)
- Stats cards (4 cards)
- Table (responsive, với loading và empty states)

**Table columns:**
1. Khách thuê (Avatar + Tên + Ngày sinh)
2. Liên hệ (SĐT + Email)
3. CMND/CCCD
4. Phòng hiện tại (Tên phòng + Nhà trọ)
5. Đăng ký tạm trú (Badge)
6. Lưu trú (Badge)
7. Thao tác (Sửa, Xóa)

**Badge colors:**
- Đang thuê: Blue
- Chưa thuê: Gray
- Đã rời đi: Gray
- Đã đăng ký: Green
- Chưa đăng ký: Yellow

## Testing

### Test 1: Load danh sách
```
1. Đăng nhập với tài khoản owner
2. Vào /owner/tenants
3. Kiểm tra: Hiển thị danh sách khách thuê từ database
```

### Test 2: Tìm kiếm
```
1. Nhập tên/SĐT/CMND vào ô tìm kiếm
2. Kiểm tra: Danh sách lọc real-time
```

### Test 3: Lọc
```
1. Chọn filter "Đang thuê"
2. Kiểm tra: Chỉ hiển thị khách đang thuê
3. Chọn filter "Đã đăng ký tạm trú"
4. Kiểm tra: Chỉ hiển thị khách đã đăng ký
```

### Test 4: Xóa
```
1. Click nút xóa khách thuê không có hợp đồng active
2. Confirm
3. Kiểm tra: Xóa thành công, reload danh sách
4. Thử xóa khách có hợp đồng active
5. Kiểm tra: Hiển thị lỗi "Không thể xóa..."
```

## Next Steps (Tùy chọn)

### 1. Thêm mới khách thuê
- [ ] Tạo modal/form thêm khách thuê
- [ ] Validate input
- [ ] Call `createTenant()`
- [ ] Reload danh sách

### 2. Sửa thông tin khách thuê
- [ ] Tạo modal/form sửa
- [ ] Pre-fill dữ liệu hiện tại
- [ ] Call `updateTenant()`
- [ ] Reload danh sách

### 3. Chi tiết khách thuê
- [ ] Tạo trang `/owner/tenants/[id]`
- [ ] Hiển thị thông tin đầy đủ
- [ ] Lịch sử hợp đồng
- [ ] Lịch sử thanh toán

### 4. Import/Export
- [ ] Import từ Excel
- [ ] Export danh sách ra Excel
- [ ] Template Excel mẫu

### 5. Đăng ký tạm trú
- [ ] Form đăng ký tạm trú
- [ ] Upload ảnh CMND/CCCD
- [ ] In giấy đăng ký tạm trú

## Files đã sửa/tạo

### Đã sửa:
1. ✅ `src/lib/landlordServices.ts` - Thêm tenant services
2. ✅ `src/app/owner/tenants/page.tsx` - Chuyển sang dữ liệu thật

### Đã tạo:
1. ✅ `TENANTS_FEATURE_COMPLETE.md` - Tài liệu này

## Lưu ý

### RLS Policies
Cần đảm bảo RLS policies cho:
- ✅ `profiles` - Owner có thể SELECT renters
- ✅ `tenant_profiles` - Owner có thể SELECT/UPDATE
- ✅ `contracts` - Owner có thể SELECT contracts của phòng họ

### Performance
- Hiện tại load tất cả tenants cùng lúc
- Nếu có nhiều khách (>100), nên implement pagination
- Consider caching với React Query hoặc SWR

### Security
- ✅ Owner chỉ thấy khách thuê của phòng họ
- ✅ Không thể xóa khách có hợp đồng active
- ✅ Validate input khi create/update

## Kết quả

✅ Trang khách thuê đã hoạt động với dữ liệu thật
✅ Tìm kiếm và lọc hoạt động tốt
✅ Thống kê chính xác
✅ Xóa khách thuê an toàn
✅ UI responsive và đẹp
✅ Loading và empty states

Chủ trọ giờ có thể:
- Xem danh sách tất cả khách thuê
- Tìm kiếm khách thuê nhanh chóng
- Lọc theo trạng thái
- Xem thống kê tổng quan
- Xóa khách thuê (nếu không có hợp đồng active)
