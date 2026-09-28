-- 1. Tạo bảng Phòng thực tế (Room Units)
CREATE TABLE IF NOT EXISTS public.room_units (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL, -- Trỏ về bảng rooms (đóng vai trò là bài đăng/tòa nhà)
  name text NOT NULL, -- Tên phòng (VD: Phòng 101, Phòng 102)
  status text DEFAULT 'available'::text CHECK (status = ANY (ARRAY['available'::text, 'rented'::text, 'maintenance'::text])),
  current_renter_id uuid, -- Link tới người đang thuê hiện tại
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT room_units_pkey PRIMARY KEY (id),
  CONSTRAINT room_units_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT room_units_renter_id_fkey FOREIGN KEY (current_renter_id) REFERENCES public.profiles(id)
);

-- 2. Tạo bảng Hợp đồng (Contracts) - Gắn với room_units
CREATE TABLE IF NOT EXISTS public.contracts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_unit_id uuid NOT NULL,
  renter_id uuid NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  deposit_amount numeric DEFAULT 0,
  rent_amount numeric NOT NULL,
  status text DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'expired'::text, 'terminated'::text, 'pending'::text])),
  contract_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contracts_pkey PRIMARY KEY (id),
  CONSTRAINT contracts_room_unit_id_fkey FOREIGN KEY (room_unit_id) REFERENCES public.room_units(id),
  CONSTRAINT contracts_renter_id_fkey FOREIGN KEY (renter_id) REFERENCES public.profiles(id)
);

-- 3. Tạo bảng Dịch vụ (Services)
CREATE TABLE IF NOT EXISTS public.services (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL,
  name text NOT NULL,
  unit_price numeric NOT NULL,
  unit text NOT NULL,
  type text DEFAULT 'variable'::text CHECK (type = ANY (ARRAY['fixed'::text, 'variable'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT services_pkey PRIMARY KEY (id),
  CONSTRAINT services_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profiles(id)
);

-- 4. Bảng liên kết Phòng & Dịch vụ (Unit Services)
CREATE TABLE IF NOT EXISTS public.unit_services (
  room_unit_id uuid NOT NULL,
  service_id uuid NOT NULL,
  CONSTRAINT unit_services_pkey PRIMARY KEY (room_unit_id, service_id),
  CONSTRAINT unit_services_room_unit_id_fkey FOREIGN KEY (room_unit_id) REFERENCES public.room_units(id),
  CONSTRAINT unit_services_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id)
);

-- 5. Tạo bảng Hóa đơn (Invoices)
CREATE TABLE IF NOT EXISTS public.invoices (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_unit_id uuid NOT NULL,
  contract_id uuid NOT NULL,
  month integer NOT NULL CHECK (month >= 1 AND month <= 12),
  year integer NOT NULL,
  total_amount numeric NOT NULL,
  status text DEFAULT 'unpaid'::text CHECK (status = ANY (ARRAY['unpaid'::text, 'paid'::text, 'overdue'::text])),
  due_date date,
  paid_at timestamp with time zone,
  payment_method text,
  payment_proof_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT invoices_pkey PRIMARY KEY (id),
  CONSTRAINT invoices_room_unit_id_fkey FOREIGN KEY (room_unit_id) REFERENCES public.room_units(id),
  CONSTRAINT invoices_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES public.contracts(id)
);

-- 6. Chi tiết hóa đơn (Invoice Items)
CREATE TABLE IF NOT EXISTS public.invoice_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  invoice_id uuid NOT NULL,
  service_id uuid NOT NULL,
  old_index numeric,
  new_index numeric,
  usage numeric,
  unit_price numeric NOT NULL,
  amount numeric NOT NULL,
  CONSTRAINT invoice_items_pkey PRIMARY KEY (id),
  CONSTRAINT invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id),
  CONSTRAINT invoice_items_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id)
);

-- 7. Bảng Yêu cầu bảo trì/hỗ trợ (Maintenance Requests)
CREATE TABLE IF NOT EXISTS public.maintenance_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_unit_id uuid NOT NULL,
  renter_id uuid NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  image_urls text[] DEFAULT '{}'::text[],
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'resolved'::text, 'rejected'::text])),
  priority text DEFAULT 'normal'::text CHECK (priority = ANY (ARRAY['low'::text, 'normal'::text, 'high'::text, 'urgent'::text])),
  resolved_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT maintenance_requests_pkey PRIMARY KEY (id),
  CONSTRAINT maintenance_requests_room_unit_id_fkey FOREIGN KEY (room_unit_id) REFERENCES public.room_units(id),
  CONSTRAINT maintenance_requests_renter_id_fkey FOREIGN KEY (renter_id) REFERENCES public.profiles(id)
);

-- 8. Hồ sơ khách thuê mở rộng (Tenant Profiles)
CREATE TABLE IF NOT EXISTS public.tenant_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  id_card_number text,
  id_card_front_url text,
  id_card_back_url text,
  university_id uuid,
  student_id text,
  hometown text,
  emergency_contact_name text,
  emergency_contact_phone text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tenant_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT tenant_profiles_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id),
  CONSTRAINT tenant_profiles_university_id_fkey FOREIGN KEY (university_id) REFERENCES public.universities(id)
);
