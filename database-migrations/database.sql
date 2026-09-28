-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.amenities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT amenities_pkey PRIMARY KEY (id)
);
CREATE TABLE public.blog_posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  title text NOT NULL,
  description text DEFAULT ''::text,
  content text DEFAULT ''::text,
  featured_image text DEFAULT ''::text,
  category_name text DEFAULT 'Gợi ý nhà ở'::text,
  category_color text DEFAULT 'purple'::text,
  tags ARRAY DEFAULT '{}'::text[],
  author_name text DEFAULT 'Admin'::text,
  author_avatar text DEFAULT ''::text,
  author_bio text DEFAULT ''::text,
  reading_time integer DEFAULT 5,
  comment_count integer DEFAULT 0,
  view_count integer DEFAULT 0,
  post_type text DEFAULT 'standard'::text CHECK (post_type = ANY (ARRAY['standard'::text, 'video'::text, 'gallery'::text, 'audio'::text])),
  published boolean DEFAULT true,
  published_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT blog_posts_pkey PRIMARY KEY (id)
);
CREATE TABLE public.bookings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  user_id uuid NOT NULL,
  check_in_date date NOT NULL,
  check_out_date date NOT NULL,
  guests_count integer NOT NULL DEFAULT 1,
  total_price numeric NOT NULL,
  status text NOT NULL DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'cancelled'::text])),
  message text,
  rejection_reason text,
  approved_by uuid,
  approved_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT bookings_pkey PRIMARY KEY (id),
  CONSTRAINT bookings_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT bookings_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES auth.users(id)
);
CREATE TABLE public.contacts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid,
  renter_id uuid,
  message text,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'seen'::text, 'replied'::text])),
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT contacts_pkey PRIMARY KEY (id),
  CONSTRAINT contacts_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT contacts_renter_id_fkey FOREIGN KEY (renter_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.favorites (
  user_id uuid NOT NULL,
  room_id uuid NOT NULL,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT favorites_pkey PRIMARY KEY (user_id, room_id),
  CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT favorites_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id)
);
CREATE TABLE public.feedbacks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  user_id uuid NOT NULL,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT feedbacks_pkey PRIMARY KEY (id),
  CONSTRAINT feedbacks_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT feedbacks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.nearby_places (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  name character varying NOT NULL,
  category character varying NOT NULL,
  distance_km numeric NOT NULL,
  description text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT nearby_places_pkey PRIMARY KEY (id),
  CONSTRAINT nearby_places_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  content text NOT NULL,
  type text NOT NULL CHECK (type = ANY (ARRAY['info'::text, 'warning'::text, 'success'::text, 'error'::text])),
  target_audience text NOT NULL CHECK (target_audience = ANY (ARRAY['all'::text, 'renters'::text, 'owners'::text, 'admins'::text])),
  is_active boolean DEFAULT true,
  created_by uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  name text NOT NULL,
  phone text,
  role text DEFAULT 'renter'::text CHECK (role = ANY (ARRAY['owner'::text, 'renter'::text, 'admin'::text])),
  created_at timestamp without time zone DEFAULT now(),
  DoB date,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.reviews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid,
  user_id uuid,
  rating integer CHECK (rating >= 1 AND rating <= 5),
  comment text,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT reviews_pkey PRIMARY KEY (id),
  CONSTRAINT reviews_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.room_amenities (
  room_id uuid NOT NULL,
  amenity_id uuid NOT NULL,
  CONSTRAINT room_amenities_pkey PRIMARY KEY (room_id, amenity_id),
  CONSTRAINT room_amenities_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT room_amenities_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES public.amenities(id)
);
CREATE TABLE public.room_images (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid,
  image_url text NOT NULL,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT room_images_pkey PRIMARY KEY (id),
  CONSTRAINT room_images_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id)
);
CREATE TABLE public.room_surroundings (
  room_id uuid NOT NULL,
  surrounding_id uuid NOT NULL,
  CONSTRAINT room_surroundings_pkey PRIMARY KEY (room_id, surrounding_id),
  CONSTRAINT room_surroundings_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT room_surroundings_surrounding_id_fkey FOREIGN KEY (surrounding_id) REFERENCES public.surroundings(id)
);
CREATE TABLE public.room_targets (
  room_id uuid NOT NULL,
  target_id uuid NOT NULL,
  CONSTRAINT room_targets_pkey PRIMARY KEY (room_id, target_id),
  CONSTRAINT room_targets_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT room_targets_target_id_fkey FOREIGN KEY (target_id) REFERENCES public.targets(id)
);
CREATE TABLE public.room_transfers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid,
  user_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  reason text,
  contact_phone text,
  contact_zalo text,
  transfer_date date,
  price_negotiable boolean DEFAULT true,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  approved_by uuid,
  approved_at timestamp with time zone,
  rejection_reason text,
  room_title text,
  room_price numeric,
  room_address text,
  room_area numeric,
  room_images ARRAY,
  CONSTRAINT room_transfers_pkey PRIMARY KEY (id),
  CONSTRAINT room_transfers_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT room_transfers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT room_transfers_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.profiles(id)
);
CREATE TABLE public.room_universities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  university_id uuid NOT NULL,
  distance_km numeric,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT room_universities_pkey PRIMARY KEY (id),
  CONSTRAINT room_universities_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT room_universities_university_id_fkey FOREIGN KEY (university_id) REFERENCES public.universities(id)
);
CREATE TABLE public.room_video_reviews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  source_url text NOT NULL,
  display_title text,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT room_video_reviews_pkey PRIMARY KEY (id),
  CONSTRAINT room_video_reviews_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id)
);
CREATE TABLE public.rooms (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id uuid,
  title text NOT NULL,
  description text,
  price numeric NOT NULL,
  area numeric,
  address text NOT NULL,
  city text,
  district text,
  ward text,
  status text DEFAULT 'available'::text CHECK (status = ANY (ARRAY['available'::text, 'reserved'::text, 'rented'::text, 'hidden'::text])),
  created_at timestamp without time zone DEFAULT now(),
  banner text,
  maps text,
  is_hot boolean NOT NULL DEFAULT false,
  CONSTRAINT rooms_pkey PRIMARY KEY (id),
  CONSTRAINT rooms_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.surroundings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT surroundings_pkey PRIMARY KEY (id)
);
CREATE TABLE public.targets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT targets_pkey PRIMARY KEY (id)
);
CREATE TABLE public.universities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  short_name text NOT NULL,
  description text,
  address text,
  latitude numeric,
  longitude numeric,
  image_url text,
  website_url text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT universities_pkey PRIMARY KEY (id)
);

