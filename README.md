# 🏙️ Le Phố Hub

**Smart Housing SaaS & Roommate Matching Platform — Nội thành Hà Nội**

Nền tảng tìm kiếm phòng trọ, chung cư mini và ghép ở thông minh tại nội thành Hà Nội.  
*A smart housing marketplace and roommate matching platform for inner Hanoi.*

---

## ✨ Tính năng chính / Key Features

- 🏠 **Marketplace** — Tìm & đăng tin phòng trọ / chung cư mini theo quận Hà Nội
- 👥 **Roommate Matching** — Ghép ở thông minh dựa trên AI (lịch sinh hoạt, thói quen, ngân sách)
- 🏢 **PMS (SaaS)** — Phần mềm quản lý nhà trọ cho chủ trọ (Admin/Owner portal)
- 🤖 **AI Assistant** — Chatbot tư vấn tìm phòng và ghép ở
- 📊 **Analytics** — Báo cáo doanh thu, vận hành cho quản lý
- 🔔 **Notifications** — Hệ thống thông báo realtime
- 💳 **CTV & Hoa hồng** — Quản lý cộng tác viên và hoa hồng

## 🗺️ Địa bàn / Coverage

Nội thành + Vùng ven Hà Nội:  
Hoàn Kiếm · Đống Đa · Ba Đình · Hai Bà Trưng · **Cầu Giấy · Thanh Xuân · Nam Từ Liêm · Bắc Từ Liêm** · Hoàng Mai · Long Biên · Tây Hồ

---

## 🔧 Công nghệ / Tech Stack

| Layer | Công nghệ |
|-------|-----------|
| Frontend | Next.js 13+ (App Router) · TypeScript |
| Styling | Tailwind CSS · Framer Motion · HeadlessUI |
| Backend | Supabase (PostgreSQL + RLS + Storage) |
| Auth | Supabase Auth + next-auth |
| Maps | Google Map React |
| AI | RAG Chatbot (Next.js API Routes) |

---

## 🚀 Cài đặt / Setup

1. Cài Node.js `>= 18`
2. `npm install` hoặc `pnpm install`
3. Sao chép `.env.local.example` → `.env.local` và điền Supabase credentials
4. Chạy migration SQL trong `database-migrations/` lên Supabase (bắt đầu từ `younghouse_pms_full_schema.sql`, sau đó `hanoi_districts.sql`)
5. `npm run dev` → `http://localhost:3000`

## 📜 Scripts

| Command | Mô tả |
|---------|-------|
| `npm run dev` | Chạy môi trường phát triển |
| `npm run dev:turbo` | Chạy với Turbopack (nhanh hơn) |
| `npm run build` | Build production |
| `npm run lint` | Kiểm tra ESLint |

---

## 📁 Cấu trúc thư mục / Directory Structure

```
src/
├── app/                    # Next.js App Router — pages & routes
│   ├── admin/              # Admin dashboard (RBAC: admin, manager)
│   ├── owner/              # Chủ trọ portal (landlord PMS)
│   ├── roommate/           # Roommate Matching hub [Phase 2]
│   ├── phong-tro-theo-quan/# Tìm phòng theo quận Hà Nội
│   ├── blog/               # Blog & tin tức
│   └── api/                # API Route Handlers
├── components/             # 65+ React components
├── lib/                    # Supabase service layer
│   ├── supabaseServices.ts # Core services
│   ├── landlordServices.ts # Landlord/Owner services
│   └── ctvServices.ts      # CTV commission services
└── shared/                 # Shared UI (Button, Logo, Nav...)

database-migrations/
├── younghouse_pms_full_schema.sql  # Schema tổng thể
├── hanoi_districts.sql             # Quận Hà Nội (Le Phố Hub)
└── ...                             # Các migration bổ sung
```

---

## 👥 Vai trò người dùng / User Roles

| Role | Mô tả |
|------|-------|
| `admin` | Quản trị toàn hệ thống |
| `manager` | Giám sát, báo cáo doanh thu |
| `sales` / CTV | Tìm kiếm, hold phòng, hoa hồng |
| `operator` | Ghi điện nước, bảo trì |
| `tenant` | Khách thuê (xem hóa đơn, báo hỏng) |
| `user` | Khách vãng lai / đăng ký mới |

---

## 🎨 Design System — Indochine Modern

| Token | Màu | Hex |
|-------|-----|-----|
| Primary | Terracotta / Đỏ gạch | `#C0522B` |
| Secondary | Vàng đồng cổ | `#B8860B` |
| Background | Kem ngà | `#FAF6F0` |
| Accent | Xanh rêu | `#2D5016` |
| Text | Nâu đậm | `#2C1810` |

---

## 📬 Đóng góp / Contributing

1. Tạo nhánh mới từ `main`
2. Chạy `npm run lint` trước khi commit
3. Mở Pull Request với mô tả rõ ràng

---

*Le Phố Hub — Nhà của bạn tại phố. Your home in the city.*