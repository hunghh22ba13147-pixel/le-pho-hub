-- Complete RLS Policies cho tất cả các bảng còn lại
-- Run this in your Supabase SQL Editor
-- 
-- QUAN TRỌNG: Migration này đảm bảo tất cả bảng đều có RLS policies phù hợp
-- Chạy sau khi đã chạy các migrations khác

-- ============================================
-- 1. ROOM_IMAGES - Bảo vệ ảnh phòng
-- ============================================
ALTER TABLE IF EXISTS public.room_images ENABLE ROW LEVEL SECURITY;

-- Xóa policies cũ nếu có
DROP POLICY IF EXISTS "Anyone can view room images" ON public.room_images;
DROP POLICY IF EXISTS "Room owners can manage their room images" ON public.room_images;
DROP POLICY IF EXISTS "Admins can manage all room images" ON public.room_images;

-- Policy: Mọi người có thể xem ảnh của phòng available
CREATE POLICY "Anyone can view room images"
ON public.room_images
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_images.room_id
        AND (rooms.status = 'available' OR rooms.owner_id = auth.uid())
    )
);

-- Policy: Room owners có thể quản lý ảnh của phòng mình
CREATE POLICY "Room owners can manage their room images"
ON public.room_images
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_images.room_id
        AND rooms.owner_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_images.room_id
        AND rooms.owner_id = auth.uid()
    )
);

-- Policy: Admins có thể quản lý tất cả ảnh
CREATE POLICY "Admins can manage all room images"
ON public.room_images
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================
-- 2. ROOM_AMENITIES - Junction table
-- ============================================
ALTER TABLE IF EXISTS public.room_amenities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view room amenities" ON public.room_amenities;
DROP POLICY IF EXISTS "Room owners can manage their room amenities" ON public.room_amenities;
DROP POLICY IF EXISTS "Admins can manage all room amenities" ON public.room_amenities;

-- Policy: Mọi người có thể xem amenities của phòng available
CREATE POLICY "Anyone can view room amenities"
ON public.room_amenities
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_amenities.room_id
        AND (rooms.status = 'available' OR rooms.owner_id = auth.uid())
    )
);

-- Policy: Room owners có thể quản lý amenities của phòng mình
CREATE POLICY "Room owners can manage their room amenities"
ON public.room_amenities
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_amenities.room_id
        AND rooms.owner_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_amenities.room_id
        AND rooms.owner_id = auth.uid()
    )
);

-- Policy: Admins có thể quản lý tất cả
CREATE POLICY "Admins can manage all room amenities"
ON public.room_amenities
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================
-- 3. ROOM_SURROUNDINGS - Junction table
-- ============================================
ALTER TABLE IF EXISTS public.room_surroundings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view room surroundings" ON public.room_surroundings;
DROP POLICY IF EXISTS "Room owners can manage their room surroundings" ON public.room_surroundings;
DROP POLICY IF EXISTS "Admins can manage all room surroundings" ON public.room_surroundings;

-- Policy: Mọi người có thể xem surroundings của phòng available
CREATE POLICY "Anyone can view room surroundings"
ON public.room_surroundings
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_surroundings.room_id
        AND (rooms.status = 'available' OR rooms.owner_id = auth.uid())
    )
);

-- Policy: Room owners có thể quản lý surroundings của phòng mình
CREATE POLICY "Room owners can manage their room surroundings"
ON public.room_surroundings
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_surroundings.room_id
        AND rooms.owner_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_surroundings.room_id
        AND rooms.owner_id = auth.uid()
    )
);

-- Policy: Admins có thể quản lý tất cả
CREATE POLICY "Admins can manage all room surroundings"
ON public.room_surroundings
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================
-- 4. ROOM_TARGETS - Junction table
-- ============================================
ALTER TABLE IF EXISTS public.room_targets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view room targets" ON public.room_targets;
DROP POLICY IF EXISTS "Room owners can manage their room targets" ON public.room_targets;
DROP POLICY IF EXISTS "Admins can manage all room targets" ON public.room_targets;

-- Policy: Mọi người có thể xem targets của phòng available
CREATE POLICY "Anyone can view room targets"
ON public.room_targets
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_targets.room_id
        AND (rooms.status = 'available' OR rooms.owner_id = auth.uid())
    )
);

-- Policy: Room owners có thể quản lý targets của phòng mình
CREATE POLICY "Room owners can manage their room targets"
ON public.room_targets
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_targets.room_id
        AND rooms.owner_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = room_targets.room_id
        AND rooms.owner_id = auth.uid()
    )
);

-- Policy: Admins có thể quản lý tất cả
CREATE POLICY "Admins can manage all room targets"
ON public.room_targets
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================
-- 5. CONTACTS - Liên hệ với chủ phòng
-- ============================================
ALTER TABLE IF EXISTS public.contacts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own contacts" ON public.contacts;
DROP POLICY IF EXISTS "Room owners can view contacts for their rooms" ON public.contacts;
DROP POLICY IF EXISTS "Users can create contacts" ON public.contacts;
DROP POLICY IF EXISTS "Admins can manage all contacts" ON public.contacts;

