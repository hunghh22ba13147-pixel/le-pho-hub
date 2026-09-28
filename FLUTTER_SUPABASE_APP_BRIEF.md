# Brief: Ứng dụng Flutter dùng chung Supabase (HoaLacHomeSuper)

Tài liệu này mô tả ngữ cảnh kỹ thuật để AI hoặc developer xây **ứng dụng Flutter** kết nối **cùng một project Supabase** với website Next.js hiện có trong repo này.

---

## 1. Mục tiêu sản phẩm

- **Nền tảng web hiện tại:** Next.js (App Router), client Supabase qua `@supabase/supabase-js`.
- **Mục tiêu Flutter:** App di động (Android/iOS) tái hiện các luồng chính của nền tảng cho thuê / tìm phòng (danh sách phòng, chi tiết, đặt phòng, tài khoản, yêu thích, v.v.) bằng cách gọi **trực tiếp** Supabase Database + Auth + Storage (giống web), không yêu cầu backend riêng trừ khi có nhu cầu bảo mật đặc biệt.

---

## 2. Cấu hình môi trường (bắt buộc)

Trên web, biến môi trường công khai là:

| Biến | Mô tả |
|------|--------|
| `NEXT_PUBLIC_SUPABASE_URL` | URL project Supabase |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Publishable / anon key (client) |

**Flutter:** dùng cùng giá trị URL + anon key (qua `--dart-define`, file env build, hoặc cấu hình an toàn theo chuẩn team). **Không** nhúng `service_role` hoặc secret key vào app.

Tham chiếu code web: `src/lib/supabaseClient.ts`.

---

## 3. Bảng Postgres đang được web sử dụng (public API)

Các tên bảng sau xuất hiện trong lớp dịch vụ web `src/lib/supabaseServices.ts` — Flutter nên bám theo cùng schema và RLS:

| Bảng | Gợi ý vai trò |
|------|----------------|
| `rooms` | Phòng cho thuê (title, price, area, address, city, district, ward, status, banner, maps, owner_id, …) |
| `room_amenities` | Liên kết phòng ↔ tiện ích |
| `amenities` | Danh mục tiện ích |
| `profiles` | Hồ sơ người dùng (name, phone, role, DoB, …) — gắn với `auth.users` |
| `favorites` | Danh sách yêu thích (wishlist) |
| `bookings` | Đặt phòng (check_in/out, guests, total_price, status pending/approved/rejected/cancelled, …) |
| `feedbacks` | Đánh giá phòng |
| `notifications` | Thông báo (target_audience: all / renters / owners / admins) |
| `nearby_places` | Địa điểm lân cận (university, bus_stop, …) |
| `universities` | Trường đại học |
| `room_universities` | Phòng gắn trường + khoảng cách |
| `room_transfers` | Luồng “pass phòng” / chuyển nhượng |
| `room_video_reviews` | Video review theo phòng (source_url, display_title, sort_order) |

Nếu cần chi tiết cột và quan hệ, đối chiếu interface trong `supabaseServices.ts` (ví dụ `DatabaseRoom`, `DatabaseBooking`, …) hoặc export schema từ Supabase Dashboard / CLI.

---

## 4. Supabase Auth (đối chiếu web)

Web đã dùng / chuẩn bị các luồng sau (cùng file services):

- Đăng nhập email + mật khẩu (`signInWithPassword`)
- Đăng ký + tạo/cập nhật `profiles` (`signUp`)
- Đăng xuất (`signOut`)
- Lấy user hiện tại, reset mật khẩu
- OAuth: Google, Facebook, Twitter (`signInWithOAuth`)

**Flutter:** cấu hình redirect / deep link trong Supabase Dashboard cho từng provider và platform; session persist qua `supabase_flutter`.

---

## 5. Supabase Storage

- Upload ảnh mặc định bucket: **`room-images`** (tham số có thể override trong code web).
- Flutter: dùng Supabase Storage API tương ứng; tuân thủ policy RLS/storage đã cấu hình trên project.

---

