-- =========================================================================
-- Le Pho Hub — Migration: hanoi_districts table
-- Thay the bang universities (Hoa Lac) bang cac quan noi thanh Ha Noi
-- =========================================================================

-- 1. Tao bang hanoi_districts
CREATE TABLE IF NOT EXISTS public.hanoi_districts (
  id        uuid NOT NULL DEFAULT gen_random_uuid(),
  name      text NOT NULL,            -- Ten day du: "Dong Da"
  slug      text NOT NULL UNIQUE,     -- URL slug: "dong-da"
  type      text NOT NULL DEFAULT 'noi_thanh',
            -- 'noi_thanh' | 'vung_ven'
  lat       numeric,
  lng       numeric,
  image_url text,
  description text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT hanoi_districts_pkey PRIMARY KEY (id),
  CONSTRAINT hanoi_districts_type_check CHECK (
    type = ANY (ARRAY['noi_thanh'::text, 'vung_ven'::text])
  )
);

-- 2. Seed du lieu cac quan Ha Noi
INSERT INTO public.hanoi_districts (name, slug, type, lat, lng, description) VALUES
  ('Dong Da',      'dong-da',      'noi_thanh', 21.0245, 105.8412, 'Trung tam van hoa, nhieu truong DH, gia phong hop ly'),
  ('Ba Dinh',      'ba-dinh',      'noi_thanh', 21.0333, 105.8412, 'Trung tam chinh tri, pho co Ha Noi'),
  ('Hoan Kiem',    'hoan-kiem',    'noi_thanh', 21.0285, 105.8542, 'Khu pho co, ho Hoan Kiem, trung tam lich su'),
  ('Hai Ba Trung', 'hai-ba-trung', 'noi_thanh', 21.0138, 105.8565, 'Khu pho cu, kien truc Phap thuoc'),
  ('Cau Giay',     'cau-giay',     'vung_ven',  21.0312, 105.7956, 'Khu vuc sinh vien soi dong, gan DH Quoc Gia'),
  ('Thanh Xuan',   'thanh-xuan',   'vung_ven',  20.9956, 105.8196, 'Nhieu van phong, khu dan cu hien dai'),
  ('Nam Tu Liem',  'nam-tu-liem',  'vung_ven',  21.0167, 105.7578, 'Khu do thi moi, nhieu chung cu mini'),
  ('Bac Tu Liem',  'bac-tu-liem',  'vung_ven',  21.0729, 105.7728, 'Gan cac khu cong nghiep, gia binh dan'),
  ('Hoang Mai',    'hoang-mai',    'vung_ven',  20.9774, 105.8431, 'Khu dan cu dong duc, nhieu tien ich'),
  ('Long Bien',    'long-bien',    'vung_ven',  21.0456, 105.8879, 'Khu vuc moi phat trien, giao thong tot'),
  ('Tay Ho',       'tay-ho',       'noi_thanh', 21.0712, 105.8234, 'Ho Tay, khu expat, cafe dep'),
  ('Thanh Tri',    'thanh-tri',    'vung_ven',  20.9521, 105.8467, 'Vung ven phia nam, gia phong re')
ON CONFLICT (slug) DO NOTHING;

-- 3. RLS Policies cho hanoi_districts
ALTER TABLE public.hanoi_districts ENABLE ROW LEVEL SECURITY;

-- Cho phep tat ca doc (public)
CREATE POLICY "public_read_hanoi_districts"
  ON public.hanoi_districts FOR SELECT
  USING (true);

-- Chi admin moi duoc insert/update/delete
CREATE POLICY "admin_manage_hanoi_districts"
  ON public.hanoi_districts FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- 4. Them cot district_id vao bang rooms (thay the hoac bo sung university_id)
ALTER TABLE public.rooms
  ADD COLUMN IF NOT EXISTS district_id uuid
  REFERENCES public.hanoi_districts(id) ON DELETE SET NULL;

-- Index de query nhanh theo quan
CREATE INDEX IF NOT EXISTS idx_rooms_district_id ON public.rooms(district_id);
