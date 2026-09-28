-- Video review (TikTok) gắn theo từng phòng — chạy trong Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.room_video_reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    source_url TEXT NOT NULL,
    display_title TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_room_video_reviews_room_id ON public.room_video_reviews(room_id);
CREATE INDEX IF NOT EXISTS idx_room_video_reviews_sort ON public.room_video_reviews(room_id, sort_order);

ALTER TABLE public.room_video_reviews ENABLE ROW LEVEL SECURITY;

-- Đọc: video của phòng đang hiển thị công khai, hoặc chủ phòng / admin xem thêm
DROP POLICY IF EXISTS "Public read room video reviews" ON public.room_video_reviews;
CREATE POLICY "Public read room video reviews"
    ON public.room_video_reviews FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.rooms r
            WHERE r.id = room_video_reviews.room_id
            AND r.status IN ('available', 'reserved', 'rented')
        )
        OR EXISTS (
            SELECT 1 FROM public.rooms r
            WHERE r.id = room_video_reviews.room_id
            AND r.owner_id IS NOT NULL
            AND r.owner_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    );

DROP POLICY IF EXISTS "Room owners manage video reviews" ON public.room_video_reviews;
CREATE POLICY "Room owners manage video reviews"
    ON public.room_video_reviews FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.rooms r
            WHERE r.id = room_video_reviews.room_id
            AND r.owner_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.rooms r
            WHERE r.id = room_video_reviews.room_id
            AND r.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Admins manage all room video reviews" ON public.room_video_reviews;
CREATE POLICY "Admins manage all room video reviews"
    ON public.room_video_reviews FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
        )
    );

GRANT SELECT ON public.room_video_reviews TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.room_video_reviews TO authenticated;

COMMENT ON TABLE public.room_video_reviews IS 'TikTok (hoặc URL chứa video ID) review gắn với phòng';
COMMENT ON COLUMN public.room_video_reviews.source_url IS 'URL chia sẻ TikTok, ví dụ https://www.tiktok.com/@user/video/123...';