-- Policy: Users có thể xem contacts của chính họ
CREATE POLICY "Users can view their own contacts"
ON public.contacts
FOR SELECT
USING (auth.uid() = renter_id);

-- Policy: Room owners có thể xem contacts cho phòng của họ
CREATE POLICY "Room owners can view contacts for their rooms"
ON public.contacts
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.rooms
        WHERE rooms.id = contacts.room_id
        AND rooms.owner_id = auth.uid()
    )
);

-- Policy: Users có thể tạo contacts
CREATE POLICY "Users can create contacts"
ON public.contacts
FOR INSERT
WITH CHECK (auth.uid() = renter_id);

-- Policy: Admins có thể quản lý tất cả
CREATE POLICY "Admins can manage all contacts"
ON public.contacts
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================
-- 6. REVIEWS - Reviews (nếu khác với feedbacks)
-- ============================================
-- Chú ý: Nếu reviews và feedbacks là cùng một bảng, bỏ qua phần này
ALTER TABLE IF EXISTS public.reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can create their own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can update their own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Users can delete their own reviews" ON public.reviews;
DROP POLICY IF EXISTS "Admins can manage all reviews" ON public.reviews;

-- Policy: Mọi người có thể xem reviews
CREATE POLICY "Anyone can view reviews"
ON public.reviews
FOR SELECT
USING (true);

-- Policy: Users có thể tạo reviews của chính họ
CREATE POLICY "Users can create their own reviews"
ON public.reviews
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users có thể update reviews của chính họ
CREATE POLICY "Users can update their own reviews"
ON public.reviews
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users có thể delete reviews của chính họ
CREATE POLICY "Users can delete their own reviews"
ON public.reviews
FOR DELETE
USING (auth.uid() = user_id);

-- Policy: Admins có thể quản lý tất cả
CREATE POLICY "Admins can manage all reviews"
ON public.reviews
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================
-- 7. AMENITIES - Lookup table (public read)
-- ============================================
ALTER TABLE IF EXISTS public.amenities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view amenities" ON public.amenities;
DROP POLICY IF EXISTS "Admins can manage amenities" ON public.amenities;

-- Policy: Mọi người có thể xem amenities
CREATE POLICY "Anyone can view amenities"
ON public.amenities
FOR SELECT
USING (true);

-- Policy: Chỉ admin mới có thể quản lý amenities
CREATE POLICY "Admins can manage amenities"
ON public.amenities
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================
-- 8. SURROUNDINGS - Lookup table (public read)
-- ============================================
ALTER TABLE IF EXISTS public.surroundings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view surroundings" ON public.surroundings;
DROP POLICY IF EXISTS "Admins can manage surroundings" ON public.surroundings;

-- Policy: Mọi người có thể xem surroundings
CREATE POLICY "Anyone can view surroundings"
ON public.surroundings
FOR SELECT
USING (true);

-- Policy: Chỉ admin mới có thể quản lý surroundings
CREATE POLICY "Admins can manage surroundings"
ON public.surroundings
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================
-- 9. TARGETS - Lookup table (public read)
-- ============================================
ALTER TABLE IF EXISTS public.targets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view targets" ON public.targets;
DROP POLICY IF EXISTS "Admins can manage targets" ON public.targets;

-- Policy: Mọi người có thể xem targets
CREATE POLICY "Anyone can view targets"
ON public.targets
FOR SELECT
USING (true);

-- Policy: Chỉ admin mới có thể quản lý targets
CREATE POLICY "Admins can manage targets"
ON public.targets
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================
-- 10. Bổ sung Admin policies cho các bảng quan trọng
-- ============================================

-- Đảm bảo admins có thể quản lý tất cả trong nearby_places
DROP POLICY IF EXISTS "Admins can manage all nearby places" ON public.nearby_places;
CREATE POLICY "Admins can manage all nearby places"
ON public.nearby_places
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================
-- Verify tất cả policies đã được tạo
-- ============================================
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd, 
    qual, 
    with_check
FROM pg_policies 
WHERE schemaname = 'public'
    AND tablename IN (
        'room_images',
        'room_amenities',
        'room_surroundings',
        'room_targets',
        'contacts',
        'reviews',
        'amenities',
        'surroundings',
        'targets',
        'nearby_places'
    )
ORDER BY tablename, policyname;

-- ============================================
-- Comments
-- ============================================
COMMENT ON POLICY "Anyone can view room images" ON public.room_images IS 'Allow public to view images of available rooms';
COMMENT ON POLICY "Room owners can manage their room images" ON public.room_images IS 'Allow room owners to manage images of their rooms';
COMMENT ON POLICY "Admins can manage all room images" ON public.room_images IS 'Allow admins to manage all room images';

COMMENT ON POLICY "Admins can manage amenities" ON public.amenities IS 'Only admins can create/update/delete amenities';
COMMENT ON POLICY "Admins can manage surroundings" ON public.surroundings IS 'Only admins can create/update/delete surroundings';
COMMENT ON POLICY "Admins can manage targets" ON public.targets IS 'Only admins can create/update/delete targets';

