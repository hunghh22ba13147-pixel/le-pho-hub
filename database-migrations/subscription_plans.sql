-- ================================================================
-- Le Pho Hub — SaaS Subscription Plans
-- ================================================================

CREATE TABLE subscription_plans (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          VARCHAR(50) NOT NULL,     -- 'free' | 'pro' | 'business'
  display_name  VARCHAR(100),
  price_monthly INTEGER NOT NULL,         -- VND/thang (0 = Mien phi)
  price_yearly  INTEGER,                  -- VND/nam (giam 20%)
  max_listings  INTEGER,                  -- NULL = khong gioi han
  features      JSONB,                    -- Danh sach tinh nang
  is_popular    BOOLEAN DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- Du lieu goi dich vu
INSERT INTO subscription_plans (name, display_name, price_monthly, price_yearly, max_listings, features, is_popular) VALUES
  ('free', 'Mien Phi', 0, 0, 3,
    '["Toi da 3 tin dang/thang", "Thong ke co ban", "Ho tro email"]'::jsonb,
    false),
  ('pro', 'Chu Tro Pro', 299000, 2868000, 20,
    '["Toi da 20 tin dang", "Hoa don tu dong", "Ghi dien nuoc", "14 ngay dung thu"]'::jsonb,
    true),
  ('business', 'Doanh Nghiep', 799000, 7670000, NULL,
    '["Khong gioi han tin dang", "Quan ly CTV & hoa hong", "API tich hop", "Ho tro 24/7"]'::jsonb,
    false);

-- Bang dang ky goi cua chu tro
CREATE TABLE user_subscriptions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id         UUID REFERENCES subscription_plans(id),
  status          VARCHAR(20) DEFAULT 'active',  -- 'active' | 'cancelled' | 'expired'
  payment_method  VARCHAR(20),                    -- 'momo' | 'vnpay' | 'bank'
  started_at      TIMESTAMPTZ DEFAULT now(),
  expires_at      TIMESTAMPTZ,
  UNIQUE(user_id)
);

ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "User manages own subscription"
  ON user_subscriptions FOR ALL USING (auth.uid() = user_id);
