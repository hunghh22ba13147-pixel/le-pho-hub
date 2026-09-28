# 🔔 Notification Features - Chi tiết tính năng

## 📍 Vị trí hiển thị

### Navbar Dropdown
```
┌─────────────────────────────────────────┐
│  Logo    Menu    Search    🔔 [3] 👤    │  ← Icon chuông với badge đếm
└─────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │ Thông báo      3 mới│
                    ├─────────────────────┤
                    │ 🔵 Thông báo 1  •   │
                    │ 🟡 Thông báo 2  •   │  
                    │ 🟢 Thông báo 3  •   │
                    │ ⚪ Thông báo 4      │
                    ├─────────────────────┤
                    │ Đánh dấu tất cả ... │
                    └─────────────────────┘
```

## 🎨 UI/UX Features

### 1. Badge đếm thông báo
- **Hiển thị:** Số thông báo chưa đọc
- **Format:** 1, 2, 3... 9, 9+ (nếu > 9)
- **Màu:** Primary color (đỏ/xanh)
- **Vị trí:** Top-right của icon chuông

### 2. Dropdown Panel
- **Width:** Responsive (max-width: sm)
- **Height:** Tối đa 96 (scrollable)
- **Sticky header:** "Thông báo" + badge
- **Sticky footer:** "Đánh dấu tất cả đã đọc"

### 3. Notification Item
**Chưa đọc:**
- Background: Primary light (xanh nhạt)
- Dot indicator: Chấm tròn primary
- Hover: Darker primary

**Đã đọc:**
- Background: Transparent
- No dot indicator
- Hover: Gray

### 4. Icons theo loại
| Loại | Icon | Màu |
|------|------|-----|
| Info | ℹ️ Information | Xanh dương |
| Warning | ⚠️ Warning | Vàng |
| Success | ✅ Check | Xanh lá |
| Error | ❌ Error | Đỏ |

### 5. Thời gian hiển thị
- **< 1 phút:** "vừa xong"
- **< 1 giờ:** "X phút trước"
- **< 1 ngày:** "X giờ trước"
- **< 1 tuần:** "X ngày trước"
- **< 1 tháng:** "X tuần trước"
- **< 1 năm:** "X tháng trước"
- **>= 1 năm:** "X năm trước"

### 6. Loading State
- Spinner animation
- Text: "Đang tải..."
- Centered

### 7. Empty State
- Icon: Chuông lớn (gray)
- Text: "Chưa có thông báo nào"
- Centered

## 🔄 User Interactions

### Click vào notification
1. Đánh dấu thông báo đã đọc
2. Badge count giảm đi 1
3. Background color thay đổi
4. Dot indicator biến mất
5. Save state vào localStorage

### Click "Đánh dấu tất cả đã đọc"
1. Tất cả notifications → đã đọc
2. Badge count → 0
3. Tất cả backgrounds → transparent
4. Save state vào localStorage

### Auto-load
- Load khi user login
- Load khi component mount
- Filter theo role của user

## 💾 Local Storage

### Key: `readNotifications`
**Format:** JSON array of notification IDs
```json
["uuid-1", "uuid-2", "uuid-3"]
```

**Purpose:**
- Track thông báo đã đọc
- Persist across page refreshes
- Clear khi logout (optional)

## 🎯 User Role Filtering

### Admin tạo notification với target_audience:
- **all** → Tất cả users thấy
- **renters** → Chỉ người thuê thấy
- **owners** → Chỉ chủ nhà thấy
- **admins** → Chỉ admin thấy

### Ví dụ:
```typescript
User role: "renter"
Notifications shown:
- target_audience = "all" ✅
- target_audience = "renters" ✅
- target_audience = "owners" ❌
- target_audience = "admins" ❌
```

## 🚀 Performance

### Optimization
- ✅ Lazy loading với dynamic import
- ✅ Memoization của read notifications
- ✅ Efficient re-renders
- ✅ LocalStorage caching

### Network
- Load notifications on mount
- No polling (manual refresh needed)
- Future: Real-time với Supabase subscriptions

## 📱 Responsive Design

### Desktop (> 768px)
- Icon chuông: 48px × 48px
- Dropdown width: 448px (sm)
- Position: Right aligned

### Mobile (< 768px)
- Icon chuông: 40px × 40px
- Dropdown width: 100vw - padding
- Position: Full width below icon

## 🎨 Dark Mode Support

### Light Mode
- Background: White
- Text: Dark gray
- Hover: Light gray

### Dark Mode
- Background: Dark neutral
- Text: Light gray
- Hover: Darker neutral

## 🔒 Security

### Data Access
- RLS policies kiểm soát access
- Chỉ load notifications cho role phù hợp
- No XSS với proper escaping

### Privacy
- Read status lưu local (không lưu DB)
- Không track user behavior
- Không có analytics

## 🧪 Testing Checklist

- [ ] Badge đếm đúng số lượng
- [ ] Click notification → mark as read
- [ ] Click "Đánh dấu tất cả" → tất cả read
- [ ] Reload page → state persist
- [ ] Filter đúng theo role
- [ ] Icons hiển thị đúng màu
- [ ] Time ago format đúng
- [ ] Loading state hoạt động
- [ ] Empty state hiển thị
- [ ] Dark mode hoạt động
- [ ] Responsive trên mobile
- [ ] Scroll khi nhiều notifications

## 🎉 Future Enhancements

- [ ] Real-time updates (Supabase subscriptions)
- [ ] Sound notification
- [ ] Desktop push notifications
- [ ] Mark as unread
- [ ] Archive notifications
- [ ] Search/filter notifications
- [ ] Notification preferences
- [ ] Rich content (images, links)
- [ ] Actions in notifications (buttons)
- [ ] Notification groups/categories

