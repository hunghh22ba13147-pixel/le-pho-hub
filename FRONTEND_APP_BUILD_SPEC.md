# Đặc tả xây dựng frontend app (tham chiếu dự án HoaLacHomeSuper)

Tài liệu mô tả **giao diện, luồng người dùng và mô hình dữ liệu UI** của website hiện tại để bạn (hoặc AI) xây **frontend app khác** (Flutter, React Native, v.v.) **đồng bộ trải nghiệm** với nền tảng **Trọ Hoà Lạc**. Phần API/Supabase xem thêm `FLUTTER_SUPABASE_APP_BRIEF.md`.

---

## 1. Bối cảnh sản phẩm

| Mục | Giá trị tham chiếu |
|-----|---------------------|
| Tên / positioning | **Trọ Hoà Lạc** — tìm kiếm và đặt phòng trọ khu Hoà Lạc |
| Ngôn ngữ UI | Tiếng Việt (`lang="vi"` trên web) |
| Web tham chiếu | Next.js App Router, React 18, Tailwind CSS, Supabase client |

**Metadata mặc định (web):** title *"Trọ Hoà Lạc - Tìm phòng trọ tại Hoà Lạc"*, mô tả nền tảng tìm phòng/đặt phòng uy tín.

---

## 2. Cấu trúc trang (Information Architecture)

### 2.1 Điều hướng chính (header công khai)

Theo `src/data/navigation.ts` (`NAVIGATION_DEMO`):

| Nhãn | Đường dẫn | Mô tả ngắn |
|------|-----------|------------|
| Home | `/` | Trang chủ: hero, listing nổi bật, khám phá theo trường |
| Nhà trọ, phòng trọ | `/phong-tro` | Danh sách phòng + bộ lọc |
| Pass Phòng | `/pass-phong-public` | Tin pass phòng công khai |
| Video review | `/video-review` | Video review phòng |
| Về chúng tớ | `/about` | Giới thiệu |

**Bổ sung quan trọng (không nằm trong menu ngắn trên nhưng là core):**

| Đường dẫn | Mô tả |
|-----------|--------|
| `/phong-tro-detail/[[...slug]]` | Chi tiết phòng — URL dạng `/phong-tro-detail/{slug}-{uuid}` (xem mục 4.2) |
| `/phong-tro-map` | Danh sách phòng trên bản đồ |
| `/phong-tro-gan-truong/[university]` | Phòng gần một trường cụ thể |
| `/login`, `/signup` | Đăng nhập / đăng ký |
| `/wishlist` | Danh sách yêu thích (cần đăng nhập tùy policy) |
| `/checkout` | Thanh toán / flow booking (template) |
| `/compare` | So sánh phòng (context `CompareProvider`) |

### 2.2 Tài khoản (`(account-pages)`)

| Đường dẫn | Mô tả |
|-----------|--------|
| `/account` | Tổng quan tài khoản |
| `/account-savelists` | Danh sách đã lưu |
| `/account-bookings` | Lịch đặt phòng của tôi |
| `/account-password` | Đổi mật khẩu |
| `/account-billing` | Thanh toán (template) |
| `/pass-phong` | Quản lý pass phòng (của user) |
| `/pass-phong/tao-moi` | Tạo tin pass phòng mới |

### 2.3 Admin (`/admin/*`)

Layout **không** dùng header/footer site thường (`ConditionalLayout` bỏ qua route bắt đầu bằng `/admin`).

Gợi ý trang: `/admin`, `/admin/rooms`, `/admin/bookings`, `/admin/pass-phong`, `/admin/users`, `/admin/notifications`, `/admin/analytics`, `/admin/settings`.

**Ghi chú cho app mobile:** có thể chỉ build phần renter/owner công khai; admin tùy scope.

### 2.4 Trang marketing / template (ưu tiên thấp khi clone app)

`/blog`, `/blog/[...slug]`, `/contact`, `/author`, `/subscription`, `/pay-done`, `/listing-real-estate`, `/listing-real-estate-map`, `/ai-assistant` — một phần là demo template; làm rõ với PO trước khi port.

---

## 3. Layout toàn cục (web)

- **Font:** Be Vietnam Pro (Google Fonts), subset `vietnamese`, `latin`; weight 300–700.
- **Body:** nền sáng `bg-white`, chữ `text-neutral-900`; dark mode: `dark:bg-neutral-900`, `dark:text-neutral-200` (`class` trên `html`).
- **Khung site:** `SiteHeader` → nội dung → `FooterNav` → `Footer` (trừ `/admin`).
- **Provider:** `AuthProvider` (session user), `CompareProvider` (so sánh listing).

App mới nên giữ **cùng hierarchy thông tin** (header actions: account, wishlist, compare nếu có).

---

## 4. Mô hình dữ liệu hiển thị listing (card phòng)

Kiểu chính: **`StayDataType`** (`src/data/types.ts`). Các trường UI quan trọng:

