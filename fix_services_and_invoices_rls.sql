-- =====================================================
-- KHẮC PHỤC LỖI RLS CHO DỊCH VỤ, HÓA ĐƠN & BẢO TRÌ
-- Chạy script này trong Supabase SQL Editor để sửa lỗi
-- "new row violates row-level security policy for table services"
-- =====================================================

-- 1. Kích hoạt RLS cho các bảng liên quan nếu chưa kích hoạt
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unit_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_requests ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- BẢNG SERVICES (DỊCH VỤ) RLS POLICIES
-- =====================================================
DROP POLICY IF EXISTS "Owners can view their services" ON public.services;
DROP POLICY IF EXISTS "Owners can create services" ON public.services;
DROP POLICY IF EXISTS "Owners can update their services" ON public.services;
DROP POLICY IF EXISTS "Owners can delete their services" ON public.services;

CREATE POLICY "Owners can view their services" ON public.services
  FOR SELECT TO authenticated
  USING (owner_id = auth.uid());

CREATE POLICY "Owners can create services" ON public.services
  FOR INSERT TO authenticated
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Owners can update their services" ON public.services
  FOR UPDATE TO authenticated
  USING (owner_id = auth.uid());

CREATE POLICY "Owners can delete their services" ON public.services
  FOR DELETE TO authenticated
  USING (owner_id = auth.uid());

-- =====================================================
-- BẢNG UNIT_SERVICES (DỊCH VỤ PHÒNG) RLS POLICIES
-- =====================================================
DROP POLICY IF EXISTS "Owners can view unit services" ON public.unit_services;
DROP POLICY IF EXISTS "Owners can insert unit services" ON public.unit_services;
DROP POLICY IF EXISTS "Owners can delete unit services" ON public.unit_services;

CREATE POLICY "Owners can view unit services" ON public.unit_services
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.room_units
      JOIN public.rooms ON rooms.id = room_units.room_id
      WHERE room_units.id = unit_services.room_unit_id
      AND rooms.owner_id = auth.uid()
    )
  );

CREATE POLICY "Owners can insert unit services" ON public.unit_services
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.room_units
      JOIN public.rooms ON rooms.id = room_units.room_id
      WHERE room_units.id = unit_services.room_unit_id
      AND rooms.owner_id = auth.uid()
    )
  );

CREATE POLICY "Owners can delete unit services" ON public.unit_services
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.room_units
      JOIN public.rooms ON rooms.id = room_units.room_id
      WHERE room_units.id = unit_services.room_unit_id
      AND rooms.owner_id = auth.uid()
    )
  );

-- =====================================================
-- BẢNG INVOICES (HÓA ĐƠN) RLS POLICIES
-- =====================================================
DROP POLICY IF EXISTS "Owners can view their invoices" ON public.invoices;
DROP POLICY IF EXISTS "Owners can create invoices" ON public.invoices;
DROP POLICY IF EXISTS "Owners can update their invoices" ON public.invoices;
DROP POLICY IF EXISTS "Renters can view their invoices" ON public.invoices;

CREATE POLICY "Owners can view their invoices" ON public.invoices
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.room_units
      JOIN public.rooms ON rooms.id = room_units.room_id
      WHERE room_units.id = invoices.room_unit_id
      AND rooms.owner_id = auth.uid()
    )
  );

CREATE POLICY "Owners can create invoices" ON public.invoices
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.room_units
      JOIN public.rooms ON rooms.id = room_units.room_id
      WHERE room_units.id = invoices.room_unit_id
      AND rooms.owner_id = auth.uid()
    )
  );

CREATE POLICY "Owners can update their invoices" ON public.invoices
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.room_units
      JOIN public.rooms ON rooms.id = room_units.room_id
      WHERE room_units.id = invoices.room_unit_id
      AND rooms.owner_id = auth.uid()
    )
  );

CREATE POLICY "Renters can view their invoices" ON public.invoices
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.contracts
      WHERE contracts.id = invoices.contract_id
      AND contracts.renter_id = auth.uid()
    )
  );

