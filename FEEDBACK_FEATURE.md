# 💬 Feedback/Review Feature Documentation

## ✅ Đã hoàn thành

Thêm chức năng đánh giá và phản hồi cho trang phòng trọ chi tiết (`/phong-tro-detail`) với đầy đủ tính năng CRUD.

---

## 🎯 Tính năng chính

### 1. **Đánh giá sao (Star Rating)**
   - ⭐ 1-5 sao với hover effect
   - ⭐ Label mô tả: Rất tệ, Tệ, Trung bình, Tốt, Rất tốt
   - ⭐ Hiển thị điểm trung bình và tổng số đánh giá

### 2. **Viết đánh giá**
   - ✍️ Form với rating và comment
   - ✍️ Validation: min 10 ký tự, max 500 ký tự
   - ✍️ Chỉ đăng nhập mới được viết
   - ✍️ Mỗi user chỉ đánh giá 1 lần cho mỗi phòng

### 3. **Quản lý đánh giá**
   - ✏️ Sửa đánh giá của bản thân
   - 🗑️ Xóa đánh giá của bản thân
   - 👀 Xem tất cả đánh giá từ người khác

### 4. **Hiển thị đánh giá**
   - 📊 Điểm trung bình và tổng số đánh giá ở đầu section
   - 👤 Avatar và tên người đánh giá
   - 🏷️ Badge cho role (Admin, Chủ trọ)
   - 📅 Thời gian đánh giá (relative: "2 ngày trước", "1 tuần trước")
   - 💬 Nội dung đánh giá

---

## 📁 Files đã tạo/sửa

### 1. **Database Migration**
**File:** `database-migrations/feedbacks_table.sql`

```sql
CREATE TABLE public.feedbacks (
    id UUID PRIMARY KEY,
    room_id UUID REFERENCES rooms(id),
    user_id UUID REFERENCES auth.users(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT unique_user_room_feedback UNIQUE (room_id, user_id)
);
```

**Features:**
- ✅ Unique constraint: 1 user chỉ 1 feedback per room
- ✅ Rating validation: 1-5
- ✅ Row Level Security policies
- ✅ Auto update timestamp trigger
- ✅ Indexes cho performance

---

### 2. **Service Functions**
**File:** `src/lib/supabaseServices.ts`

**Interfaces:**
```typescript
export interface DatabaseFeedback {
  id: string;
  room_id: string;
  user_id: string;
  rating: number;
  comment: string;
  created_at: string;
  updated_at: string;
}

export interface FeedbackWithUser extends DatabaseFeedback {
  profiles: {
    name: string;
    role: 'owner' | 'renter' | 'admin';
  };
}
```

**Functions:**
1. `fetchRoomFeedbacks(roomId)` - Lấy tất cả feedbacks của phòng
2. `getRoomAverageRating(roomId)` - Tính điểm trung bình
3. `createFeedback(feedback)` - Tạo feedback mới
4. `updateFeedback(feedbackId, updates)` - Cập nhật feedback
5. `deleteFeedback(feedbackId)` - Xóa feedback
6. `hasUserFeedback(roomId)` - Kiểm tra user đã đánh giá chưa

---

### 3. **UI Components**

#### **FeedbackItem.tsx**
**File:** `src/components/FeedbackItem.tsx`

**Props:**
```typescript
interface FeedbackItemProps {
  feedback: FeedbackWithUser;
  onDelete?: (feedbackId: string) => void;
  onEdit?: (feedbackId: string) => void;
  isOwnFeedback?: boolean;
}
```

**Features:**
- ✅ Avatar với userName
- ✅ Star rating display
- ✅ Time ago format
- ✅ Role badges (Admin, Chủ trọ)
- ✅ Edit/Delete buttons cho own feedback
- ✅ Beautiful card design với hover effect

---

#### **FeedbackForm.tsx**
**File:** `src/components/FeedbackForm.tsx`

**Props:**
```typescript
interface FeedbackFormProps {
  roomId: string;
  onSubmit: (rating: number, comment: string) => Promise<void>;
  onCancel?: () => void;
  isEditing?: boolean;
  initialData?: DatabaseFeedback;
}
```

**Features:**
- ⭐ Interactive star rating với hover
- 📝 Textarea với character counter (10-500)
- ✅ Client-side validation
- 🎨 Error messages
- 🔄 Loading states
- ✏️ Support edit mode với initialData

---

### 4. **Integration vào phong-tro-detail**
**File:** `src/app/(listing-detail)/phong-tro-detail/page.tsx`

