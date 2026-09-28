# ❤️ Wishlist/Savelist Feature - Phòng Yêu Thích

## ✅ Đã hoàn thành

Thêm chức năng lưu phòng yêu thích (wishlist/savelist) với Supabase, cho phép người dùng lưu các phòng trọ yêu thích và xem trong tài khoản.

---

## 🎯 Tính năng

### **User Features**
- ❤️ **Lưu phòng yêu thích** - Click icon trái tim để lưu/bỏ lưu
- 👀 **Xem danh sách** - Vào `/account-savelists` để xem tất cả phòng đã lưu
- 🔄 **Realtime update** - Icon thay đổi ngay khi lưu/bỏ lưu
- 🔒 **Đăng nhập required** - Phải login mới lưu được
- 📱 **Share button** - Chia sẻ phòng qua native share hoặc copy link

---

## 📁 Files đã tạo/sửa

### 1. **Database Migration**
**File:** `database-migrations/favorites_table.sql`

**Table Structure:**
```sql
CREATE TABLE public.favorites (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    room_id UUID REFERENCES rooms(id),
    created_at TIMESTAMP,
    CONSTRAINT unique_user_room_favorite UNIQUE (user_id, room_id)
);
```

**Features:**
- ✅ Unique constraint: 1 user chỉ lưu 1 lần mỗi phòng
- ✅ Foreign keys to users và rooms
- ✅ Cascade delete khi xóa user/room
- ✅ Row Level Security policies
- ✅ Indexes for performance

---

### 2. **Service Functions** (Already Exists)
**File:** `src/lib/supabaseServices.ts`

Functions đã có sẵn:
1. **`addToWishlist(roomId)`** - Thêm phòng vào wishlist
2. **`removeFromWishlist(roomId)`** - Xóa phòng khỏi wishlist
3. **`isInWishlist(roomId)`** - Kiểm tra phòng đã trong wishlist chưa
4. **`fetchWishlistRooms()`** - Lấy tất cả phòng đã lưu

---

### 3. **LikeSaveBtns Component**
**File:** `src/components/LikeSaveBtns.tsx`

**Changes:** Từ static UI → Full functional component

**Features:**
- ✅ Check wishlist status khi load
- ✅ Toggle save/unsave với click
- ✅ Icon thay đổi: HeartIcon (outline) → HeartIconSolid (filled)
- ✅ Color thay đổi: gray → red khi saved
- ✅ Loading states (checking, toggling)
- ✅ Error handling với alerts
- ✅ Share functionality (native share hoặc copy link)

**Props:**
```typescript
interface LikeSaveBtnsProps {
  roomId?: string;
  className?: string;
}
```

**States:**
```typescript
const [isSaved, setIsSaved] = useState(false);
const [loading, setLoading] = useState(false);
const [checking, setChecking] = useState(true);
```

---

### 4. **Integration vào phong-tro-detail**
**File:** `src/app/(listing-detail)/phong-tro-detail/page.tsx`

**Change:**
```tsx
// Before
<LikeSaveBtns />

// After
<LikeSaveBtns roomId={String(roomData?.id)} />
```

---

### 5. **Account Savelists Page** (Already Good!)
**File:** `src/app/(account-pages)/account-savelists/page.tsx`

**Features:**
- ✅ Load wishlist rooms khi mount
- ✅ Display với StayCard grid
- ✅ Empty state với icon và CTA
- ✅ Loading state
- ✅ "Xem thêm" pagination
- ✅ Redirect to login nếu chưa đăng nhập

---

## 🎨 UI/UX

### **LikeSaveBtns Component**

**Layout:**
```
┌─────────────────────────────────┐
│ [📤 Chia sẻ] [❤️ Lưu/Đã lưu]   │
└─────────────────────────────────┘
```

**States:**

1. **Not Saved (Default)**
   - Icon: HeartIcon (outline)
   - Color: neutral-700
   - Text: "Lưu"

2. **Saved**
   - Icon: HeartIconSolid (filled)
   - Color: red-600
   - Text: "Đã lưu"

3. **Loading**
   - Icon: Spinner animation
   - Text: "Đang xử lý..."
   - Disabled state

4. **Checking**
   - Icon: Spinner (small)
   - Disabled state

---

### **Account Savelists Page**

**Header:**
```
Danh sách yêu thích
X phòng đã lưu
─────────────────
[Phòng đã lưu]
```

**Grid Display:**
```
┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│Room1│ │Room2│ │Room3│ │Room4│
└─────┘ └─────┘ └─────┘ └─────┘
┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
│Room5│ │Room6│ │Room7│ │Room8│
└─────┘ └─────┘ └─────┘ └─────┘

        [Xem thêm]
```

**Empty State:**
```
        ❤️
   Chưa có phòng yêu thích
Bắt đầu lưu các phòng trọ bạn thích
        để xem sau
        
    [Khám phá phòng trọ]
```

---

## 🔄 User Flow

### **Save a Room**
1. User vào `/phong-tro-detail?id=xxx`
2. Thấy section đầu với icon trái tim outline
3. Click vào icon trái tim
4. **If not logged in:**
   - Alert: "Vui lòng đăng nhập để lưu phòng yêu thích"
5. **If logged in:**
   - Loading spinner hiện
   - Call `addToWishlist(roomId)`
   - Icon đổi thành filled heart màu đỏ
   - Text đổi thành "Đã lưu"
   - Success! ✅

### **Unsave a Room**
1. User thấy icon filled heart màu đỏ
2. Click vào icon
3. Loading spinner hiện
4. Call `removeFromWishlist(roomId)`
5. Icon đổi về outline heart màu gray
6. Text đổi thành "Lưu"
7. Removed! ✅

