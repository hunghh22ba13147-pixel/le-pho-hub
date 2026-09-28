# 🚀 Hướng dẫn Setup Bảo mật

## Bước 1: Chạy Database Migration

**QUAN TRỌNG:** Đây là bước đầu tiên và quan trọng nhất!

1. Mở Supabase Dashboard
2. Vào SQL Editor
3. Copy toàn bộ nội dung từ file: `database-migrations/secure_profiles_rls.sql`
4. Paste và chạy script
5. Verify policies đã được tạo:

```sql
SELECT policyname FROM pg_policies WHERE tablename = 'profiles';
```

Bạn sẽ thấy các policies:
- `Users can view all profiles`
- `Users can insert their own profile on signup`
- `Users can update their own profile except role`
- `Admins can manage all profiles`

---

## Bước 2: Setup Environment Variables

Tạo file `.env.local` trong root của project (nếu chưa có):

```env
# Public keys (có thể expose, được bảo vệ bởi RLS)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Service role key (KHÔNG BAO GIỜ expose)
# Lấy từ: Supabase Dashboard → Settings → API → service_role key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

**QUAN TRỌNG:**
- ✅ Thêm `.env.local` vào `.gitignore`
- ❌ KHÔNG commit `.env.local` vào git
- ❌ KHÔNG expose service role key

---

## Bước 3: (Tùy chọn) Cài đặt Dependencies Nâng cao

Để có bảo vệ tốt hơn với cookies trong middleware, cài đặt:

```bash
npm install @supabase/ssr@latest
```

Sau đó cập nhật `src/middleware.ts` để sử dụng `@supabase/ssr` (xem examples trong documentation).

**NOTE:** Middleware hiện tại đã hoạt động với dependencies hiện có, nhưng sẽ tốt hơn với `@supabase/ssr`.

---

## Bước 4: Verify Setup

### Test 1: RLS Policies

Chạy trong Supabase SQL Editor:

```sql
-- Test với user thường (phải bị lỗi)
-- Thay <user-id> bằng ID của user thường
UPDATE profiles SET role = 'admin' WHERE id = '<user-id>';
-- Expected: ERROR: Permission denied: Only admins can change user roles
```

### Test 2: Middleware Protection

1. Đăng nhập với user thường (không phải admin)
2. Truy cập `http://localhost:3000/admin`
3. Expected: Redirect về `/` hoặc `/login`

### Test 3: Client-side Protection

1. Đăng nhập với user thường
2. Thử truy cập admin pages
3. Expected: Redirect về home

---

## Bước 5: Kiểm tra Tất cả Admin Routes

Đảm bảo các routes sau đều được bảo vệ:
- ✅ `/admin`
- ✅ `/admin/users`
- ✅ `/admin/rooms`
- ✅ `/admin/bookings`
- ✅ `/admin/notifications`
- ✅ `/admin/pass-phong`

---

## ✅ Checklist Hoàn thành

- [ ] Đã chạy migration `secure_profiles_rls.sql`
- [ ] Đã setup `.env.local` với các keys
- [ ] Đã verify RLS policies hoạt động
- [ ] Đã test middleware protection
- [ ] Đã test client-side protection
- [ ] Đã verify `.env.local` trong `.gitignore`

---

## 🆘 Troubleshooting

### Lỗi: "Permission denied" khi chạy migration

**Giải pháp:** Đảm bảo bạn đang chạy với quyền admin trong Supabase SQL Editor.

### Lỗi: Middleware không hoạt động

**Giải pháp:**
1. Restart dev server: `npm run dev`
2. Kiểm tra file `src/middleware.ts` ở đúng vị trí
3. Kiểm tra environment variables

### Lỗi: "Cannot find module @supabase/ssr"

**Giải pháp:** Middleware hiện tại không cần `@supabase/ssr`. Nếu muốn sử dụng, cài đặt:
```bash
npm install @supabase/ssr@latest
```

---

## 📚 Tài liệu Thêm

Xem file `SECURITY_GUIDE.md` để biết chi tiết về:
- Các biện pháp bảo mật đã triển khai
- Best practices
- Rủi ro và cách xử lý
- Troubleshooting chi tiết

---

## ✅ Hoàn thành!

Sau khi hoàn thành các bước trên, hệ thống của bạn đã được bảo vệ khỏi việc chiếm quyền admin! 🛡️

