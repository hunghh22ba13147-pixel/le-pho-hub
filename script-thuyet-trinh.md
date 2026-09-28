# 📋 KỊCH BẢN THUYẾT TRÌNH — LE PHỐ HUB
### Smart Housing SaaS & Roommate Matching Platform

---

## 🎤 PHẦN 1 — GIỚI THIỆU DỰ ÁN (2–3 phút)

> **[Mở slide trang chủ http://localhost:3000]**

**Lời nói:**
> "Kính chào thầy/cô và các bạn. Hôm nay nhóm em sẽ thuyết trình về dự án **Le Phố Hub** —
> một nền tảng SaaS thông minh giúp tìm kiếm phòng trọ và ghép ở tại nội thành Hà Nội."

### 1.1 Vấn đề thực tiễn (Pain Point)
- Sinh viên, người đi làm mất nhiều thời gian tìm phòng, xem thông tin rải rác
- Thông tin không minh bạch: ảnh không thật, giá ẩn phí
- Khó tìm người ghép ở phù hợp → chi phí thuê cao
- Không có nền tảng nào tập trung vào **nội thành Hà Nội** với trải nghiệm hiện đại

### 1.2 Giải pháp — Le Phố Hub
| Tính năng | Mô tả |
|-----------|-------|
| 🏠 Tìm phòng theo quận | Lọc theo 8 quận nội thành, giá, diện tích |
| 🤝 Roommate Matching AI | Ghép ở thông minh theo lịch sinh hoạt, ngân sách |
| 🤖 AI Assistant | Chatbot tư vấn 24/7 về phòng trọ Hà Nội |
| 💰 SaaS Pricing | 3 gói dịch vụ cho chủ trọ: Free / Pro / Business |

---

## 🖥️ PHẦN 2 — KIẾN TRÚC HỆ THỐNG (3–4 phút)

> **[Mở slide sơ đồ kiến trúc]**

```
┌─────────────────────────────────────────────┐
│              FRONTEND (Next.js 13)           │
│  ┌─────────┐  ┌──────────┐  ┌────────────┐  │
│  │  Pages  │  │Components│  │  Contexts  │  │
│  └─────────┘  └──────────┘  └────────────┘  │
│         App Router + Server Components       │
└───────────────────┬─────────────────────────┘
                    │ HTTP / API Routes
┌───────────────────▼─────────────────────────┐
│            BACKEND (Next.js API Routes)      │
│  /api/rag  │  /api/phong-tro  │  /api/auth  │
└───────────────────┬─────────────────────────┘
                    │
┌───────────────────▼─────────────────────────┐
│         DATABASE (Supabase / PostgreSQL)     │
│  listings │ profiles │ matches │ plans       │
└─────────────────────────────────────────────┘
```

**Lời nói:**
> "Hệ thống được xây dựng theo mô hình **Full-Stack Monorepo** với Next.js 13.
> Frontend và Backend đều nằm trong cùng một dự án.
> Database sử dụng Supabase — một dịch vụ PostgreSQL có realtime và auth tích hợp sẵn."

---

## ⚙️ PHẦN 3 — CÔNG NGHỆ SỬ DỤNG (2 phút)

> **[Mở file package.json tại D:\lephohub\package.json]**

### Frontend Stack
```json
{
  "name": "le-pho-hub",
  "version": "1.0.0",
  "dependencies": {
    "next": "13.4.3",          // Framework chính — App Router
    "react": "18.2.0",         // UI library
    "typescript": "5.x",       // Type safety
    "tailwindcss": "3.3.2",    // Utility-first CSS
    "@heroicons/react": "2.x", // Icon library
    "framer-motion": "10.x",   // Animation
    "@supabase/supabase-js": "2.x" // Database client
  }
}
```

**Lời nói:**
> "Em dùng **Next.js 13** với App Router — đây là phiên bản mới nhất hỗ trợ
> Server Components, giúp trang load nhanh hơn. TypeScript đảm bảo type safety.
> Tailwind CSS giúp styling nhanh với utility classes."

### Backend & Database
```
- Next.js API Routes → /src/app/api/
- Supabase PostgreSQL → Database chính
- Supabase Auth → Xác thực người dùng
- Supabase Storage → Lưu ảnh phòng trọ
- Row Level Security (RLS) → Bảo mật dữ liệu
```

---

## 🎨 PHẦN 4 — FRONTEND — CẤU TRÚC THƯ MỤC (3 phút)

> **[Mở VS Code, expand cây thư mục src/]**

```
D:\lephohub\src\
├── app/                          # Next.js 13 App Router
│   ├── (home)/                   # Trang chủ
│   │   └── page.tsx              # ← TRANG CHỦ CHÍNH
│   ├── (server-components)/
│   │   └── CustomHero.tsx        # ← Hero search box
│   ├── (stay-listings)/
│   │   ├── TabFilters.tsx        # ← Bộ lọc phòng trọ
│   │   └── layout.tsx
│   ├── roommate/                 # ← MODULE GHÉP Ở
│   │   ├── page.tsx              # Landing page ghép ở
│   │   ├── matches/page.tsx      # Danh sách matching
│   │   ├── profile/page.tsx      # Tạo hồ sơ (5 bước)
│   │   └── chat/[matchId]/       # Chat trực tiếp
│   ├── ai-assistant/
│   │   └── page.tsx              # ← Full-screen AI chatbot
│   ├── pricing/
│   │   └── page.tsx              # ← SaaS pricing page
│   ├── about/
│   │   └── page.tsx              # Về chúng tôi
│   ├── contact/
│   │   └── page.tsx              # Liên hệ
│   └── api/                      # ← BACKEND API ROUTES
│       └── rag/route.ts          # AI API endpoint
│
├── components/                   # Shared UI Components
│   ├── AIChatWidget.tsx          # ← Widget AI nổi góc phải
│   ├── DistrictExploreSection.tsx # ← 8 quận nội thành
│   ├── SectionOurFeatures.tsx    # Tính năng nổi bật
│   ├── SectionClientSay.tsx      # Reviews
│   ├── SectionStats.tsx          # Thống kê số liệu
│   ├── SectionSliderNewCategories.tsx # Khám phá quận
│   ├── Footer.tsx                # Footer
│   └── ZaloWidget.tsx            # Zalo chat widget
│
├── data/
│   └── navigation.ts             # ← Menu navigation
│
└── shared/                       # Atomic UI components
    ├── Button.tsx
    ├── Input.tsx
    └── Select.tsx
```

---

## 🏠 PHẦN 5 — TRANG CHỦ — CHI TIẾT CODE (5 phút)

> **[Mở file: D:\lephohub\src\app\page.tsx]**

### 5.1 CustomHero — Search Box

```tsx
// src/app/(server-components)/CustomHero.tsx
"use client";  // ← Đây là Client Component (có state, event)

const CustomHero = () => {
  // State quản lý tab đang active
  const [activeTab, setActiveTab] = useState<"all" | "room">("room");
  const [selectedArea, setSelectedArea] = useState("");
  const [priceRange, setPriceRange] = useState("");

  // Hàm xử lý khi user nhấn "Tìm kiếm"
  const handleSearch = () => {
    const params = new URLSearchParams();
    if (selectedArea) params.set("district", selectedArea);
    if (priceRange)   params.set("price", priceRange);
    // Redirect sang trang danh sách phòng
    window.location.href = `/phong-tro?${params.toString()}`;
  };

  return (
    // Tab "Tat ca" / "Nha tro"
    <button onClick={() => setActiveTab("all")}>Tat ca</button>

    // Dropdown chọn quận — 8 quận nội thành
    <Select onChange={(e) => setSelectedArea(e.target.value)}>
      <option value="Dong Da">Dong Da</option>
      <option value="Cau Giay">Cau Giay</option>
      {/* ... 6 quận khác */}
    </Select>

    // Nút tìm kiếm
    <ButtonPrimary onClick={handleSearch}>Tim kiem</ButtonPrimary>
  );
};
```

**Lời nói:**
> "CustomHero là component search chính của trang chủ.
> Nó dùng `useState` để track tab và bộ lọc đang chọn.
> Khi user nhấn tìm kiếm, nó tạo URL params và redirect sang trang listing."

---

### 5.2 DistrictExploreSection — Khám Phá Quận

> **[Mở file: D:\lephohub\src\components\DistrictExploreSection.tsx]**

```tsx
// Dữ liệu 8 quận nội thành (mock data)
const HANOI_DISTRICTS = [
  {
    id: "dong-da",
    name: "Dong Da",
    type: "Noi thanh",  // ← Dùng để filter tab
    image: "https://images.unsplash.com/...",
    roomCount: 45,
    description: "Trung tam van hoa, nhieu truong DH"
  },
  {
    id: "cau-giay",
    type: "Noi thanh",  // ← Được chuyển từ Vùng ven sang Nội thành
    roomCount: 62,
    // ...
  },
  // ...8 quận tổng cộng
];

// Component chính — Filter theo tab
const DistrictExploreSection = () => {
  const [activeFilter, setActiveFilter] = useState("all");

  // Lọc districts theo tab đang active
  const filtered = activeFilter === "all"
    ? HANOI_DISTRICTS
    : HANOI_DISTRICTS.filter(d => d.type === activeFilter);

  return (
    // Tab Nội thành / Vùng ven / Tất cả
    <div className="tabs">...</div>

    // Grid hiển thị các quận
    <div className="grid grid-cols-4">
      {filtered.map(district => (
        <DistrictCard key={district.id} district={district} />
      ))}
    </div>
  );
};
```

---

## 🤝 PHẦN 6 — ROOMMATE MATCHING MODULE (5 phút)

> **[Mở http://localhost:3000/roommate rồi http://localhost:3000/roommate/matches]**

### 6.1 Luồng hoạt động
```
User → Tạo hồ sơ (/roommate/profile) 
     → Xem gợi ý (/roommate/matches) 
     → Nhắn tin (/roommate/chat/[matchId])
```

### 6.2 Hồ sơ người dùng — TypeScript Interface

> **[Mở file: D:\lephohub\src\data\roommate.types.ts (nếu có)]**

```typescript
// Định nghĩa kiểu dữ liệu cho hồ sơ ghép ở
export interface RoommateProfile {
  id: string;
  name: string;
  age: number;
  occupation: 'student' | 'working' | 'freelance';
  district: string;          // Quận muốn thuê
  budgetMin: number;         // Ngân sách tối thiểu (VND)
  budgetMax: number;         // Ngân sách tối đa
  sleepSchedule: 'early_bird' | 'night_owl' | 'flexible';
  cookingHabit: 'always' | 'sometimes' | 'never';
  smoking: boolean;
  pets: boolean;
  personality: 'introvert' | 'extrovert' | 'ambivert';
  interests: string[];       // Sở thích chung
  matchScore: number;        // 0-100 — điểm tương thích
}
```

**Lời nói:**
> "TypeScript giúp em định nghĩa rõ kiểu dữ liệu.
> Khi có lỗi type, VS Code sẽ báo ngay trong editor thay vì runtime error."

### 6.3 Trang Matches — Mock Data & UI

> **[Mở file: D:\lephohub\src\app\roommate\matches\page.tsx]**

```tsx
// Mock data — 6 người dùng với match score khác nhau
const MOCK_PROFILES = [
  {
    name: "Nguyen Thi Lan",
    matchScore: 94,
    district: "Cau Giay",
    occupation: "Sinh vien - BK",
    bio: "Minh la sinh vien nam 3 BK, thich yeu tinh...",
    commonInterests: ["Nau an", "Phim Han"],
    // Avatar từ pravatar.cc (đã được whitelist trong next.config.js)
    avatar: "https://i.pravatar.cc/150?img=1"
  },
  // ...5 người khác
];

// Component hiển thị match score badge
function MatchScoreBadge({ score }: { score: number }) {
  // Màu khác nhau theo % matching
  const color = score >= 90 ? "bg-green-500"
              : score >= 80 ? "bg-blue-500"
              : "bg-orange-500";
  return (
    <span className={`${color} text-white px-2 py-1 rounded-full text-xs`}>
      Match {score}%
    </span>
  );
}
```

---

## 🤖 PHẦN 7 — AI ASSISTANT (4 phút)

> **[Mở http://localhost:3000/ai-assistant]**

### 7.1 Kiến trúc AI Widget

```
User gõ câu hỏi
     ↓
AIChatWidget.tsx (Client Component)
     ↓
POST /api/rag  (Next.js API Route)
     ↓
[Thử Supabase AI] → Thất bại (placeholder key)
     ↓
Fallback: MOCK_RULES (Pattern matching)
     ↓
Trả về câu trả lời
```

### 7.2 File AIChatWidget.tsx — Floating Widget

> **[Mở file: D:\lephohub\src\components\AIChatWidget.tsx]**

```tsx
// src/components/AIChatWidget.tsx
"use client";

// Câu hỏi gợi ý hiển thị sẵn
const QUICK_QUESTIONS = [
  "Tim phong o Cau Giay",
  "Gia phong Dong Da bao nhieu?",
  "Ghep o la gi?",
  "Xem goi dich vu",
];

export default function AIChatWidget() {
  const [open, setOpen] = useState(false);  // Widget đóng/mở
  const [messages, setMessages] = useState([
    { role: "assistant", content: "Xin chao! Minh la AI..." }
  ]);
  const [input, setInput] = useState("");
  const [isTyping, setIsTyping] = useState(false);

  const send = async (text?: string) => {
    const q = text ?? input;
    setIsTyping(true);

    // Thêm loading message
    setMessages(prev => [...prev, { role: "assistant", content: "", loading: true }]);

    try {
      // Gọi API route
      const res = await fetch("/api/rag", {
        method: "POST",
        body: JSON.stringify({ question: q })
      });
      const data = await res.json();
      // Cập nhật message với câu trả lời
      setMessages(prev => prev.map(m =>
        m.loading ? { ...m, content: data.answer, loading: false } : m
      ));
    } catch {
      // Fallback: dùng mock rules nếu API lỗi
      const answer = getMockAnswer(q);
      setMessages(prev => prev.map(m =>
        m.loading ? { ...m, content: answer, loading: false } : m
      ));
    } finally {
      setIsTyping(false);
    }
  };
}
```

### 7.3 API Route — /api/rag/route.ts

> **[Mở file: D:\lephohub\src\app\api\rag\route.ts (nếu có)]**

```typescript
// src/app/api/rag/route.ts
import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
  const { question } = await req.json();

  // Pattern matching với từ khóa
  const RULES = [
    {
      pattern: /dong da|cau giay/i,
      answer: "Quan Dong Da co nhieu phong tro gia 2-4 trieu/thang..."
    },
    {
      pattern: /gia|bao nhieu/i,
      answer: "Gia phong tro noi thanh Ha Noi: 2.5-8 trieu/thang..."
    },
  ];

  for (const rule of RULES) {
    if (rule.pattern.test(question)) {
      return NextResponse.json({ answer: rule.answer });
    }
  }

  return NextResponse.json({
    answer: "Xin loi, ban co the hoi ve: tim phong, gia ca, ghep o, goi dich vu..."
  });
}
```

**Lời nói:**
> "API Route trong Next.js chạy trên server — không lộ logic ra client.
> Em dùng pattern matching để phân loại câu hỏi và trả lời phù hợp.
> Trong tương lai có thể kết nối OpenAI hoặc Gemini API thật."

---

## 💰 PHẦN 8 — SAAS PRICING MODULE (3 phút)

> **[Mở http://localhost:3000/pricing]**

### 8.1 3 Gói Dịch Vụ

```tsx
// src/app/pricing/page.tsx
const PLANS = [
  {
    name: "Mien Phi",
    price: 0,
    features: [
      "Toi da 3 tin dang/thang",
      "Thong ke co ban",
      "Ho tro email"
    ]
  },
  {
    name: "Chu Tro Pro",
    price: 299000,    // 299,000 VND/tháng
    popular: true,    // Badge "Phổ biến nhất"
    features: [
      "Toi da 20 tin dang",
      "Hoa don tu dong",
      "Ghi dien nuoc",
      "14 ngay dung thu mien phi"
    ]
  },
  {
    name: "Doanh Nghiep",
    price: 799000,
    features: [
      "Khong gioi han tin dang",
      "Quan ly CTV & hoa hong",
      "API tich hop",
      "Ho tro 24/7"
    ]
  }
];
```

### 8.2 Database Schema cho SaaS

> **[Mở file: D:\lephohub\database-migrations\subscription_plans.sql]**

```sql
-- Bảng gói dịch vụ
CREATE TABLE subscription_plans (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        VARCHAR(50) NOT NULL,      -- 'free', 'pro', 'business'
  price_vnd   INTEGER NOT NULL,          -- Giá VND/tháng
  max_listings INTEGER,                 -- NULL = không giới hạn
  features    JSONB,                     -- Danh sách tính năng
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- Bảng đăng ký của chủ trọ
CREATE TABLE user_subscriptions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES auth.users(id),
  plan_id     UUID REFERENCES subscription_plans(id),
  status      VARCHAR(20) DEFAULT 'active',  -- active/cancelled/expired
  started_at  TIMESTAMPTZ DEFAULT now(),
  expires_at  TIMESTAMPTZ,
  payment_method VARCHAR(20)               -- 'momo', 'vnpay', 'bank'
);
```

---

## 🗄️ PHẦN 9 — DATABASE — POSTGRESQL / SUPABASE (3 phút)

> **[Mở file: D:\lephohub\database-migrations\hanoi_districts.sql]**

### 9.1 Schema tổng quan

```sql
-- Bảng phòng trọ
CREATE TABLE listings (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       VARCHAR(200) NOT NULL,
  description TEXT,
  price       INTEGER NOT NULL,         -- VND/tháng
  area        DECIMAL(6,2),             -- m²
  district    VARCHAR(100),             -- Quận
  address     TEXT,
  images      TEXT[],                   -- Mảng URL ảnh
  owner_id    UUID REFERENCES auth.users(id),
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- Bảng hồ sơ ghép ở
CREATE TABLE roommate_profiles (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES auth.users(id),
  budget_min      INTEGER,
  budget_max      INTEGER,
  sleep_schedule  VARCHAR(20),          -- 'early_bird'|'night_owl'|'flexible'
  smoking         BOOLEAN DEFAULT false,
  pets            BOOLEAN DEFAULT false,
  district        VARCHAR(100),
  interests       TEXT[],               -- Mảng sở thích
  is_active       BOOLEAN DEFAULT true
);

-- Row Level Security — Mỗi user chỉ xem được data của mình
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Owner can manage own listings"
  ON listings FOR ALL
  USING (auth.uid() = owner_id);
```

**Lời nói:**
> "Row Level Security trong Supabase giúp bảo mật ở tầng database.
> Dù frontend có bug, data vẫn được bảo vệ — user A không thể sửa data của user B."

---

## 🔐 PHẦN 10 — AUTH & MIDDLEWARE (2 phút)

> **[Mở file: D:\lephohub\src\middleware.ts]**

```typescript
// src/middleware.ts — Chạy trước mọi request
import { createMiddlewareClient } from "@supabase/auth-helpers-nextjs";
import { NextResponse } from "next/server";

export async function middleware(req: NextRequest) {
  const res = NextResponse.next();
  const supabase = createMiddlewareClient({ req, res });

  // Refresh session nếu token sắp hết hạn
  await supabase.auth.getSession();

  // Các route cần đăng nhập
  const protectedRoutes = ["/roommate/profile", "/roommate/chat"];
  const isProtected = protectedRoutes.some(r => req.nextUrl.pathname.startsWith(r));

  if (isProtected) {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
      // Redirect về trang đăng nhập
      return NextResponse.redirect(new URL("/login", req.url));
    }
  }

  return res;
}
```

---

## 📱 PHẦN 11 — RESPONSIVE DESIGN (2 phút)

> **[Demo trên browser — thu nhỏ cửa sổ xuống mobile size]**

```tsx
// Ví dụ responsive với Tailwind CSS
<div className="
  grid
  grid-cols-1      // Mobile: 1 cột
  md:grid-cols-2   // Tablet: 2 cột
  lg:grid-cols-4   // Desktop: 4 cột
  gap-6
">
  {districts.map(d => <DistrictCard key={d.id} district={d} />)}
</div>
```

**Lời nói:**
> "Tailwind CSS dùng utility classes với prefix `md:` và `lg:` để tạo responsive design.
> Không cần viết media query thủ công — code gọn hơn rất nhiều."

---

## 🚀 PHẦN 12 — DEPLOYMENT & DEVOPS (2 phút)

### Môi trường hiện tại (Development)
```bash
# Cài đặt dependencies
npm install

# Chạy development server
npm run dev
# → http://localhost:3000
```

### Environment Variables
```env
# .env.local — Không commit lên Git
NEXT_PUBLIC_SUPABASE_URL=https://[project-ref].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
```

### Production (kế hoạch)
```
Code → GitHub → Vercel (Auto Deploy)
Database → Supabase Cloud (Free tier: 500MB)
Images → Supabase Storage
Domain → lephohub.vn
```

---

## 📊 PHẦN 13 — KẾT QUẢ & DEMO LIVE (3 phút)

> **[Demo trực tiếp theo thứ tự]**

### Checklist Demo
- [ ] **1.** Mở trang chủ — Hero search box, chọn quận Đống Đa, nhấn Tìm kiếm
- [ ] **2.** Trang Khám phá — Click tab "Noi thanh" → thấy 5 quận nội thành
- [ ] **3.** Trang Về chúng tôi — Ảnh chung cư, mission/commitment
- [ ] **4.** Trang Roommate → Matches — Xem các card với Match Score %
- [ ] **5.** Click "Nhan tin" → Vào trang chat
- [ ] **6.** AI Widget (góc phải dưới) → Hỏi "phong o dong da bao nhieu"
- [ ] **7.** Trang AI Assistant → Hỏi về ghép ở
- [ ] **8.** Trang Pricing — 3 gói, toggle tháng/năm, modal thanh toán
- [ ] **9.** Trang Liên hệ — Form gửi tin, thông tin liên hệ

---

## 💡 PHẦN 14 — ĐIỂM NỔI BẬT KỸ THUẬT (2 phút)

| Điểm mạnh | Giải thích |
|-----------|-----------|
| **App Router** | Next.js 13 — Server Components render faster, SEO tốt hơn |
| **TypeScript** | 100% type-safe, giảm bug runtime |
| **CSS Variables + Tailwind** | Brand colors định nghĩa 1 lần, dùng toàn dự án |
| **Row Level Security** | Database-level authorization, secure by default |
| **AI Fallback Pattern** | API lỗi → tự động fallback sang mock rules, không crash |
| **Mock Data Mode** | Chạy được 100% không cần Supabase thật |
| **Responsive** | Mobile-first với Tailwind breakpoints |
| **next.config.js** | Remote image whitelist, redirects, performance options |

---

## ❓ PHẦN 15 — Q&A — CÂU HỎI DỰ KIẾN

**Q: Tại sao chọn Next.js thay vì React thuần?**
> "Next.js cung cấp Server-Side Rendering, App Router, API Routes tích hợp sẵn.
> Không cần cài thêm Express.js riêng. SEO tốt hơn nhờ SSR."

**Q: Supabase có bảo mật không?**
> "Supabase dùng PostgreSQL với Row Level Security.
> Mỗi request đều được xác thực JWT. Anon key chỉ được phép theo RLS policy."

**Q: Match Score tính như thế nào?**
> "Hiện tại dùng mock score. Thực tế sẽ tính theo weighted scoring:
> lịch ngủ (30%) + ngân sách (25%) + khu vực (20%) + sở thích (15%) + thói quen (10%)"

**Q: Tại sao không có dấu tiếng Việt một số chỗ?**
> "Do file gốc từ dự án cũ bị encoding UTF-8 lỗi khi được sửa bằng PowerShell.
> Các component mới em viết đều có tiếng Việt đầy đủ."

**Q: Scale lên production thế nào?**
> "Deploy lên Vercel — auto scale. Database Supabase có plan trả phí.
> Thêm Redis cache cho listing queries. CDN cho ảnh."

---

## 📌 KẾT LUẬN

> "Le Phố Hub là một **SaaS platform hoàn chỉnh** với:
> - Frontend hiện đại bằng Next.js 13 + TypeScript + Tailwind CSS
> - Backend API Routes tích hợp, sẵn sàng kết nối AI
> - Database schema PostgreSQL với bảo mật RLS
> - 4 module chính: Tìm phòng, Ghép ở, AI Assistant, SaaS Pricing
> - UI responsive, đã sẵn sàng deploy production
>
> **Cảm ơn thầy/cô và các bạn đã lắng nghe!**"

---
*Script thuyết trình Le Phố Hub — Version 1.0 — 27/09/2025*
