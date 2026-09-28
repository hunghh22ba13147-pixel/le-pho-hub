# 🔧 Fix: Lỗi Không Xem Được Ảnh Pass Phòng

## 🐛 Vấn Đề

Khi upload ảnh lên pass-phong, ảnh được upload thành công nhưng không hiển thị được (broken image).

## 🔍 Nguyên Nhân

Storage bucket `rooms` chưa được cấu hình public hoặc RLS policies chặn quyền truy cập.

## ✅ Giải Pháp

### Bước 1: Chạy SQL Migration

Mở **Supabase Dashboard** → **SQL Editor** → Chạy file:

```bash
database-migrations/fix_storage_permissions.sql
```

Hoặc copy SQL này:

```sql
-- Set bucket to public
UPDATE storage.buckets 
SET public = true 
WHERE id = 'rooms';

-- Allow authenticated users to upload
CREATE POLICY IF NOT EXISTS "Allow authenticated users to upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'rooms' 
  AND auth.role() = 'authenticated'
);

-- Allow public to read
CREATE POLICY IF NOT EXISTS "Allow public to read room images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'rooms');
```

### Bước 2: Kiểm Tra Trong Supabase Dashboard

1. Vào **Storage** → **rooms** bucket
2. Kiểm tra **Public bucket** = `ON` (màu xanh)
3. Vào **Policies** tab
4. Đảm bảo có policies:
   - ✅ `Allow authenticated users to upload images`
   - ✅ `Allow public to read room images`

### Bước 3: Test Upload

1. Vào `/pass-phong/tao-moi`
2. Upload 1 ảnh test
3. Xem preview ảnh có hiển thị không

## 🔄 Nếu Vẫn Lỗi

### Option 1: Xóa và Tạo Lại Bucket

```sql
-- Xóa bucket cũ (cẩn thận - mất hết ảnh!)
DELETE FROM storage.objects WHERE bucket_id = 'rooms';
DELETE FROM storage.buckets WHERE id = 'rooms';

-- Tạo bucket mới
INSERT INTO storage.buckets (id, name, public)
VALUES ('rooms', 'rooms', true);
```

### Option 2: Check URL Format

Kiểm tra URL ảnh có format đúng không:
```
https://[PROJECT_ID].supabase.co/storage/v1/object/public/rooms/room-transfer-images/[filename]
```

### Option 3: Kiểm Tra CORS

Nếu ảnh vẫn không load, có thể là vấn đề CORS:

1. Vào **Storage Settings**
2. Thêm domain của bạn vào **Allowed origins**:
   - `http://localhost:3000`
   - `https://yourdomain.com`

## 📝 Code Hiện Tại (Đã Đúng)

File: `src/app/(account-pages)/pass-phong/tao-moi/page.tsx`

```typescript
const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
  const files = e.target.files;
  if (!files || files.length === 0) return;

  setUploadingImages(true);
  const uploadedUrls: string[] = [];

  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const fileExt = file.name.split('.').pop();
    const fileName = `${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`;
    const filePath = `room-transfer-images/${fileName}`; // ✅ Đúng

    const { data, error } = await supabase.storage
      .from('rooms') // ✅ Bucket name
      .upload(filePath, file);

    if (error) {
      console.error('Error uploading image:', error);
      continue;
    }

    const { data: publicUrlData } = supabase.storage
      .from('rooms')
      .getPublicUrl(filePath); // ✅ Get public URL

    uploadedUrls.push(publicUrlData.publicUrl); // ✅ Save URL
  }

  setForm({ ...form, room_images: [...form.room_images, ...uploadedUrls] });
  setUploadingImages(false);
};
```

## 🎯 Checklist

- [ ] Chạy SQL migration `fix_storage_permissions.sql`
- [ ] Kiểm tra bucket `rooms` là public
- [ ] Kiểm tra có 2 policies: upload (authenticated) và read (public)
- [ ] Test upload ảnh mới
- [ ] Xem ảnh có hiển thị trong preview
- [ ] Xem ảnh có hiển thị trong danh sách pass-phong

## 🔍 Debug Tips

### Kiểm Tra URL Ảnh:

1. Upload ảnh
2. Mở Developer Tools (F12)
3. Vào tab **Network**
4. Reload page
5. Tìm request ảnh bị fail
6. Xem response code:
   - `403 Forbidden` → RLS chặn, chạy lại SQL
   - `404 Not Found` → Bucket/path sai
   - `CORS error` → Cần config CORS

### Log URL Để Debug:

Thêm vào code sau khi upload:

```typescript
const { data: publicUrlData } = supabase.storage
  .from('rooms')
  .getPublicUrl(filePath);

console.log('✅ Uploaded image URL:', publicUrlData.publicUrl); // Debug
uploadedUrls.push(publicUrlData.publicUrl);
```

## 📊 Storage Structure

```
rooms/
├── room-transfer-images/
│   ├── 1704876543210-abc123.jpg
│   ├── 1704876544321-xyz789.png
│   └── ...
└── (other folders...)
```

## ⚠️ Lưu Ý

1. **Bucket phải public** để ảnh hiển thị được
2. **Policies phải đúng** để upload và đọc được
3. **URL phải đúng format** của Supabase Storage
4. Nếu đã upload ảnh trước khi fix, cần upload lại hoặc update policies

---

**Sau khi chạy SQL, reload trang và test lại upload ảnh!** 🎉

