-- ================================================================
-- Le Pho Hub — Database Schema
-- Smart Housing SaaS & Roommate Matching Platform
-- ================================================================

-- Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =========================
-- 1. BANG PHONG TRO
-- =========================
CREATE TABLE listings (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title         VARCHAR(200) NOT NULL,
  description   TEXT,
  price         INTEGER NOT NULL,         -- VND/thang
  area          DECIMAL(6,2),             -- m2
  district      VARCHAR(100),             -- Quan noi thanh Ha Noi
  address       TEXT,
  images        TEXT[],                   -- Mang URL anh
  owner_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_active     BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- =========================
-- 2. BANG HO SO GHEP O
-- =========================
CREATE TABLE roommate_profiles (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name       VARCHAR(100),
  age             INTEGER,
  gender          VARCHAR(10),             -- 'male' | 'female'
  occupation      VARCHAR(20),             -- 'student' | 'working' | 'freelance'
  district        VARCHAR(100),            -- Quan muon thue
  budget_min      INTEGER,                 -- VND/thang
  budget_max      INTEGER,
  sleep_schedule  VARCHAR(20),             -- 'early_bird' | 'night_owl' | 'flexible'
  cooking_habit   VARCHAR(20),             -- 'always' | 'sometimes' | 'never'
  smoking         BOOLEAN DEFAULT false,
  pets            BOOLEAN DEFAULT false,
  personality     VARCHAR(20),             -- 'introvert' | 'extrovert' | 'ambivert'
  interests       TEXT[],                  -- Mang so thich
  bio             TEXT,
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- =========================
-- 3. BANG GHEP O (MATCHES)
-- =========================
CREATE TABLE roommate_matches (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profile_a     UUID REFERENCES roommate_profiles(id) ON DELETE CASCADE,
  profile_b     UUID REFERENCES roommate_profiles(id) ON DELETE CASCADE,
  match_score   INTEGER,                  -- 0-100
  status        VARCHAR(20) DEFAULT 'pending', -- 'pending' | 'accepted' | 'rejected'
  matched_at    TIMESTAMPTZ DEFAULT now()
);

-- =========================
-- 4. BANG TIN NHAN
-- =========================
CREATE TABLE messages (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  match_id      UUID REFERENCES roommate_matches(id) ON DELETE CASCADE,
  sender_id     UUID REFERENCES auth.users(id),
  content       TEXT NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- =========================
-- 5. BANG YEU THICH
-- =========================
CREATE TABLE wishlist (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id    UUID REFERENCES listings(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, listing_id)
);

-- =========================
-- 6. ROW LEVEL SECURITY
-- =========================
ALTER TABLE listings         ENABLE ROW LEVEL SECURITY;
ALTER TABLE roommate_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE roommate_matches  ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages          ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlist          ENABLE ROW LEVEL SECURITY;

-- Listings: ai cung xem duoc, chu so huu moi sua/xoa
CREATE POLICY "Public can view active listings"
  ON listings FOR SELECT USING (is_active = true);

CREATE POLICY "Owner can manage own listings"
  ON listings FOR ALL USING (auth.uid() = owner_id);

-- Roommate profiles: chi chu so huu moi sua
CREATE POLICY "Public can view active profiles"
  ON roommate_profiles FOR SELECT USING (is_active = true);

CREATE POLICY "Owner can manage own profile"
  ON roommate_profiles FOR ALL USING (auth.uid() = user_id);

-- Wishlist: rieng tu
CREATE POLICY "User can manage own wishlist"
  ON wishlist FOR ALL USING (auth.uid() = user_id);
