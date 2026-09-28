-- =========================================================================
-- Le Pho Hub — Migration: SaaS Subscription Plans (Phase 3)
-- Quan ly goi dang ky SaaS cho chu tro
-- =========================================================================

-- 1. Bang dinh nghia cac goi dich vu
CREATE TABLE IF NOT EXISTS public.subscription_plans (
  id            uuid NOT NULL DEFAULT gen_random_uuid(),
  name          text NOT NULL,           -- 'free' | 'pro' | 'business'
  display_name  text NOT NULL,           -- 'Mien Phi' | 'Chu Tro Pro' | 'Doanh Nghiep'
  price_monthly integer NOT NULL DEFAULT 0,  -- VND/thang
  price_yearly  integer NOT NULL DEFAULT 0,  -- VND/thang (thanh toan nam)
  max_rooms     integer,                 -- NULL = khong gioi han
  features      jsonb NOT NULL DEFAULT '[]'::jsonb,
  is_active     boolean NOT NULL DEFAULT true,
  sort_order    integer NOT NULL DEFAULT 0,
  created_at    timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT subscription_plans_pkey PRIMARY KEY (id),
  CONSTRAINT subscription_plans_name_unique UNIQUE (name)
);

-- 2. Seed data goi dich vu
INSERT INTO public.subscription_plans (name, display_name, price_monthly, price_yearly, max_rooms, sort_order, features)
VALUES
  ('free', 'Mien Phi', 0, 0, 3, 1, '[
    "Toi da 3 phong tro",
    "Dang tin co ban",
    "Xem danh sach khach thue",
    "Ho tro email"
  ]'::jsonb),
  ('pro', 'Chu Tro Pro', 299000, 249000, 20, 2, '[
    "Toi da 20 phong tro",
    "Dang tin nang cao + anh dep",
    "Quan ly khach thue day du",
    "Ho tro uu tien (chat + email)",
    "Quan ly hoa don tu dong",
    "Ghi chi so dien nuoc",
    "Thong bao tu dong (Zalo/Email)",
    "Bao cao doanh thu hang thang"
  ]'::jsonb),
  ('business', 'Doanh Nghiep', 799000, 649000, NULL, 3, '[
    "Khong gioi han phong tro",
    "Dang tin VIP uu tien hien thi",
    "Quan ly khach thue day du",
    "Ho tro 24/7 + account manager rieng",
    "Quan ly hoa don tu dong",
    "Ghi chi so dien nuoc",
    "Thong bao Zalo/Email/SMS",
    "He thong CTV va quan ly hoa hong"
  ]'::jsonb)
ON CONFLICT (name) DO UPDATE SET
  price_monthly = EXCLUDED.price_monthly,
  price_yearly  = EXCLUDED.price_yearly,
  max_rooms     = EXCLUDED.max_rooms,
  features      = EXCLUDED.features;

-- 3. Bang dang ky goi cho tung chu tro (landlord)
CREATE TABLE IF NOT EXISTS public.landlord_subscriptions (
  id               uuid NOT NULL DEFAULT gen_random_uuid(),
  landlord_id      uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  plan_id          uuid NOT NULL REFERENCES public.subscription_plans(id),
  billing_cycle    text NOT NULL DEFAULT 'monthly',  -- 'monthly' | 'yearly'
  status           text NOT NULL DEFAULT 'trialing', -- 'trialing' | 'active' | 'cancelled' | 'expired'
  trial_ends_at    timestamptz,
  current_period_start timestamptz NOT NULL DEFAULT now(),
  current_period_end   timestamptz,
  cancelled_at     timestamptz,
  payment_method   text,                -- 'momo' | 'vnpay' | 'bank'
  amount_paid      integer DEFAULT 0,   -- VND
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT landlord_subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT landlord_subscriptions_billing_check CHECK (billing_cycle = ANY (ARRAY['monthly'::text, 'yearly'::text])),
  CONSTRAINT landlord_subscriptions_status_check CHECK (status = ANY (ARRAY['trialing','active','cancelled','expired']))
);

CREATE INDEX IF NOT EXISTS idx_landlord_subscriptions_landlord ON public.landlord_subscriptions(landlord_id);
CREATE INDEX IF NOT EXISTS idx_landlord_subscriptions_status ON public.landlord_subscriptions(status);

-- 4. Bang lich su thanh toan
CREATE TABLE IF NOT EXISTS public.payment_history (
  id               uuid NOT NULL DEFAULT gen_random_uuid(),
  subscription_id  uuid NOT NULL REFERENCES public.landlord_subscriptions(id) ON DELETE CASCADE,
  landlord_id      uuid NOT NULL REFERENCES public.profiles(id),
  plan_name        text NOT NULL,
  amount           integer NOT NULL,    -- VND
  payment_method   text NOT NULL,       -- 'momo' | 'vnpay' | 'bank'
  payment_ref      text,                -- Ma giao dich tu cong thanh toan
  status           text NOT NULL DEFAULT 'pending', -- 'pending' | 'success' | 'failed'
  paid_at          timestamptz,
  created_at       timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT payment_history_pkey PRIMARY KEY (id)
);

-- 5. RLS Policies
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.landlord_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_history ENABLE ROW LEVEL SECURITY;

-- Tat ca co the doc bang ke hoach (de hien thi trang pricing)
CREATE POLICY "public_read_subscription_plans"
  ON public.subscription_plans FOR SELECT USING (true);

-- Chu tro chi xem dang ky cua chinh minh
CREATE POLICY "landlord_own_subscription"
  ON public.landlord_subscriptions FOR ALL
  USING (landlord_id = auth.uid());

-- Admin quan ly tat ca
CREATE POLICY "admin_manage_subscriptions"
  ON public.landlord_subscriptions FOR ALL
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "landlord_own_payments"
  ON public.payment_history FOR SELECT
  USING (landlord_id = auth.uid());

-- 6. Function kiem tra gioi han phong cua chu tro
CREATE OR REPLACE FUNCTION public.get_landlord_room_limit(p_landlord_id uuid)
RETURNS integer AS 
DECLARE
  v_max_rooms integer;
BEGIN
  SELECT sp.max_rooms INTO v_max_rooms
  FROM public.landlord_subscriptions ls
  JOIN public.subscription_plans sp ON sp.id = ls.plan_id
  WHERE ls.landlord_id = p_landlord_id
    AND ls.status IN ('trialing', 'active')
    AND (ls.current_period_end IS NULL OR ls.current_period_end > now())
  ORDER BY sp.max_rooms DESC NULLS FIRST
  LIMIT 1;

  -- Mac dinh tra ve gioi han goi Free (3 phong) neu chua dang ky
  RETURN COALESCE(v_max_rooms, 3);
END;
 LANGUAGE plpgsql SECURITY DEFINER;