-- =====================================================
-- BẢNG INVOICE_ITEMS (CHI TIẾT HÓA ĐƠN) RLS POLICIES
-- =====================================================
DROP POLICY IF EXISTS "Owners can view invoice items" ON public.invoice_items;
DROP POLICY IF EXISTS "Owners can create invoice items" ON public.invoice_items;
DROP POLICY IF EXISTS "Renters can view their invoice items" ON public.invoice_items;

CREATE POLICY "Owners can view invoice items" ON public.invoice_items
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.invoices
      JOIN public.room_units ON room_units.id = invoices.room_unit_id
      JOIN public.rooms ON rooms.id = room_units.room_id
      WHERE invoices.id = invoice_items.invoice_id
      AND rooms.owner_id = auth.uid()
    )
  );

CREATE POLICY "Owners can create invoice items" ON public.invoice_items
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.invoices
      JOIN public.room_units ON room_units.id = invoices.room_unit_id
      JOIN public.rooms ON rooms.id = room_units.room_id
      WHERE invoices.id = invoice_items.invoice_id
      AND rooms.owner_id = auth.uid()
    )
  );

CREATE POLICY "Renters can view their invoice items" ON public.invoice_items
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.invoices
      JOIN public.contracts ON contracts.id = invoices.contract_id
      WHERE invoices.id = invoice_items.invoice_id
      AND contracts.renter_id = auth.uid()
    )
  );

-- =====================================================
-- BẢNG MAINTENANCE_REQUESTS (BẢO TRÌ) RLS POLICIES
-- =====================================================
DROP POLICY IF EXISTS "Owners can view maintenance requests" ON public.maintenance_requests;
DROP POLICY IF EXISTS "Owners can update maintenance requests" ON public.maintenance_requests;
DROP POLICY IF EXISTS "Renters can create maintenance requests" ON public.maintenance_requests;
DROP POLICY IF EXISTS "Renters can view their maintenance requests" ON public.maintenance_requests;
DROP POLICY IF EXISTS "Renters can update their pending requests" ON public.maintenance_requests;

CREATE POLICY "Owners can view maintenance requests" ON public.maintenance_requests
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.room_units
      JOIN public.rooms ON rooms.id = room_units.room_id
      WHERE room_units.id = maintenance_requests.room_unit_id
      AND rooms.owner_id = auth.uid()
    )
  );

CREATE POLICY "Owners can update maintenance requests" ON public.maintenance_requests
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.room_units
      JOIN public.rooms ON rooms.id = room_units.room_id
      WHERE room_units.id = maintenance_requests.room_unit_id
      AND rooms.owner_id = auth.uid()
    )
  );

CREATE POLICY "Renters can create maintenance requests" ON public.maintenance_requests
  FOR INSERT TO authenticated
  WITH CHECK (renter_id = auth.uid());

CREATE POLICY "Renters can view their maintenance requests" ON public.maintenance_requests
  FOR SELECT TO authenticated
  USING (renter_id = auth.uid());

CREATE POLICY "Renters can update their pending requests" ON public.maintenance_requests
  FOR UPDATE TO authenticated
  USING (
    renter_id = auth.uid() 
    AND status = 'pending'
  );

-- =====================================================
-- BỔ SUNG QUYỀN TRUY CẬP CHO ADMINS (QUẢN TRỊ VIÊN)
-- =====================================================
DROP POLICY IF EXISTS "Admins can do everything on services" ON public.services;
CREATE POLICY "Admins can do everything on services" ON public.services
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can do everything on unit_services" ON public.unit_services;
CREATE POLICY "Admins can do everything on unit_services" ON public.unit_services
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can do everything on invoices" ON public.invoices;
CREATE POLICY "Admins can do everything on invoices" ON public.invoices
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can do everything on invoice_items" ON public.invoice_items;
CREATE POLICY "Admins can do everything on invoice_items" ON public.invoice_items
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can do everything on maintenance_requests" ON public.maintenance_requests;
CREATE POLICY "Admins can do everything on maintenance_requests" ON public.maintenance_requests
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Kiểm tra xem đã tạo policies thành công hay chưa
SELECT schemaname, tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('services', 'unit_services', 'invoices', 'invoice_items', 'maintenance_requests')
ORDER BY tablename, policyname;
