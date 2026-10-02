import rightImg from "@/images/hero-apartment.jpg";
import React, { FC } from "react";
import SectionFounder from "./SectionFounder";
import SectionStatistic from "./SectionStatistic";
import SectionHero from "./SectionHero";
import BgGlassmorphism from "@/components/BgGlassmorphism";
import BackgroundSection from "@/components/BackgroundSection";
import SectionClientSay from "@/components/SectionClientSay";

export interface PageAboutProps {}

const PageAbout: FC<PageAboutProps> = ({}) => {
  return (
    <div className={`nc-PageAbout overflow-hidden relative`}>
      <BgGlassmorphism />

      <div className="container py-16 lg:py-28 space-y-16 lg:space-y-28">
        <SectionHero
          rightImg={rightImg}
          heading={
            <>
              Về <span className="text-primary-600">Le Phố Hub</span>
            </>
          }
          btnText="Tìm phòng trọ ngay"
          subHeading="Nền tảng tìm kiếm phòng trọ, chung cư mini và ghép ở thông minh tại nội thành Hà Nội — minh bạch, tiện lợi và đáng tin cậy. Smart housing marketplace for inner Hanoi."
        />

        <div className="grid md:grid-cols-3 gap-6">
          <div className="p-6 rounded-2xl bg-neutral-50 dark:bg-neutral-800 border border-neutral-100 dark:border-neutral-700">
            <div className="text-2xl mb-3">🏙️</div>
            <div className="text-sm font-semibold text-neutral-900 dark:text-neutral-100 mb-2">
              Sứ mệnh / Mission
            </div>
            <div className="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
              Giúp bạn <strong>tìm phòng trọ phù hợp nhanh hơn</strong> tại nội thành Hà Nội, giảm thời gian
              đi xem lan man bằng cách tổng hợp thông tin trong yếu: giá, vị trí, diện tích,
              tiện nghi và khoảng cách đến nơi làm việc.
            </div>
          </div>
          <div className="p-6 rounded-2xl bg-neutral-50 dark:bg-neutral-800 border border-neutral-100 dark:border-neutral-700">
            <div className="text-2xl mb-3">🤝</div>
            <div className="text-sm font-semibold text-neutral-900 dark:text-neutral-100 mb-2">
              Cam kết / Commitment
            </div>
            <div className="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
              Ưu tiên <strong>minh bạch</strong>: phòng còn trống, ảnh rõ, giá dễ hiểu.
              Tất cả tin đăng đều được kiểm tra thực tế — không ảo, không lừa đảo,
              chỉ có những phòng trọ xứng đáng với đồng tiền của bạn.
            </div>
          </div>
          <div className="p-6 rounded-2xl bg-neutral-50 dark:bg-neutral-800 border border-neutral-100 dark:border-neutral-700">
            <div className="text-2xl mb-3">👥</div>
            <div className="text-sm font-semibold text-neutral-900 dark:text-neutral-100 mb-2">
              Dành cho ai? / Who Is It For?
            </div>
            <div className="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
              Sinh viên, người đi làm và freelancer cần phòng trọ tại các quận nội thành Hà Nội;
              người cần ghép ở để tiết kiệm chi phí; và chủ trọ muốn đăng tin nhanh, quản lý phòng rõ ràng.
            </div>
          </div>
        </div>

        {/* Khu vực hoạt động */}
        <div className="rounded-2xl bg-primary-50 dark:bg-primary-950/20 border border-primary-100 dark:border-primary-900/40 p-6 md:p-10">
          <div className="text-xl font-bold text-neutral-900 dark:text-neutral-100 mb-4">
            📍 Khu vực hoạt động / Coverage Area
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            {["Đống Đa", "Ba Đình", "Hoàn Kiếm", "Hai Bà Trưng", "Cầu Giấy", "Thanh Xuân", "Nam Từ Liêm", "Bắc Từ Liêm"].map((q) => (
              <div key={q} className="bg-white dark:bg-neutral-800 rounded-xl px-3 py-2 text-center text-sm font-medium text-neutral-700 dark:text-neutral-300 shadow-sm">
                {q}
              </div>
            ))}
          </div>
          <p className="mt-4 text-sm text-neutral-500 dark:text-neutral-400">
            Và các quận lân cận: Hoàng Mai, Long Biên, Tây Hồ, Thanh Trì.
          </p>
        </div>

        {/* Liên hệ */}
        <div className="rounded-2xl border border-neutral-200 dark:border-neutral-700 p-6 md:p-10">
          <div className="text-xl font-semibold text-neutral-900 dark:text-neutral-100 mb-2">
            Liên hệ & Hợp tác / Contact & Partnership
          </div>
          <div className="text-sm text-neutral-600 dark:text-neutral-300 mb-4">
            Nếu bạn là chủ trọ muốn đăng tin, hợp tác hoặc cần hỗ trợ, hãy liên hệ với chúng tôi:
          </div>
          <div className="flex flex-wrap gap-4">
            <a href="/contact" className="inline-flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-xl text-sm font-medium hover:bg-primary-600 transition-colors">
              Trang liên hệ
            </a>
            <a href="/pricing" className="inline-flex items-center gap-2 px-4 py-2 border border-primary-300 text-primary-600 dark:text-primary-400 rounded-xl text-sm font-medium hover:bg-primary-50 dark:hover:bg-primary-950/30 transition-colors">
              Xem gói dịch vụ
            </a>
          </div>
        </div>

        <SectionFounder />
        <div className="relative py-16">
          <BackgroundSection />
          <SectionClientSay />
        </div>
        <SectionStatistic />
      </div>
    </div>
  );
};

export default PageAbout;
