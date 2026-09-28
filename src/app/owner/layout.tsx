"use client";

import React, { useEffect, useState } from "react";
import { useRouter, usePathname } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import OwnerSidebar from "@/components/owner/OwnerSidebar";
import OwnerHeader from "@/components/owner/OwnerHeader";
import OwnerBottomNav from "@/components/owner/OwnerBottomNav";

const pageTitles: Record<string, { title: string; subtitle: string }> = {
  "/owner": {
    title: "Tổng quan",
    subtitle: "Thống kê hoạt động kinh doanh khu trọ",
  },
  "/owner/properties": {
    title: "Quản lý Nhà trọ",
    subtitle: "Danh sách các tòa nhà/khu trọ của bạn",
  },
  "/owner/properties/new": {
    title: "Thêm nhà trọ mới",
    subtitle: "Điền thông tin chi tiết về nhà trọ của bạn",
  },
  "/owner/rooms": {
    title: "Quản lý Phòng",
    subtitle: "Quản lý danh sách các phòng trong khu trọ",
  },
  "/owner/tenants": {
    title: "Quản lý khách thuê",
    subtitle: "Quản lý thông tin lưu trú của khách",
  },
  "/owner/contracts": {
    title: "Quản lý hợp đồng",
    subtitle: "Lập và theo dõi hợp đồng thuê phòng",
  },
  "/owner/invoices": {
    title: "Hóa đơn",
    subtitle: "Quản lý hóa đơn và thanh toán hàng tháng",
  },
  "/owner/services": {
    title: "Dịch vụ",
    subtitle: "Cấu hình bảng giá điện, nước, internet, rác",
  },
  "/owner/maintenance": {
    title: "Bảo trì",
    subtitle: "Tiếp nhận và xử lý yêu cầu sửa chữa từ khách thuê",
  },
  "/owner/settings/account": {
    title: "Thông tin tài khoản",
    subtitle: "Quản lý thông tin đăng nhập và bảo mật",
  },
  "/owner/settings/profile": {
    title: "Thông tin cá nhân",
    subtitle: "Cập nhật thông tin cá nhân và ảnh đại diện",
  },
  "/owner/settings/contact": {
    title: "Thông tin liên hệ trọ",
    subtitle: "Thông tin liên hệ hiển thị cho khách thuê",
  },
  "/owner/settings/business": {
    title: "Thông tin doanh nghiệp",
    subtitle: "Thông tin kinh doanh và tài khoản thanh toán",
  },
  "/owner/system/activity": {
    title: "Lịch sử hoạt động",
    subtitle: "Xem lại các hoạt động gần đây trên hệ thống",
  },
  "/owner/system/notifications": {
    title: "Thông báo",
    subtitle: "Quản lý thông báo của bạn",
  },
};

export default function OwnerLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, loading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    // Cho phép owner truy cập. (Nên xử lý nếu user có role là admin vẫn có thể vào xem owner dashboard nếu cần, nhưng chuẩn nhất là owner)
    if (!loading && (!user || (user.role !== "owner" && user.role !== "admin"))) {
      router.push("/");
    }
  }, [user, loading, router]);

  const pageInfo = pageTitles[pathname] || (() => {
    // Handle dynamic routes
    if (pathname.match(/^\/owner\/properties\/[^/]+\/edit$/)) {
      return { title: "Chỉnh sửa nhà trọ", subtitle: "Cập nhật thông tin nhà trọ" };
    }
    if (pathname.match(/^\/owner\/properties\/[^/]+$/)) {
      return { title: "Chi tiết nhà trọ", subtitle: "Xem thông tin chi tiết nhà trọ" };
    }
    return { title: "", subtitle: "" };
  })();

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-500"></div>
      </div>
    );
  }

  if (!user || (user.role !== "owner" && user.role !== "admin")) {
    return null;
  }

  return (
    <div className="flex h-screen bg-neutral-50 dark:bg-neutral-900 overflow-hidden">
      {/* Sidebar */}
      <OwnerSidebar
        isMobileOpen={isMobileMenuOpen}
        onMobileClose={() => setIsMobileMenuOpen(false)}
      />

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <OwnerHeader
          title={pageInfo.title}
          subtitle={pageInfo.subtitle}
          onMobileMenuClick={() => setIsMobileMenuOpen(true)}
        />

        {/* Page Content */}
        <main className="flex-1 overflow-y-auto bg-neutral-50 dark:bg-neutral-900">
          <div className="max-w-7xl mx-auto p-4 sm:p-6 pb-20 lg:pb-6">{children}</div>
        </main>
      </div>

      {/* Mobile Bottom Navigation */}
      <OwnerBottomNav onMenuClick={() => setIsMobileMenuOpen(true)} />
    </div>
  );
}
