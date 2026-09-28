-- =====================================================
-- CTV Commission System - Database Migration
-- Hệ thống hoa hồng CTV sale phòng trọ
-- =====================================================

-- 1. Mở rộng bảng profiles - thêm role 'ctv'
-- Note: Cần ALTER CHECK constraint trên cột role
ALTER TABLE public.profiles 
  DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE public.profiles 
  ADD CONSTRAINT profiles_role_check 
  CHECK (role = ANY (ARRAY['owner'::text, 'renter'::text, 'admin'::text, 'ctv'::text]));

-- 2. Bảng ctv_profiles - Hồ sơ CTV
CREATE TABLE IF NOT EXISTS public.ctv_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  referral_code text NOT NULL,
  commission_rate numeric NOT NULL DEFAULT 10, -- % hoa hồng mặc định 10%
  bank_name text,
  bank_account text,
  bank_owner text,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'active'::text, 'suspended'::text])),
  total_earned numeric DEFAULT 0,
  total_paid numeric DEFAULT 0,
  note text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ctv_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT ctv_profiles_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id),
  CONSTRAINT ctv_profiles_referral_code_key UNIQUE (referral_code),
  CONSTRAINT ctv_profiles_profile_id_key UNIQUE (profile_id)
);

-- 3. Bảng ctv_referrals - Lượt giới thiệu
CREATE TABLE IF NOT EXISTS public.ctv_referrals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ctv_id uuid NOT NULL,
  booking_id uuid,
  room_id uuid NOT NULL,
  referred_user_id uuid,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'cancelled'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ctv_referrals_pkey PRIMARY KEY (id),
  CONSTRAINT ctv_referrals_ctv_id_fkey FOREIGN KEY (ctv_id) REFERENCES public.ctv_profiles(id),
  CONSTRAINT ctv_referrals_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.bookings(id),
  CONSTRAINT ctv_referrals_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT ctv_referrals_referred_user_id_fkey FOREIGN KEY (referred_user_id) REFERENCES public.profiles(id)
);

-- 4. Bảng ctv_commissions - Hoa hồng
CREATE TABLE IF NOT EXISTS public.ctv_commissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ctv_id uuid NOT NULL,
  referral_id uuid NOT NULL,
  amount numeric NOT NULL,
  commission_rate numeric NOT NULL,
  room_price numeric NOT NULL,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'approved'::text, 'paid'::text, 'rejected'::text])),
  paid_at timestamp with time zone,
  approved_by uuid,
  note text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ctv_commissions_pkey PRIMARY KEY (id),
  CONSTRAINT ctv_commissions_ctv_id_fkey FOREIGN KEY (ctv_id) REFERENCES public.ctv_profiles(id),
  CONSTRAINT ctv_commissions_referral_id_fkey FOREIGN KEY (referral_id) REFERENCES public.ctv_referrals(id),
  CONSTRAINT ctv_commissions_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.profiles(id)
);

-- 5. Indexes cho performance
CREATE INDEX IF NOT EXISTS idx_ctv_profiles_profile_id ON public.ctv_profiles(profile_id);
CREATE INDEX IF NOT EXISTS idx_ctv_profiles_referral_code ON public.ctv_profiles(referral_code);
CREATE INDEX IF NOT EXISTS idx_ctv_profiles_status ON public.ctv_profiles(status);

CREATE INDEX IF NOT EXISTS idx_ctv_referrals_ctv_id ON public.ctv_referrals(ctv_id);
CREATE INDEX IF NOT EXISTS idx_ctv_referrals_booking_id ON public.ctv_referrals(booking_id);
CREATE INDEX IF NOT EXISTS idx_ctv_referrals_room_id ON public.ctv_referrals(room_id);
CREATE INDEX IF NOT EXISTS idx_ctv_referrals_status ON public.ctv_referrals(status);

CREATE INDEX IF NOT EXISTS idx_ctv_commissions_ctv_id ON public.ctv_commissions(ctv_id);
CREATE INDEX IF NOT EXISTS idx_ctv_commissions_status ON public.ctv_commissions(status);
CREATE INDEX IF NOT EXISTS idx_ctv_commissions_created_at ON public.ctv_commissions(created_at DESC);

-- 6. Enable RLS
ALTER TABLE public.ctv_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ctv_referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ctv_commissions ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies cho ctv_profiles
-- Admin có thể xem tất cả
CREATE POLICY "Admins can manage all ctv_profiles"
  ON public.ctv_profiles FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- CTV xem hồ sơ của mình
CREATE POLICY "CTV can view own profile"
  ON public.ctv_profiles FOR SELECT
  USING (profile_id = auth.uid());

-- CTV có thể cập nhật thông tin bank
CREATE POLICY "CTV can update own bank info"
  ON public.ctv_profiles FOR UPDATE
  USING (profile_id = auth.uid())
  WITH CHECK (profile_id = auth.uid());

