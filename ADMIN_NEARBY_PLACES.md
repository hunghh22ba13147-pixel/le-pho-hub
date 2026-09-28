# 🗺️ Admin Form - Khu vực xung quanh

## ✅ Đã hoàn thành

Thêm phần quản lý "Khu vực xung quanh" vào Admin Create Room Form, cho phép admin/owner thêm các địa điểm xung quanh khi tạo phòng mới.

---

## 🎯 Tính năng

### **Admin Form Features**
- ➕ Thêm nhiều địa điểm xung quanh
- 🏷️ Chọn category với emoji
- 📏 Nhập khoảng cách (km)
- 📝 Mô tả chi tiết (optional)
- ➖ Xóa từng địa điểm
- 💾 Auto-save khi tạo phòng

---

## 📋 Form Fields

Mỗi địa điểm có các trường:

### 1. **Tên địa điểm** (Required)
- Placeholder: "Tên địa điểm (VD: Đại học FPT)"
- Type: Text input
- Validation: Required khi có distance

### 2. **Loại địa điểm** (Category)
- Type: Select dropdown
- Options:
  - 🎓 Đại học
  - 🏫 Trường học
  - 🏥 Bệnh viện
  - 🛒 Siêu thị
  - 🏪 Trung tâm thương mại
  - 🌳 Công viên
  - 🚌 Trạm xe buýt
  - 🚇 Tàu điện
  - 🍽️ Nhà hàng
  - ☕ Quán cafe
  - 💪 Phòng gym
  - 📍 Khác

### 3. **Khoảng cách** (Required)
- Type: Number input
- Step: 0.1
- Placeholder: "Khoảng cách (km)"
- Format: Decimal (VD: 2.5, 6.5)
- Validation: Required khi có tên

### 4. **Mô tả** (Optional)
- Type: Text input
- Placeholder: "Mô tả (optional)"
- Example: "Trường đại học công nghệ hàng đầu"

---

## 🎨 UI Layout

**Location:** Sidebar phải, dưới phần "Tiện nghi"

```
┌─────────────────────────────────────┐
│ Khu vực xung quanh 🗺️               │
├─────────────────────────────────────┤
│ ┌───────────────────────────────┐   │
│ │ Địa điểm #1              [Xóa]│   │
│ ├───────────────────────────────┤   │
│ │ Tên: Đại học FPT             │   │
│ │ Loại: 🎓 Đại học             │   │
│ │ Cách: 2.5 km                 │   │
│ │ Mô tả: Trường công nghệ...   │   │
│ └───────────────────────────────┘   │
│                                     │
│ ┌───────────────────────────────┐   │
│ │ Địa điểm #2              [Xóa]│   │
│ ├───────────────────────────────┤   │
│ │ Tên: Siêu thị Co.opmart      │   │
│ │ Loại: 🛒 Siêu thị            │   │
│ │ Cách: 0.8 km                 │   │
│ │ Mô tả: Siêu thị lớn          │   │
│ └───────────────────────────────┘   │
│                                     │
│ [+ Thêm địa điểm]                   │
└─────────────────────────────────────┘
```

---

## 💻 Code Changes

### **File:** `src/app/admin/AdminCreateRoomForm.tsx`

#### 1. **Import**
```typescript
import { uploadImage, uploadMultipleImages, DatabaseNearbyPlace } from "@/lib/supabaseServices";
```

#### 2. **State**
```typescript
const [nearbyPlaces, setNearbyPlaces] = useState<Array<{
  name: string;
  category: DatabaseNearbyPlace['category'];
  distance_km: string;
  description: string;
}>>([{
  name: '',
  category: 'university',
  distance_km: '',
  description: ''
}]);
```

#### 3. **Handlers**
```typescript
const addNearbyPlaceField = () => {
  setNearbyPlaces(prev => [...prev, {
    name: '',
    category: 'university',
    distance_km: '',
    description: ''
  }]);
};

const removeNearbyPlaceField = (idx: number) => {
  setNearbyPlaces(prev => prev.filter((_, i) => i !== idx));
};

const handleNearbyPlaceChange = (idx: number, field: string, value: string) => {
  setNearbyPlaces(prev => prev.map((place, i) => 
    i === idx ? { ...place, [field]: value } : place
  ));
};
```

#### 4. **Submit Logic**
```typescript
// Add nearby places
const validNearbyPlaces = nearbyPlaces.filter(place => 
  place.name.trim() && place.distance_km
);

if (validNearbyPlaces.length > 0 && roomData) {
  const nearbyPlaceInserts = validNearbyPlaces.map(place => ({
    room_id: roomData.id,
    name: place.name.trim(),
    category: place.category,
    distance_km: parseFloat(place.distance_km),
    description: place.description.trim() || null
  }));

  const { error: nearbyPlaceError } = await supabase
    .from('nearby_places')
    .insert(nearbyPlaceInserts);

  if (nearbyPlaceError) console.error('Error adding nearby places:', nearbyPlaceError);
}
```

#### 5. **Form Reset**
```typescript
setNearbyPlaces([{
  name: '',
  category: 'university',
  distance_km: '',
  description: ''
}]);
```

---

## 🔄 Workflow

### **Khi tạo phòng mới:**

1. Admin mở form "Thêm phòng mới"
2. Điền thông tin cơ bản (title, price, địa chỉ...)
3. **Scroll xuống phần "Khu vực xung quanh"** ở sidebar
4. Nhập thông tin địa điểm đầu tiên:
   - Tên: "Đại học FPT"
   - Loại: 🎓 Đại học
   - Cách: 2.5 km
   - Mô tả: "Trường đại học công nghệ hàng đầu"