| Trường | Ý nghĩa UI |
|--------|------------|
| `id` | Định danh phòng |
| `title` | Tiêu đề |
| `featuredImage` | Ảnh đại diện |
| `galleryImgs` | Gallery |
| `price` | Giá (string, thường format VND trên UI) |
| `address`, `district`, `ward` | Địa chỉ |
| `reviewStart`, `reviewCount` | Sao trung bình + số đánh giá |
| `roomStatus` | `available` \| `reserved` \| `sold_out` — badge |
| `like` | Trạng thái tim / wishlist (đồng bộ với favorites khi đăng nhập) |
| `map.lat`, `map.lng` | Bản đồ |
| `author` | Chủ phòng (avatar, tên hiển thị) |
| `href` | Link tới chi tiết |

**Phòng chi tiết:** parse UUID từ segment cuối URL (`parseRoomDetailSlugParam` trong `src/utils/roomDetailUrl.ts`). Slug tạo bằng `slugifyRoomTitle` (bỏ dấu tiếng Việt → slug ASCII).

---

## 5. Luồng nghiệp vụ cần có trên UI

### 5.1 Khách / renter

1. Xem trang chủ → xem phòng hot / mới.
2. Vào **Nhà trọ** → lọc (giá, khu vực, tiện ích — logic trong `supabaseServices`: `fetchRoomsWithFilters*`) → mở chi tiết.
3. Chi tiết: ảnh, mô tả, tiện ích, địa điểm lân cận, map, đánh giá, video review (nếu có), nút **yêu thích**, **đặt phòng** / form booking (`BookingForm`).
4. **Video review:** trang tổng hợp + liên kết về phòng.
5. **Pass phòng:** xem public → (nếu có quyền) tạo / quản lý tin trong account.
6. Đăng nhập → xem **account-bookings**, **account-savelists**.

### 5.2 Chủ phòng (owner)

- Quản lý phòng / booking tùy policy RLS; trên web có admin forms — trên app có thể thu gọn thành “phòng của tôi” + chỉnh sửa cơ bản nếu API cho phép.

### 5.3 So sánh

- User chọn nhiều phòng → màn `/compare` (cần state toàn app tương đương `CompareProvider`).

---

## 6. Thành phần UI đặc trưng (để designer/dev app bám theo)

- **Hero trang chủ:** `CustomHero`, nền glass morphism (`BgGlassmorphism`).
- **Grid phòng:** các section dạng `SectionGridFeaturePlaces`, filter card (`SectionGridFilterCard`, `HeaderFilter`).
- **Thẻ phòng (Stay card):** ảnh, giá, địa chỉ rút gọn, sao review, badge trạng thái.
- **Chi tiết phòng:** gallery, owner, amenities (`fetchRoomAmenities`), nearby places, feedback list, booking CTA.
- **Thông báo:** `NotificationBanner` — theo role (`fetchActiveNotifications`).
- **Nút Like/Save:** `LikeSaveBtns` — wishlist.

App Flutter/React Native: map từng block thành screen/widget tương ứng; giữ **thứ tự ưu tiên thông tin** giống web để user quen tay.

---

## 7. Hệ màu & theme (web)

- **Tailwind:** màu `primary`, `secondary`, `neutral` mở rộng từ **CSS variables** (`--c-primary-*`, …) trong theme SCSS/CSS (xem `tailwind.config.js`).
- **Dark mode:** class-based (`darkMode: "class"`).

Khi port sang app native: export bảng màu từ file theme web (hoặc chụp design token) để đồng nhất thương hiệu.

---

## 8. File nguồn nên đọc khi implement

| Đường dẫn | Mục đích |
|-----------|----------|
| `src/app/layout.tsx` | Font, metadata, providers |
| `src/components/ConditionalLayout.tsx` | Header/footer vs admin |
| `src/data/types.ts` | `StayDataType`, `RoomStatus` |
| `src/data/navigation.ts` | Menu chính |
| `src/utils/roomDetailUrl.ts` | Quy ước URL chi tiết phòng |
| `src/lib/supabaseServices.ts` | Mapping API ↔ UI (đã liệt kê trong brief Supabase) |
| `src/contexts/AuthContext.tsx` | Hành vi đăng nhập / user |
| `src/contexts/CompareContext.tsx` | So sánh phòng |

---

## 9. Gợi ý giao app cho dev / AI

1. **Chốt MVP màn hình:** ví dụ Home, Danh sách + lọc, Chi tiết, Video review, Pass phòng (public), Login/Signup, Wishlist, Bookings, Profile.
2. **Deep link:** cùng quy ước path hoặc mapping sang scheme app (`phong-tro-detail/{slug}-{uuid}` → mở đúng phòng).
3. **Đồng bộ copy:** dùng lại microcopy tiếng Việt từ web khi có thể.
4. **Backend:** dùng chung Supabase — chi tiết bảng và hàm service xem `FLUTTER_SUPABASE_APP_BRIEF.md`.

---

## 10. Phiên bản

- Đặc tả bám theo repo **HoaLacHomeSuper** (Next.js + Tailwind + Supabase).
- Cập nhật khi thêm/bớt route hoặc đổi menu trong `src/data/navigation.ts` và `src/app/`.