**State Management:**
```typescript
const [feedbacks, setFeedbacks] = useState<FeedbackWithUser[]>([]);
const [averageRating, setAverageRating] = useState<number>(0);
const [totalFeedbacks, setTotalFeedbacks] = useState<number>(0);
const [userFeedback, setUserFeedback] = useState<DatabaseFeedback | null>(null);
const [showFeedbackForm, setShowFeedbackForm] = useState(false);
const [isEditingFeedback, setIsEditingFeedback] = useState(false);
const [feedbackLoading, setFeedbackLoading] = useState(false);
```

**Functions:**
- `loadFeedbacks(roomId)` - Load all feedback data
- `handleSubmitFeedback(rating, comment)` - Submit new feedback
- `handleUpdateFeedback(rating, comment)` - Update existing feedback
- `handleDeleteFeedback(feedbackId)` - Delete feedback
- `handleEditFeedback(feedbackId)` - Show edit form

**Render:**
- `renderSectionFeedback()` - Main feedback section
  - Header với average rating
  - "Viết đánh giá" button (if not logged in or no feedback)
  - Feedback form (when shown)
  - User's own feedback (highlighted)
  - All other feedbacks

---

## 🎨 UI/UX Design

### **Section Header**
```
┌─────────────────────────────────────────────┐
│ Đánh giá từ khách thuê                      │
│ ⭐ 4.5 (12 đánh giá)  [Viết đánh giá]       │
└─────────────────────────────────────────────┘
```

### **Feedback Form** (khi mở)
```
┌─────────────────────────────────────────────┐
│ Viết đánh giá của bạn                       │
│                                             │
│ Đánh giá của bạn *                          │
│ ☆ ☆ ☆ ☆ ☆  (hover để chọn)                 │
│                                             │
│ Nhận xét của bạn *                          │
│ ┌─────────────────────────────────────┐    │
│ │ Chia sẻ trải nghiệm của bạn...      │    │
│ │                                     │    │
│ └─────────────────────────────────────┘    │
│ Tối thiểu 10 ký tự          0/500           │
│                                             │
│ [Gửi đánh giá]  [Hủy]                       │
└─────────────────────────────────────────────┘
```

### **Feedback Item**
```
┌─────────────────────────────────────────────┐
│ 👤 Nguyễn Văn A    [Admin]                  │
│    ⭐⭐⭐⭐⭐  2 ngày trước                    │
│                                             │
│    Phòng rất đẹp, chủ trọ nhiệt tình...     │
│                                  [Sửa] [Xóa]│
└─────────────────────────────────────────────┘
```

---

## 🔐 Security & Validation

### **Database Level**
- ✅ Row Level Security (RLS) enabled
- ✅ Users can only edit/delete their own feedbacks
- ✅ Unique constraint: 1 feedback per user per room
- ✅ Rating validation: CHECK (rating >= 1 AND rating <= 5)

### **Application Level**
- ✅ Authentication required để viết đánh giá
- ✅ Client-side validation:
  - Rating: required, 1-5
  - Comment: min 10, max 500 characters
- ✅ Server-side validation in service functions
- ✅ Prevent duplicate feedbacks per user/room

### **UI Level**
- ✅ Disable form khi đang submit
- ✅ Show error messages
- ✅ Confirm dialog khi xóa
- ✅ Hide edit/delete buttons cho feedbacks của người khác

---

## 📊 Data Flow

### **Load Feedbacks**
```
1. User visits phong-tro-detail page
2. useEffect → loadFeedbacks(roomId)
3. Fetch feedbacks, average rating, user's feedback
4. Update states
5. Render feedback section
```

### **Create Feedback**
```
1. User clicks "Viết đánh giá"
2. Show form
3. User fills rating + comment
4. Submit → createFeedback()
5. Check: user logged in? already has feedback?
6. Insert to database
7. Reload feedbacks
8. Hide form
```

### **Update Feedback**
```
1. User clicks "Sửa" on own feedback
2. Show form với initialData
3. User edits rating + comment
4. Submit → updateFeedback()
5. Update database
6. Reload feedbacks
7. Hide form
```

### **Delete Feedback**
```
1. User clicks "Xóa" on own feedback
2. Confirm dialog
3. If confirmed → deleteFeedback()
4. Delete from database
5. Reload feedbacks
```

---

## 🎯 Features Breakdown

### **1. Rating System**
- **Input:** Interactive star icons
- **Display:** Filled stars for rating
- **Average:** Calculated từ all feedbacks
- **Counter:** Total số lượng đánh giá

