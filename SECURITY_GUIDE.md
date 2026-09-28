# 🔒 Hướng dẫn Bảo mật cho Project

## ⚠️ QUAN TRỌNG: Bảo vệ Super Admin khỏi việc lộ Token Supabase

Tài liệu này mô tả các biện pháp bảo mật đã được triển khai để bảo vệ hệ thống khỏi việc chiếm quyền super admin.

---

## 🛡️ Các Biện pháp Bảo mật Đã Triển khai

### 1. **Row Level Security (RLS) cho bảng Profiles**

**File:** `database-migrations/secure_profiles_rls.sql`

**Mục đích:** Ngăn chặn người dùng tự thay đổi role của mình thành admin.

**Các bảo vệ:**
- ✅ Users chỉ có thể INSERT profile với role `owner` hoặc `renter`, KHÔNG được set `admin`
- ✅ Users KHÔNG thể UPDATE role của chính họ (ngoại trừ admin)
- ✅ Trigger function `prevent_role_escalation()` tự động chặn mọi attempt thay đổi role
- ✅ CHỈ ADMIN mới có thể thay đổi role của người khác

**Cách áp dụng:**
```sql
-- Chạy trong Supabase SQL Editor
-- Copy và paste nội dung từ database-migrations/secure_profiles_rls.sql
```

---

### 2. **Server-side Middleware Protection**

**File:** `src/middleware.ts`

**Mục đích:** Bảo vệ tất cả admin routes (`/admin/*`) trên server-side TRƯỚC KHI request đến server.

**Các bảo vệ:**
- ✅ Kiểm tra authentication (session)
- ✅ Kiểm tra admin role trong database
- ✅ Tự động redirect nếu không phải admin
- ✅ Chạy trên server, không thể bypass từ client

**Cách hoạt động:**
1. Mọi request đến `/admin/*` đều đi qua middleware
2. Middleware verify session và role trước khi cho phép tiếp tục
3. Nếu không phải admin → redirect về home

---

### 3. **Server-side Supabase Client**

**File:** `src/lib/supabaseServer.ts`

**Mục đích:** Tách biệt server-side và client-side Supabase clients.

**Các tính năng:**
- ✅ `supabaseServer`: Server-side client với anon key (vẫn tuân thủ RLS)
- ✅ `supabaseAdmin`: Server-side client với service role key (chỉ dùng khi cần)
- ✅ `verifyAdminRole()`: Function để verify admin role trên server
- ✅ `getUserProfile()`: Function để lấy user profile an toàn

**Lưu ý:**
- Service role key CHỈ được dùng trong các trường hợp đặc biệt
- KHÔNG BAO GIỜ expose service role key ra client
- KHÔNG BAO GIỜ commit service role key vào git

---

### 4. **Admin Utility Functions**

**File:** `src/lib/adminUtils.ts`

**Mục đích:** Cung cấp các utility functions để verify admin trên server.

**Các functions:**
- ✅ `getServerUser()`: Lấy authenticated user từ cookies (Server Components)
- ✅ `verifyAdmin()`: Verify admin từ Server Component
- ✅ `verifyAdminFromRequest()`: Verify admin từ API route
- ✅ `withAdminAuth()`: Wrapper để tự động verify admin cho API routes

**Ví dụ sử dụng:**
```typescript
// Trong API route
import { withAdminAuth } from "@/lib/adminUtils";

export async function POST(req: NextRequest) {
  return withAdminAuth(req, async (userId) => {
    // Handler logic here - userId đã được verify là admin
    return NextResponse.json({ success: true });
  });
}
```

---

### 5. **Client-side Protection (Đã có sẵn)**

**File:** `src/app/admin/layout.tsx`, `src/app/admin/page.tsx`

**Mục đích:** Bảo vệ client-side (defense in depth).

**Các bảo vệ:**
- ✅ Check `user.role !== "admin"` và redirect
- ✅ Loading states và error handling
- ✅ Không render admin UI nếu không phải admin

**Lưu ý:** Client-side protection có thể bị bypass, đó là lý do cần middleware và RLS.

---

## 📋 Checklist Bảo mật

### ✅ Đã triển khai

- [x] RLS policies cho bảng profiles
- [x] Trigger function ngăn chặn role escalation
- [x] Server-side middleware protection
- [x] Server-side Supabase client
- [x] Admin utility functions
- [x] Client-side protection (đã có)

### ⚠️ Cần kiểm tra

- [ ] Đã chạy migration `secure_profiles_rls.sql` trong Supabase
- [ ] Đã setup environment variables an toàn
- [ ] Đã verify middleware hoạt động đúng
- [ ] Đã test các admin routes với non-admin users
- [ ] Đã test việc thay đổi role (phải bị chặn)

---

## 🔧 Setup và Cài đặt

### Bước 1: Chạy Database Migration

1. Mở Supabase Dashboard → SQL Editor
2. Copy nội dung từ `database-migrations/secure_profiles_rls.sql`
3. Paste và chạy
4. Verify policies đã được tạo:
   ```sql
   SELECT policyname FROM pg_policies WHERE tablename = 'profiles';
   ```

### Bước 2: Setup Environment Variables

**File:** `.env.local` (KHÔNG commit vào git)