CREATE TABLE public.room_units (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  name text NOT NULL,
  status text DEFAULT 'available'::text CHECK (status = ANY (ARRAY['available'::text, 'rented'::text, 'maintenance'::text])),
  current_renter_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT room_units_pkey PRIMARY KEY (id),
  CONSTRAINT room_units_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.rooms(id),
  CONSTRAINT room_units_renter_id_fkey FOREIGN KEY (current_renter_id) REFERENCES public.profiles(id)
);

CREATE TABLE public.contracts (
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

CREATE TABLE public.services (
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

CREATE TABLE public.unit_services (
  room_unit_id uuid NOT NULL,
  service_id uuid NOT NULL,
  CONSTRAINT unit_services_pkey PRIMARY KEY (room_unit_id, service_id),
  CONSTRAINT unit_services_room_unit_id_fkey FOREIGN KEY (room_unit_id) REFERENCES public.room_units(id),
  CONSTRAINT unit_services_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id)
);

CREATE TABLE public.invoices (
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

CREATE TABLE public.invoice_items (
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

CREATE TABLE public.maintenance_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_unit_id uuid NOT NULL,
  renter_id uuid NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  image_urls ARRAY DEFAULT '{}'::text[],
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'resolved'::text, 'rejected'::text])),
  priority text DEFAULT 'normal'::text CHECK (priority = ANY (ARRAY['low'::text, 'normal'::text, 'high'::text, 'urgent'::text])),
  resolved_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT maintenance_requests_pkey PRIMARY KEY (id),
  CONSTRAINT maintenance_requests_room_unit_id_fkey FOREIGN KEY (room_unit_id) REFERENCES public.room_units(id),
  CONSTRAINT maintenance_requests_renter_id_fkey FOREIGN KEY (renter_id) REFERENCES public.profiles(id)
);

CREATE TABLE public.tenant_profiles (
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

CREATE TABLE public.ctv_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  referral_code text NOT NULL,
  commission_rate numeric NOT NULL DEFAULT 10,
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

CREATE TABLE public.ctv_referrals (
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

CREATE TABLE public.ctv_commissions (
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