5. Click "+ Thêm địa điểm" để thêm địa điểm khác
6. Nhập thông tin địa điểm tiếp theo
7. Click "Tạo phòng"
8. System sẽ:
   - Tạo room
   - Thêm amenities
   - Thêm images
   - **Thêm nearby places vào database**
9. Done! ✅

---

## 🎯 Validation Logic

### **Khi submit:**
```typescript
const validNearbyPlaces = nearbyPlaces.filter(place => 
  place.name.trim() && place.distance_km
);
```

**Rules:**
- ✅ Chỉ save các địa điểm có **tên** VÀ **khoảng cách**
- ✅ Bỏ qua các field để trống
- ✅ Description là optional (null nếu để trống)
- ✅ Distance được parse sang float

**Example:**
```javascript
// Valid - Sẽ được save
{ name: "Đại học FPT", category: "university", distance_km: "2.5", description: "" }
→ { name: "Đại học FPT", category: "university", distance_km: 2.5, description: null }

// Invalid - Bị skip
{ name: "", category: "university", distance_km: "2.5", description: "" }
{ name: "Đại học FPT", category: "university", distance_km: "", description: "" }

// Valid - Với description
{ name: "Siêu thị", category: "supermarket", distance_km: "0.8", description: "Siêu thị lớn" }
→ { name: "Siêu thị", category: "supermarket", distance_km: 0.8, description: "Siêu thị lớn" }
```

---

## 🎨 UI Features

### **Card Style**
- Border với rounded corners
- Padding 12px
- Space between fields
- Hover effects

### **Header**
- "Địa điểm #1, #2, #3..."
- Xóa button (hiện khi > 1 địa điểm)
- Text color: neutral-600

### **Add Button**
- Full width
- Dashed border
- Primary color
- "+ Thêm địa điểm" text

### **Input Fields**
- Small size (text-sm)
- Placeholders helpful
- Proper input types

---

## 💡 User Experience

### **Smart Defaults**
- Form mở với 1 địa điểm trống sẵn
- Default category: "university"
- Easy to add more places

### **Easy Management**
- Thêm nhiều địa điểm không giới hạn
- Xóa từng địa điểm dễ dàng
- Không thể xóa địa điểm cuối cùng (phải có ít nhất 1)

### **Flexible**
- Có thể để trống nếu không muốn thêm
- Optional description
- Category với emoji dễ nhận biết

---

## 📊 Example Data

**Admin nhập:**
```
Địa điểm #1:
- Tên: Đại học FPT
- Loại: 🎓 Đại học
- Cách: 2.5 km
- Mô tả: Trường đại học công nghệ hàng đầu

Địa điểm #2:
- Tên: Siêu thị Co.opmart
- Loại: 🛒 Siêu thị
- Cách: 0.8 km
- Mô tả: Siêu thị lớn, đầy đủ tiện ích

Địa điểm #3:
- Tên: Trạm xe buýt số 5
- Loại: 🚌 Trạm xe buýt
- Cách: 0.3 km
- Mô tả: Thuận tiện đi lại
```

**Saved to database:**
```sql
INSERT INTO nearby_places (room_id, name, category, distance_km, description) VALUES
('room-id-123', 'Đại học FPT', 'university', 2.5, 'Trường đại học công nghệ hàng đầu'),
('room-id-123', 'Siêu thị Co.opmart', 'supermarket', 0.8, 'Siêu thị lớn, đầy đủ tiện ích'),
('room-id-123', 'Trạm xe buýt số 5', 'bus_stop', 0.3, 'Thuận tiện đi lại');
```

---

## 🔍 Testing Checklist

- [ ] Form mở với 1 địa điểm trống
- [ ] Có thể thêm nhiều địa điểm
- [ ] Có thể xóa địa điểm (ngoại trừ cuối cùng)
- [ ] Category select hoạt động
- [ ] Distance input chấp nhận decimal
- [ ] Submit với nearby places valid
- [ ] Submit bỏ qua places không đủ thông tin
- [ ] Data saved đúng vào database
- [ ] Form reset sau khi submit
- [ ] UI responsive trên mobile

---

## 🎉 Benefits

### **Cho Admin/Owner:**
- ✅ Dễ dàng thêm thông tin khu vực xung quanh
- ✅ Tất cả trong 1 form, không cần thêm step
- ✅ Visual feedback với emoji
- ✅ Flexible - có thể skip nếu không cần

### **Cho Users:**
- ✅ Thông tin đầy đủ về khu vực
- ✅ Biết chính xác khoảng cách đến các địa điểm
- ✅ Dễ đánh giá tính tiện lợi
- ✅ Quyết định thuê phòng tốt hơn

---

## 📝 Next Steps

Sau khi tạo phòng với nearby places:
1. Data được save vào `nearby_places` table
2. User vào `/phong-tro-detail?id=xxx`
3. Scroll xuống section "Khu vực xung quanh"
4. Thấy danh sách địa điểm vừa thêm
5. Beautiful UI với icons và colors! 🎨

---

## ✨ Summary

Đã thêm thành công chức năng quản lý "Khu vực xung quanh" vào Admin Create Room Form với:
- ✅ UI đẹp, dễ sử dụng
- ✅ Thêm/xóa địa điểm linh hoạt
- ✅ Category với emoji
- ✅ Validation thông minh
- ✅ Auto-save khi tạo phòng
- ✅ Responsive design

Perfect! 🚀

