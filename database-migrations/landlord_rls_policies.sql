-- =====================================================
-- Row Level Security Policies for Landlord Features
-- =====================================================

-- Enable RLS on all landlord tables
ALTER TABLE public.room_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unit_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenant_profiles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- ROOM UNITS POLICIES
-- =====================================================

-- Owners can view their own room units
CREATE POLICY "Owners can view their room units"
ON public.room_units
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.rooms
    WHERE rooms.id = room_units.room_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Owners can insert room units for their properties
CREATE POLICY "Owners can insert room units"
ON public.room_units
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.rooms
    WHERE rooms.id = room_units.room_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Owners can update their room units
CREATE POLICY "Owners can update their room units"
ON public.room_units
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.rooms
    WHERE rooms.id = room_units.room_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Owners can delete their room units
CREATE POLICY "Owners can delete their room units"
ON public.room_units
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.rooms
    WHERE rooms.id = room_units.room_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Renters can view their current room unit
CREATE POLICY "Renters can view their room unit"
ON public.room_units
FOR SELECT
USING (current_renter_id = auth.uid());

-- =====================================================
-- CONTRACTS POLICIES
-- =====================================================

-- Owners can view contracts for their properties
CREATE POLICY "Owners can view their contracts"
ON public.contracts
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = contracts.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Owners can create contracts
CREATE POLICY "Owners can create contracts"
ON public.contracts
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = contracts.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Owners can update their contracts
CREATE POLICY "Owners can update their contracts"
ON public.contracts
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = contracts.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Renters can view their own contracts
CREATE POLICY "Renters can view their contracts"
ON public.contracts
FOR SELECT
USING (renter_id = auth.uid());

-- =====================================================
-- SERVICES POLICIES
-- =====================================================

-- Owners can view their services
CREATE POLICY "Owners can view their services"
ON public.services
FOR SELECT
USING (owner_id = auth.uid());

-- Owners can create services
CREATE POLICY "Owners can create services"
ON public.services
FOR INSERT
WITH CHECK (owner_id = auth.uid());

-- Owners can update their services
CREATE POLICY "Owners can update their services"
ON public.services
FOR UPDATE
USING (owner_id = auth.uid());

-- Owners can delete their services
CREATE POLICY "Owners can delete their services"
ON public.services
FOR DELETE
USING (owner_id = auth.uid());

-- =====================================================
-- UNIT SERVICES POLICIES
-- =====================================================

-- Owners can manage unit services
CREATE POLICY "Owners can view unit services"
ON public.unit_services
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = unit_services.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

CREATE POLICY "Owners can insert unit services"
ON public.unit_services
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = unit_services.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

CREATE POLICY "Owners can delete unit services"
ON public.unit_services
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = unit_services.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

-- =====================================================
-- INVOICES POLICIES
-- =====================================================

-- Owners can view invoices for their properties
CREATE POLICY "Owners can view their invoices"
ON public.invoices
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = invoices.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Owners can create invoices
CREATE POLICY "Owners can create invoices"
ON public.invoices
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = invoices.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Owners can update their invoices
CREATE POLICY "Owners can update their invoices"
ON public.invoices
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = invoices.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Renters can view their invoices
CREATE POLICY "Renters can view their invoices"
ON public.invoices
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.contracts
    WHERE contracts.id = invoices.contract_id
    AND contracts.renter_id = auth.uid()
  )
);

-- =====================================================
-- INVOICE ITEMS POLICIES
-- =====================================================

-- Owners can view invoice items
CREATE POLICY "Owners can view invoice items"
ON public.invoice_items
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.invoices
    JOIN public.room_units ON room_units.id = invoices.room_unit_id
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE invoices.id = invoice_items.invoice_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Owners can create invoice items
CREATE POLICY "Owners can create invoice items"
ON public.invoice_items
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.invoices
    JOIN public.room_units ON room_units.id = invoices.room_unit_id
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE invoices.id = invoice_items.invoice_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Renters can view their invoice items
CREATE POLICY "Renters can view their invoice items"
ON public.invoice_items
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.invoices
    JOIN public.contracts ON contracts.id = invoices.contract_id
    WHERE invoices.id = invoice_items.invoice_id
    AND contracts.renter_id = auth.uid()
  )
);

-- =====================================================
-- MAINTENANCE REQUESTS POLICIES
-- =====================================================

-- Owners can view maintenance requests for their properties
CREATE POLICY "Owners can view maintenance requests"
ON public.maintenance_requests
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = maintenance_requests.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Owners can update maintenance request status
CREATE POLICY "Owners can update maintenance requests"
ON public.maintenance_requests
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.room_units
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE room_units.id = maintenance_requests.room_unit_id
    AND rooms.owner_id = auth.uid()
  )
);

-- Renters can create maintenance requests
CREATE POLICY "Renters can create maintenance requests"
ON public.maintenance_requests
FOR INSERT
WITH CHECK (renter_id = auth.uid());

-- Renters can view their own maintenance requests
CREATE POLICY "Renters can view their maintenance requests"
ON public.maintenance_requests
FOR SELECT
USING (renter_id = auth.uid());

-- Renters can update their own pending requests
CREATE POLICY "Renters can update their pending requests"
ON public.maintenance_requests
FOR UPDATE
USING (
  renter_id = auth.uid() 
  AND status = 'pending'
);

-- =====================================================
-- TENANT PROFILES POLICIES
-- =====================================================