```env
# Public keys (có thể expose)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key

# Service role key (KHÔNG BAO GIỜ expose)
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

**QUAN TRỌNG:**
- ✅ Anon key có thể expose (đã được bảo vệ bởi RLS)
- ❌ Service role key KHÔNG BAO GIỜ expose
- ❌ KHÔNG commit `.env.local` vào git
- ✅ Thêm `.env.local` vào `.gitignore`

### Bước 3: Verify Dependencies

```bash
npm install @supabase/ssr @supabase/auth-helpers-nextjs
```

Nếu chưa có, cài đặt:
```bash
npm install @supabase/ssr@latest @supabase/auth-helpers-nextjs@latest
```

---

## 🧪 Testing

### Test 1: Ngăn chặn tự thay đổi role

```sql
-- Test với user không phải admin
-- Phải bị lỗi
UPDATE profiles SET role = 'admin' WHERE id = auth.uid();
-- Expected: ERROR: Permission denied: Only admins can change user roles
```

### Test 2: Middleware protection

1. Đăng nhập với user thường
2. Truy cập `/admin`
3. Expected: Redirect về `/` hoặc `/login`

### Test 3: API route protection

```bash
# Test với non-admin token
curl -H "Authorization: Bearer <non-admin-token>" http://localhost:3000/api/admin/verify
# Expected: { "isAdmin": false, "error": "..." }
```

---

## 🚨 Rủi ro và Cách Xử lý

### Rủi ro 1: Token Supabase bị lộ

**Tình huống:** Nếu anon key bị lộ (trong code, logs, etc.)

**Giải pháp:**
- ✅ RLS policies vẫn bảo vệ (user không thể tự thay đổi role)
- ✅ Middleware vẫn verify admin role
- ✅ Service role key không được expose (nếu setup đúng)

**Action:** Rotate keys trong Supabase Dashboard nếu cần

### Rủi ro 2: Service role key bị lộ

**Tình huống:** Service role key bị commit vào git hoặc expose

**Giải pháp:**
- ✅ Rotate service role key NGAY LẬP TỨC
- ✅ Xóa key cũ trong Supabase Dashboard
- ✅ Update `.env.local` với key mới
- ✅ Kiểm tra git history và xóa nếu đã commit

**Action:** 
1. Supabase Dashboard → Settings → API
2. Rotate service role key
3. Update environment variables

### Rủi ro 3: Admin account bị compromise

**Tình huống:** Admin account bị hack

**Giải pháp:**
- ✅ Thay đổi password ngay lập tức
- ✅ Kiểm tra audit logs
- ✅ Revoke session hiện tại
- ✅ Kiểm tra các thay đổi trong database

**Action:**
```sql
-- Revoke all sessions cho user
DELETE FROM auth.sessions WHERE user_id = '<compromised-user-id>';

-- Kiểm tra các thay đổi gần đây
SELECT * FROM profiles WHERE id = '<compromised-user-id>';
```

---

## 📚 Best Practices

### 1. Environment Variables

- ✅ Sử dụng `.env.local` cho local development
- ✅ Sử dụng environment variables của hosting platform (Vercel, etc.)
- ❌ KHÔNG commit `.env` files
- ❌ KHÔNG hardcode keys trong code

### 2. RLS Policies

- ✅ Luôn enable RLS cho các bảng quan trọng
- ✅ Test policies với các user roles khác nhau
- ✅ Review policies định kỳ

### 3. API Routes

- ✅ Luôn verify admin trên server-side
- ✅ Sử dụng `withAdminAuth()` wrapper
- ✅ Return error messages rõ ràng

### 4. Monitoring

- ✅ Log các admin actions
- ✅ Monitor các thay đổi role
- ✅ Set up alerts cho suspicious activities

---

## 🔍 Troubleshooting

### Lỗi: "Permission denied" khi truy cập admin

**Nguyên nhân:** User không phải admin hoặc RLS policy chặn

**Giải pháp:**
1. Kiểm tra role trong database:
   ```sql
   SELECT role FROM profiles WHERE id = auth.uid();
   ```
2. Nếu cần set admin (chỉ dùng trong development):
   ```sql
   -- CHỈ CHẠY VỚI SUPER ADMIN HOẶC TRONG DEVELOPMENT
   UPDATE profiles SET role = 'admin' WHERE id = '<user-id>';
   ```

### Lỗi: Middleware không hoạt động

**Nguyên nhân:** Dependencies chưa cài đặt hoặc config sai

**Giải pháp:**
1. Kiểm tra dependencies:
   ```bash
   npm list @supabase/ssr @supabase/auth-helpers-nextjs
   ```
2. Verify middleware file ở đúng vị trí: `src/middleware.ts`
3. Restart dev server

### Lỗi: RLS policies không hoạt động

**Nguyên nhân:** Policies chưa được tạo hoặc bị disable

**Giải pháp:**
1. Kiểm tra RLS đã enable:
   ```sql
   SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'profiles';
   ```
2. Kiểm tra policies:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'profiles';
   ```
3. Chạy lại migration nếu cần

---

## 📞 Support

Nếu gặp vấn đề về bảo mật, vui lòng:
1. Review lại documentation này
2. Kiểm tra Supabase logs
3. Test với các scenarios khác nhau
4. Contact team nếu cần

---

## ✅ Summary

Với các biện pháp bảo mật đã triển khai:

1. ✅ **RLS Policies** ngăn chặn tự thay đổi role
2. ✅ **Middleware** bảo vệ admin routes trên server
3. ✅ **Server-side verification** cho tất cả admin operations
4. ✅ **Client-side protection** (defense in depth)

**Ngay cả khi token Supabase bị lộ, attacker vẫn KHÔNG THỂ tự thay đổi role thành admin** vì:
- RLS policies chặn UPDATE role
- Trigger function chặn role escalation
- Middleware verify admin role trên server
- Service role key không được expose

Hệ thống đã được bảo vệ đầy đủ! 🛡️