### **View Saved Rooms**
1. User vào `/account-savelists`
2. **If not logged in:**
   - Redirect to `/login`
3. **If logged in:**
   - Loading spinner hiện
   - Call `fetchWishlistRooms()`
   - Display grid of saved rooms
   - Each room là StayCard component
4. Click vào room → Navigate to detail page
5. Can unsave from detail page

---

## 🔐 Security & Validation

### **Database Level**
- ✅ Row Level Security enabled
- ✅ Users can only view/edit their own favorites
- ✅ Unique constraint prevents duplicates
- ✅ Foreign key constraints ensure data integrity

### **Application Level**
- ✅ Authentication check before save/unsave
- ✅ RoomId validation
- ✅ Error handling for all operations
- ✅ User feedback via alerts

### **UI Level**
- ✅ Disable buttons during loading
- ✅ Check login status before action
- ✅ Visual feedback (loading spinners)
- ✅ Clear error messages

---

## 📊 Data Flow

### **Check Wishlist Status**
```
1. Component mounts
2. If user && roomId:
   → isInWishlist(roomId)
   → setIsSaved(result)
3. Else:
   → setIsSaved(false)
4. setChecking(false)
```

### **Toggle Wishlist**
```
1. User clicks heart icon
2. Check: user logged in?
   → No: Alert + return
   → Yes: Continue
3. If isSaved:
   → removeFromWishlist(roomId)
   → setIsSaved(false)
4. Else:
   → addToWishlist(roomId)
   → setIsSaved(true)
5. Handle errors
```

### **Fetch Wishlist Rooms**
```
1. User navigates to /account-savelists
2. Check: user logged in?
   → No: Redirect to /login
   → Yes: Continue
3. fetchWishlistRooms()
4. Map to StayDataType[]
5. Display in grid
```

---

## 💡 Additional Features

### **Share Button**
- 🌐 **Native Share API** (if supported)
  - Title: "Phòng trọ"
  - Text: "Xem phòng trọ này"
  - URL: Current page URL
- 📋 **Fallback: Copy to Clipboard**
  - Copy current URL
  - Alert: "Đã copy link!"

---

## 🧪 Testing Checklist

### **LikeSaveBtns Component**
- [ ] Component renders with correct initial state
- [ ] Checking state shows spinner
- [ ] isInWishlist() called on mount
- [ ] Click save → calls addToWishlist()
- [ ] Click unsave → calls removeFromWishlist()
- [ ] Icon changes from outline to filled
- [ ] Color changes to red when saved
- [ ] Loading state shows spinner
- [ ] Error handling works
- [ ] Alert shows when not logged in
- [ ] Share button works (both native and fallback)

### **Database**
- [ ] favorites table created successfully
- [ ] Unique constraint prevents duplicates
- [ ] RLS policies work correctly
- [ ] Foreign keys cascade delete

### **Account Savelists Page**
- [ ] Redirects to /login when not authenticated
- [ ] Loads wishlist rooms correctly
- [ ] Empty state displays when no rooms
- [ ] Grid displays rooms with StayCard
- [ ] "Xem thêm" pagination works
- [ ] Loading state shows spinner

### **Integration**
- [ ] Save room from detail page
- [ ] Room appears in account-savelists
- [ ] Unsave from detail page
- [ ] Room disappears from account-savelists
- [ ] State persists across page reloads

---

## 🎯 Example Usage

### **Step 1: Setup Database**
```sql
-- Run this in Supabase SQL Editor
-- File: database-migrations/favorites_table.sql
```

### **Step 2: Use in Detail Page**
```tsx
// In phong-tro-detail page
<LikeSaveBtns roomId={String(roomData?.id)} />
```

### **Step 3: User Interaction**
```
User clicks ❤️ → Saves to favorites
User goes to /account-savelists → Sees saved room
User clicks ❤️ again → Removes from favorites
```

---

## 📈 Future Enhancements

### **Potential Features:**
- [ ] 🔔 Notification khi phòng đã lưu có giá mới
- [ ] 📊 Analytics: Most saved rooms
- [ ] 🏷️ Organize savelists into folders/tags
- [ ] 💬 Add notes to saved rooms
- [ ] 📧 Email digest of saved rooms
- [ ] 🔗 Share entire wishlist with others
- [ ] ⭐ Priority/rating for saved rooms
- [ ] 📅 Remind me later feature
- [ ] 🔄 Export wishlist to PDF/Excel

---

## 🎉 Summary

Chức năng Wishlist đã hoàn thành với:
- ✅ Database table với RLS
- ✅ Service functions đầy đủ
- ✅ Functional LikeSaveBtns component
- ✅ Integration vào detail page
- ✅ Account savelists page
- ✅ Loading & error states
- ✅ Authentication checks
- ✅ Share functionality
- ✅ Beautiful UI/UX

**User Benefits:**
- ❤️ Save favorite rooms easily
- 👀 View all saved rooms in one place
- 🔄 Realtime updates
- 📱 Share rooms with friends
- 🎨 Beautiful visual feedback

Ready to use! 🚀

---

## 📝 Quick Start

### **For Users:**
1. Browse rooms at `/phong-tro`
2. Click on a room to view details
3. Click ❤️ icon to save (login required)
4. Go to Account → Savelists to view all saved rooms
5. Click ❤️ again to remove from favorites

### **For Developers:**
1. Run database migration: `favorites_table.sql`
2. Component already integrated
3. Test save/unsave functionality
4. Verify account-savelists page

Perfect! ❤️