-- Owners can view tenant profiles of their renters
CREATE POLICY "Owners can view tenant profiles"
ON public.tenant_profiles
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.contracts
    JOIN public.room_units ON room_units.id = contracts.room_unit_id
    JOIN public.rooms ON rooms.id = room_units.room_id
    WHERE contracts.renter_id = tenant_profiles.profile_id
    AND rooms.owner_id = auth.uid()
    AND contracts.status = 'active'
  )
);

-- Users can view and update their own tenant profile
CREATE POLICY "Users can view their tenant profile"
ON public.tenant_profiles
FOR SELECT
USING (profile_id = auth.uid());

CREATE POLICY "Users can insert their tenant profile"
ON public.tenant_profiles
FOR INSERT
WITH CHECK (profile_id = auth.uid());

CREATE POLICY "Users can update their tenant profile"
ON public.tenant_profiles
FOR UPDATE
USING (profile_id = auth.uid());

-- =====================================================
-- ADMIN POLICIES (Optional - for admin dashboard)
-- =====================================================

-- Admins can view all data
CREATE POLICY "Admins can view all room units"
ON public.room_units
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

CREATE POLICY "Admins can view all contracts"
ON public.contracts
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

CREATE POLICY "Admins can view all invoices"
ON public.invoices
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

CREATE POLICY "Admins can view all maintenance requests"
ON public.maintenance_requests
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

-- =====================================================
-- INDEXES for Performance
-- =====================================================

-- Room units indexes
CREATE INDEX IF NOT EXISTS idx_room_units_room_id ON public.room_units(room_id);
CREATE INDEX IF NOT EXISTS idx_room_units_status ON public.room_units(status);
CREATE INDEX IF NOT EXISTS idx_room_units_current_renter ON public.room_units(current_renter_id);

-- Contracts indexes
CREATE INDEX IF NOT EXISTS idx_contracts_room_unit_id ON public.contracts(room_unit_id);
CREATE INDEX IF NOT EXISTS idx_contracts_renter_id ON public.contracts(renter_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON public.contracts(status);
CREATE INDEX IF NOT EXISTS idx_contracts_end_date ON public.contracts(end_date);

-- Services indexes
CREATE INDEX IF NOT EXISTS idx_services_owner_id ON public.services(owner_id);
CREATE INDEX IF NOT EXISTS idx_services_type ON public.services(type);

-- Invoices indexes
CREATE INDEX IF NOT EXISTS idx_invoices_room_unit_id ON public.invoices(room_unit_id);
CREATE INDEX IF NOT EXISTS idx_invoices_contract_id ON public.invoices(contract_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON public.invoices(status);
CREATE INDEX IF NOT EXISTS idx_invoices_month_year ON public.invoices(month, year);

-- Invoice items indexes
CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice_id ON public.invoice_items(invoice_id);
CREATE INDEX IF NOT EXISTS idx_invoice_items_service_id ON public.invoice_items(service_id);

-- Maintenance requests indexes
CREATE INDEX IF NOT EXISTS idx_maintenance_room_unit_id ON public.maintenance_requests(room_unit_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_renter_id ON public.maintenance_requests(renter_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_status ON public.maintenance_requests(status);
CREATE INDEX IF NOT EXISTS idx_maintenance_priority ON public.maintenance_requests(priority);

-- Tenant profiles indexes
CREATE INDEX IF NOT EXISTS idx_tenant_profiles_profile_id ON public.tenant_profiles(profile_id);
CREATE INDEX IF NOT EXISTS idx_tenant_profiles_university_id ON public.tenant_profiles(university_id);

-- =====================================================
-- FUNCTIONS for automatic updates
-- =====================================================

-- Function to update room unit status when contract is created
CREATE OR REPLACE FUNCTION update_room_status_on_contract()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'active' THEN
    UPDATE public.room_units
    SET status = 'rented',
        current_renter_id = NEW.renter_id,
        updated_at = NOW()
    WHERE id = NEW.room_unit_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for contract creation
DROP TRIGGER IF EXISTS trigger_update_room_on_contract ON public.contracts;
CREATE TRIGGER trigger_update_room_on_contract
AFTER INSERT OR UPDATE ON public.contracts
FOR EACH ROW
EXECUTE FUNCTION update_room_status_on_contract();

-- Function to update room unit status when contract is terminated
CREATE OR REPLACE FUNCTION update_room_status_on_contract_end()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status IN ('terminated', 'expired') AND OLD.status = 'active' THEN
    UPDATE public.room_units
    SET status = 'available',
        current_renter_id = NULL,
        updated_at = NOW()
    WHERE id = NEW.room_unit_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for contract termination
DROP TRIGGER IF EXISTS trigger_update_room_on_contract_end ON public.contracts;
CREATE TRIGGER trigger_update_room_on_contract_end
AFTER UPDATE ON public.contracts
FOR EACH ROW
EXECUTE FUNCTION update_room_status_on_contract_end();

-- Function to check for overdue invoices
CREATE OR REPLACE FUNCTION check_overdue_invoices()
RETURNS void AS $$
BEGIN
  UPDATE public.invoices
  SET status = 'overdue',
      updated_at = NOW()
  WHERE status = 'unpaid'
    AND due_date < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- You can run this function periodically using pg_cron or external scheduler
-- SELECT check_overdue_invoices();

COMMENT ON FUNCTION check_overdue_invoices() IS 'Updates invoice status to overdue when past due date. Run daily via cron job.';