### **2. Comment System**
- **Input:** Textarea với validation
- **Display:** Text với line breaks preserved
- **Length:** Min 10, max 500 characters
- **Counter:** Real-time character count

### **3. Time Display**
- **Format:** Relative time ago
  - "Hôm nay"
  - "Hôm qua"
  - "3 ngày trước"
  - "2 tuần trước"
  - "1 tháng trước"
  - Or: dd/mm/yyyy nếu > 1 năm

### **4. User Identification**
- **Avatar:** Generated từ username
- **Name:** Display name
- **Role Badge:**
  - 🔵 Admin
  - 🟢 Chủ trọ
  - (No badge for renters)

---

## 🧪 Testing Checklist

### **Create Feedback**
- [ ] User chưa đăng nhập → Show message "Đăng nhập để viết đánh giá"
- [ ] User đã đăng nhập, chưa có feedback → Show "Viết đánh giá" button
- [ ] Click button → Show form
- [ ] Submit without rating → Error: "Vui lòng chọn số sao"
- [ ] Submit với comment < 10 chars → Error
- [ ] Submit với comment > 500 chars → Error
- [ ] Submit valid → Success, reload feedbacks

### **Update Feedback**
- [ ] User có feedback → Show own feedback với "Sửa" button
- [ ] Click "Sửa" → Show form với data hiện tại
- [ ] Edit và submit → Success, reload feedbacks

### **Delete Feedback**
- [ ] Click "Xóa" → Show confirm dialog
- [ ] Confirm → Delete và reload feedbacks
- [ ] Cancel → No action

### **Display**
- [ ] Show average rating correctly
- [ ] Show total count correctly
- [ ] Own feedback highlighted separately
- [ ] Other feedbacks listed
- [ ] Time ago format correct
- [ ] Role badges show correctly

### **Edge Cases**
- [ ] No feedbacks yet → Show empty state
- [ ] User already has feedback → Can't create new, only edit
- [ ] Loading states show correctly
- [ ] Error handling works

---

## 💡 Best Practices Applied

### **1. State Management**
- ✅ Clear separation of concerns
- ✅ Loading states for async operations
- ✅ Error handling với user-friendly messages

### **2. Component Design**
- ✅ Reusable components (FeedbackItem, FeedbackForm)
- ✅ Props interface với TypeScript
- ✅ Conditional rendering based on state

### **3. Data Fetching**
- ✅ Load feedbacks khi room changes
- ✅ Reload sau mỗi CRUD operation
- ✅ Separate functions cho clarity

### **4. User Experience**
- ✅ Clear visual feedback
- ✅ Helpful error messages
- ✅ Confirmation dialogs
- ✅ Loading indicators
- ✅ Disabled states during submission

### **5. Security**
- ✅ Authentication checks
- ✅ Authorization (own feedback only)
- ✅ Input validation
- ✅ SQL injection protection (via Supabase)

---

## 🚀 Usage Instructions

### **Cho Admin:**
1. Vào Supabase Dashboard
2. Chạy SQL migration: `database-migrations/feedbacks_table.sql`
3. Verify table được tạo với RLS policies

### **Cho Developer:**
1. Import các service functions từ `supabaseServices.ts`
2. Sử dụng `FeedbackItem` và `FeedbackForm` components
3. Integrate vào bất kỳ detail page nào

### **Cho User:**
1. Vào trang chi tiết phòng: `/phong-tro-detail?id=xxx`
2. Đăng nhập nếu chưa
3. Click "Viết đánh giá"
4. Chọn số sao và viết nhận xét
5. Submit
6. Có thể sửa hoặc xóa sau

---

## 📈 Future Enhancements

### **Potential Features:**
- [ ] 📸 Upload ảnh kèm đánh giá
- [ ] 👍 Like/helpful vote cho feedbacks
- [ ] 💬 Reply/comment to feedbacks
- [ ] 🔔 Notification khi có feedback mới
- [ ] 📊 Analytics dashboard cho admin
- [ ] 🏆 Top reviewers badge
- [ ] 🔍 Filter/sort feedbacks
- [ ] 📄 Pagination cho many feedbacks

---

## 🎉 Summary

Chức năng feedback đã hoàn thành với:
- ✅ Full CRUD operations
- ✅ Beautiful UI/UX
- ✅ Security & validation
- ✅ Error handling
- ✅ Loading states
- ✅ TypeScript support
- ✅ Responsive design

Ready to use! 🚀