## 6. Chức năng nên lập bản đồ từ web sang Flutter

Dưới đây là các hàm export chính trong `src/lib/supabaseServices.ts` — coi như **checklist parity** (có thể giai đoạn hóa MVP):

**Phòng & tìm kiếm**

- `fetchRooms`, `fetchRoomsPaginated`, `getTotalRoomsCount`, `fetchRoomsPaginatedWithTotal`
- `fetchRoomById`, `fetchRoomAmenities`
- `fetchRoomsWithFilters`, `fetchRoomsWithFiltersPaginated`

**Auth & profile**

- `loginUser`, `signupUser`, `logoutUser`, `getCurrentUser`, `resetPassword`
- `updateUserProfile`, `updateUserRole`
- `loginWithGoogle`, `loginWithFacebook`, `loginWithTwitter`

**Yêu thích**

- `addToWishlist`, `removeFromWishlist`, `isInWishlist`, `fetchWishlistRooms`

**Thông báo**

- `fetchAllNotifications`, `fetchActiveNotifications`, `createNotification`, `updateNotification`, `deleteNotification`

**Feedback**

- `fetchRoomFeedbacks`, `getRoomAverageRating`, `createFeedback`, `updateFeedback`, `deleteFeedback`, `hasUserFeedback`

**Địa điểm lân cận**

- `fetchNearbyPlaces`, `createNearbyPlace`, `updateNearbyPlace`, `deleteNearbyPlace`

**Phòng của chủ & chuyển nhượng**

- `fetchUserRooms`
- `fetchApprovedTransfers`, `fetchPendingTransfers`, `fetchMyTransfers`
- `createRoomTransfer`, `updateRoomTransfer`, `deleteRoomTransfer`, `approveRoomTransfer`, `rejectRoomTransfer`

**Đặt phòng**

- `createBooking`, `fetchAllBookings`, `fetchPendingBookings`, `fetchMyBookings`
- `approveBooking`, `rejectBooking`, `cancelBooking`

**Đại học & phòng theo trường**

- `fetchUniversities`, `fetchUniversitiesWithRoomCounts`, `fetchRoomsByUniversity`
- `addRoomUniversities`, `getRoomUniversities`

**Video review**

- `fetchRoomVideoReviewsForPublicPage`, `fetchRoomVideoReviewsByRoomId`

**Upload (thường dành cho admin/owner trên web)**

- `uploadImage`, `uploadMultipleImages`

Một số màn hình admin trên web có thể **không** cần trong bản Flutter đầu tiên — làm rõ scope với product owner.

---

## 7. Gợi ý kỹ thuật Flutter

- Package: **`supabase_flutter`** (khớp phiên bản với docs Supabase hiện tại).
- Bảo mật: mọi truy cập dữ liệu user phải dựa trên **RLS** đã bật trên project; không bypass bằng service role từ app.
- UI/state: tùy chọn Riverpod / Bloc — không bắt buộc trong brief này.
- Deep linking: bắt buộc cho OAuth trên mobile.
- Optional: generate Dart models từ schema (tooling team chọn).

---

## 8. Tài liệu tham chiếu trong repo

| Đường dẫn | Nội dung |
|-----------|----------|
| `src/lib/supabaseClient.ts` | Khởi tạo client |
| `src/lib/supabaseServices.ts` | Toàn bộ query, filter, auth, storage — **nguồn sự thật cho hành vi nghiệp vụ** |

---

## 9. Việc chủ dự án cần cung cấp cho dev / AI

- URL Supabase + anon key (môi trường dev/staging; production tách nếu cần).
- Danh sách màn hình MVP Flutter (ưu tiên renter vs owner vs admin).
- Redirect URL / scheme cho OAuth trên iOS/Android.
- Quy ước branding (logo, màu) nếu cần đồng bộ với web.

---

## 10. Phiên bản brief

- Repo: **HoaLacHomeSuper** (Next.js + Supabase).
- Brief được tạo để hỗ trợ outsource / AI codegen app Flutter dùng chung backend Supabase.
