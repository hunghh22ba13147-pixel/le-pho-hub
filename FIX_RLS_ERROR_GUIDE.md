# Hướng dẫn Fix lỗi RLS "new row violates row-level security policy"

## Vấn đề

Khi chủ trọ (owner) tạo nhà trọ mới, gặp lỗi:
```
Upload banner thất bại: new row violates row-level security policy
```

## Nguyên nhân

Supabase Row Level Security (RLS) đang chặn chủ trọ insert dữ liệu vào các bảng:
- `rooms` - Bảng nhà trọ chính
- `room_amenities` - Tiện nghi
- `room_images` - Ảnh phòng
- `nearby_places` - Địa điểm xung quanh
- `room_universities` - Trường học liên kết
- `room_video_reviews` - Video đánh giá
- `room_units` - Phòng thực tế
- Storage bucket `room-images` - Upload ảnh

## Giải pháp

### Bước 1: Chạy SQL Script

1. Mở **Supabase Dashboard**
2. Vào **SQL Editor**
3. Copy toàn bộ nội dung file `fix_rls_policies.sql`
4. Paste vào SQL Editor
5. Click **Run** để thực thi

Script này sẽ:
- ✅ Tạo policies cho phép owners INSERT/UPDATE/DELETE dữ liệu của họ
- ✅ Cho phép public SELECT dữ liệu công khai
- ✅ Bảo mật: Owners chỉ có thể thao tác với rooms của chính họ

### Bước 2: Cấu hình Storage Bucket Policies

#### 2.1. Vào Storage Settings
1. Mở **Supabase Dashboard**
2. Vào **Storage** → **Buckets**
3. Click vào bucket **room-images**
4. Click tab **Policies**

#### 2.2. Tạo Policy cho INSERT (Upload)
Click **New Policy** → **For full customization**

**Policy Name:** `Authenticated users can upload images`

**Policy Definition:**
```sql
CREATE POLICY "Authenticated users can upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'room-images');
```

#### 2.3. Tạo Policy cho SELECT (View)
Click **New Policy** → **For full customization**

**Policy Name:** `Public can view images`

**Policy Definition:**
```sql
CREATE POLICY "Public can view images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'room-images');
```

#### 2.4. Tạo Policy cho DELETE (Optional)
Click **New Policy** → **For full customization**

**Policy Name:** `Users can delete their own images`

**Policy Definition:**
```sql
CREATE POLICY "Users can delete their own images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'room-images' AND auth.uid()::text = owner);
```

### Bước 3: Kiểm tra Role của User

Đảm bảo user đang đăng nhập có `role = 'owner'` trong bảng `profiles`:

```sql
-- Kiểm tra role
SELECT id, name, email, role FROM profiles WHERE id = 'USER_ID_HERE';

-- Nếu role không đúng, update:
UPDATE profiles SET role = 'owner' WHERE id = 'USER_ID_HERE';
```

### Bước 4: Test lại

1. Đăng xuất và đăng nhập lại
2. Vào `/owner/properties/new`
3. Thử tạo nhà trọ mới với đầy đủ thông tin
4. Upload banner và ảnh
5. Submit form

## Kiểm tra Policies đã tạo

Chạy query này để xem tất cả policies:

```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename IN (
  'rooms', 
  'room_amenities', 
  'room_images', 
  'nearby_places', 
  'room_universities', 
  'room_video_reviews', 
  'room_units'
)
ORDER BY tablename, policyname;
```

## Policies đã tạo

### ROOMS Table
- ✅ `owners_insert_own_rooms` - Owners có thể INSERT rooms của họ
- ✅ `owners_update_own_rooms` - Owners có thể UPDATE rooms của họ
- ✅ `owners_delete_own_rooms` - Owners có thể DELETE rooms của họ
- ✅ `owners_select_own_rooms` - Owners có thể SELECT rooms của họ
- ✅ `public_select_available_rooms` - Public có thể xem rooms available

### ROOM_AMENITIES Table
- ✅ `owners_insert_room_amenities` - Owners có thể thêm amenities
- ✅ `owners_delete_room_amenities` - Owners có thể xóa amenities
- ✅ `public_select_room_amenities` - Public có thể xem amenities

### ROOM_IMAGES Table
- ✅ `owners_insert_room_images` - Owners có thể thêm images
- ✅ `owners_delete_room_images` - Owners có thể xóa images
- ✅ `public_select_room_images` - Public có thể xem images

### NEARBY_PLACES Table
- ✅ `owners_insert_nearby_places` - Owners có thể thêm nearby places
- ✅ `owners_update_nearby_places` - Owners có thể update nearby places
- ✅ `owners_delete_nearby_places` - Owners có thể xóa nearby places
- ✅ `public_select_nearby_places` - Public có thể xem nearby places

### ROOM_UNIVERSITIES Table
- ✅ `owners_insert_room_universities` - Owners có thể thêm university links
- ✅ `owners_delete_room_universities` - Owners có thể xóa university links
- ✅ `public_select_room_universities` - Public có thể xem university links

### ROOM_VIDEO_REVIEWS Table
- ✅ `owners_insert_room_video_reviews` - Owners có thể thêm videos
- ✅ `owners_update_room_video_reviews` - Owners có thể update videos
- ✅ `owners_delete_room_video_reviews` - Owners có thể xóa videos
- ✅ `public_select_room_video_reviews` - Public có thể xem videos

### ROOM_UNITS Table
- ✅ `owners_insert_room_units` - Owners có thể thêm room units
- ✅ `owners_update_room_units` - Owners có thể update room units
- ✅ `owners_delete_room_units` - Owners có thể xóa room units
- ✅ `owners_select_room_units` - Owners có thể xem room units của họ

### Storage Bucket (room-images)
- ✅ Authenticated users có thể upload
- ✅ Public có thể view
- ✅ Users có thể delete images của họ

## Bảo mật

Các policies này đảm bảo:
1. ✅ Owners chỉ có thể thao tác với rooms/data của chính họ
2. ✅ Public chỉ có thể xem (SELECT) dữ liệu công khai
3. ✅ Không ai có thể sửa/xóa dữ liệu của người khác
4. ✅ Admin có thể xem tất cả dữ liệu

## Troubleshooting

### Vẫn gặp lỗi sau khi chạy SQL?

1. **Kiểm tra user đã đăng nhập chưa:**
   ```javascript
   const { data: { user } } = await supabase.auth.getUser();
   console.log('Current user:', user);
   ```

2. **Kiểm tra role của user:**
   ```sql
   SELECT * FROM profiles WHERE id = auth.uid();
   ```

3. **Xóa cache browser và đăng nhập lại**

4. **Kiểm tra policies đã được tạo:**
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'rooms';
   ```

5. **Kiểm tra RLS đã enable:**
   ```sql
   SELECT tablename, rowsecurity 
   FROM pg_tables 
   WHERE schemaname = 'public' 
   AND tablename IN ('rooms', 'room_amenities', 'room_images');
   ```

### Lỗi "permission denied for table profiles"

Cần tạo policy cho bảng `profiles`:

```sql
-- Allow users to read their own profile
CREATE POLICY "Users can read own profile" ON profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
```

## Liên hệ

Nếu vẫn gặp vấn đề, cung cấp:
1. Error message đầy đủ từ console
2. User ID đang test
3. Role của user trong bảng profiles
4. Screenshot của policies trong Supabase Dashboard
