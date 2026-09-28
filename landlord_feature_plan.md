# Tài liệu Phân tích & Kế hoạch Phát triển Tính năng Landlord - trohoalac.com

Dựa trên việc phân tích hệ thống **quanly.tromoi.com**, tài liệu này xây dựng lộ trình chi tiết để áp dụng vai trò Chủ nhà (Landlord) cho dự án **trohoalac.com**, tối ưu cho khu vực Hòa Lạc.

---

## 1. Phân tích đối thủ: quanly.tromoi.com
Hệ thống này tập trung vào tính thực dụng, giúp chủ nhà giảm bớt các công việc chân tay và quản lý dữ liệu tập trung.

### Các module then chốt:
* **Quản lý Tài sản:** Cấu trúc theo cây (Tòa nhà -> Tầng -> Phòng).
* **Quản lý Khách thuê:** Lưu trữ hồ sơ, định danh và lịch sử thuê.
* **Quản lý Dịch vụ:** Tự động hóa tính toán chỉ số điện, nước, internet, vệ sinh.
* **Tài chính:** Theo dõi công nợ, xuất hóa đơn tự động và báo cáo doanh thu.

---

## 2. Kế hoạch áp dụng cho trohoalac.com (Role Landlord)

### Giai đoạn 1: Số hóa Quản lý & Hợp đồng (MVP)
Mục tiêu là giúp chủ nhà loại bỏ sổ sách giấy truyền thống.

* **Quản lý danh mục phòng:**
    * Trạng thái phòng: Trống, Đang ở, Đang sửa chữa, Đã đặt cọc.
    * Thông tin chi tiết: Diện tích, giá thuê, danh sách nội thất kèm ảnh chụp thực tế.
* **Hợp đồng điện tử:**
    * Tạo mẫu hợp đồng chuẩn.
    * Lưu trữ ảnh CCCD và thông tin sinh viên thuê phòng.
    * Thông báo nhắc khi hợp đồng sắp hết hạn (trước 30 ngày).

### Giai đoạn 2: Tự động hóa Vận hành & Tài chính
Tập trung vào tính năng "Sổ thu chi" thông minh.

* **Tính hóa đơn hàng tháng:**
    * Nhập số điện/nước cuối tháng -> Hệ thống tự tính dựa trên đơn giá cài đặt.
    * Cộng các phí dịch vụ cố định (rác, wifi).
    * Xuất hóa đơn dạng ảnh/link gửi trực tiếp qua Zalo/Facebook cho sinh viên.
* **Cổng thanh toán (Option):**
    * Tích hợp mã QR động (VietQR) chứa số tiền cần trả để sinh viên quét mã là xong, chủ nhà nhận thông báo real-time.

### Giai đoạn 3: Tiện ích đặc thù cho Hòa Lạc
Tối ưu hóa cho môi trường sinh viên FPT/VNU.

* **Hệ thống Phản hồi & Bảo trì:**
    * Sinh viên gửi yêu cầu sửa chữa kèm ảnh qua app.
    * Chủ nhà theo dõi trạng thái: "Chờ xử lý", "Đang sửa", "Hoàn thành".
* **Tính năng tìm người ở ghép:**
    * Chủ nhà có thể đăng tin hỗ trợ sinh viên tìm bạn cùng phòng để lấp đầy phòng nhanh hơn.
* **Báo cáo dòng tiền:** Biểu đồ doanh thu hàng tháng, tỉ lệ lấp đầy theo thời gian.

---

## 3. Kiến trúc kỹ thuật (Tech Stack Alignment)

Hệ thống sẽ được xây dựng trên nền tảng hiện tại:

| Thành phần | Công nghệ | Vai trò |
| :--- | :--- | :--- |
| **Frontend** | Next.js | Dashboard quản trị mượt mà, tối ưu Mobile-first cho chủ nhà. |
| **Backend** | Spring Boot | Xử lý logic tính toán hóa đơn phức tạp và quản lý nghiệp vụ. |
| **Database** | PostgreSQL | Lưu trữ dữ liệu quan hệ (Landlord - Room - Invoice). |
| **Real-time** | Supabase/WS | Thông báo ngay lập tức khi sinh viên gửi yêu cầu sửa chữa. |

---

## 4. Các bước triển khai tiếp theo (Next Steps)
1. **Database Schema:** Thiết kế các bảng dữ liệu cho `Properties`, `Rooms`, `Leases`, và `Invoices`.
2. **UI/UX Design:** Thiết kế màn hình "Nhập chỉ số điện nước" sao cho nhanh nhất (vì chủ nhà thường cầm điện thoại đi từng phòng).
3. **API Development:** Xây dựng các Endpoint CRUD cho quản lý phòng và API tính toán hóa đơn.