-- Authenticated users có thể tạo CTV profile (đăng ký làm CTV)
CREATE POLICY "Authenticated users can register as CTV"
  ON public.ctv_profiles FOR INSERT
  WITH CHECK (profile_id = auth.uid());

-- 8. RLS Policies cho ctv_referrals
CREATE POLICY "Admins can manage all ctv_referrals"
  ON public.ctv_referrals FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "CTV can view own referrals"
  ON public.ctv_referrals FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.ctv_profiles
      WHERE ctv_profiles.id = ctv_referrals.ctv_id
      AND ctv_profiles.profile_id = auth.uid()
    )
  );

CREATE POLICY "CTV can create referrals"
  ON public.ctv_referrals FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.ctv_profiles
      WHERE ctv_profiles.id = ctv_referrals.ctv_id
      AND ctv_profiles.profile_id = auth.uid()
      AND ctv_profiles.status = 'active'
    )
  );

-- 9. RLS Policies cho ctv_commissions
CREATE POLICY "Admins can manage all ctv_commissions"
  ON public.ctv_commissions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "CTV can view own commissions"
  ON public.ctv_commissions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.ctv_profiles
      WHERE ctv_profiles.id = ctv_commissions.ctv_id
      AND ctv_profiles.profile_id = auth.uid()
    )
  );

-- 10. Grant permissions
GRANT ALL ON public.ctv_profiles TO authenticated;
GRANT ALL ON public.ctv_referrals TO authenticated;
GRANT ALL ON public.ctv_commissions TO authenticated;

-- 11. Function tự động tạo hoa hồng khi booking được approve
CREATE OR REPLACE FUNCTION public.auto_create_ctv_commission()
RETURNS TRIGGER AS $$
DECLARE
  v_referral RECORD;
  v_ctv RECORD;
  v_room RECORD;
  v_commission_amount numeric;
BEGIN
  -- Chỉ xử lý khi booking chuyển sang 'approved'
  IF NEW.status = 'approved' AND (OLD.status IS NULL OR OLD.status != 'approved') THEN
    -- Tìm referral liên quan đến booking này
    SELECT * INTO v_referral 
    FROM public.ctv_referrals 
    WHERE booking_id = NEW.id 
    AND status = 'pending' 
    LIMIT 1;
    
    IF v_referral IS NOT NULL THEN
      -- Lấy thông tin CTV
      SELECT * INTO v_ctv 
      FROM public.ctv_profiles 
      WHERE id = v_referral.ctv_id 
      AND status = 'active';
      
      IF v_ctv IS NOT NULL THEN
        -- Lấy giá phòng
        SELECT * INTO v_room 
        FROM public.rooms 
        WHERE id = NEW.room_id;
        
        -- Tính hoa hồng
        v_commission_amount := (v_room.price * v_ctv.commission_rate) / 100;
        
        -- Tạo commission record
        INSERT INTO public.ctv_commissions (
          ctv_id, referral_id, amount, commission_rate, room_price, status
        ) VALUES (
          v_ctv.id, v_referral.id, v_commission_amount, v_ctv.commission_rate, v_room.price, 'pending'
        );
        
        -- Cập nhật referral status
        UPDATE public.ctv_referrals 
        SET status = 'confirmed' 
        WHERE id = v_referral.id;
        
        -- Cập nhật tổng tiền CTV đã kiếm
        UPDATE public.ctv_profiles 
        SET total_earned = total_earned + v_commission_amount,
            updated_at = now()
        WHERE id = v_ctv.id;
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. Trigger trên bảng bookings
DROP TRIGGER IF EXISTS trigger_auto_ctv_commission ON public.bookings;
CREATE TRIGGER trigger_auto_ctv_commission
  AFTER UPDATE ON public.bookings
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_create_ctv_commission();

-- 13. Function cập nhật total_paid khi commission được thanh toán
CREATE OR REPLACE FUNCTION public.update_ctv_total_paid()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'paid' AND (OLD.status IS NULL OR OLD.status != 'paid') THEN
    UPDATE public.ctv_profiles 
    SET total_paid = total_paid + NEW.amount,
        updated_at = now()
    WHERE id = NEW.ctv_id;
    
    NEW.paid_at := now();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_update_ctv_paid ON public.ctv_commissions;
CREATE TRIGGER trigger_update_ctv_paid
  BEFORE UPDATE ON public.ctv_commissions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_ctv_total_paid();

-- Comments
COMMENT ON TABLE public.ctv_profiles IS 'Hồ sơ Cộng tác viên (CTV) sale phòng trọ';
COMMENT ON TABLE public.ctv_referrals IS 'Lượt giới thiệu khách thuê phòng từ CTV';
COMMENT ON TABLE public.ctv_commissions IS 'Hoa hồng CTV từ giới thiệu thành công';
COMMENT ON COLUMN public.ctv_profiles.commission_rate IS 'Tỷ lệ hoa hồng (%), mặc định 10%';
COMMENT ON COLUMN public.ctv_profiles.referral_code IS 'Mã giới thiệu duy nhất của CTV';
