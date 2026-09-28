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
              Ve <span className="text-primary-600">Le Pho Hub</span>
            </>
          }
          btnText="Tim phong tro ngay"
          subHeading="Nen tang tim kiem phong tro, chung cu mini va ghep o thong minh tai noi thanh Ha Noi — minh bach, tien loi va dang tin cay. Smart housing marketplace for inner Hanoi."
        />

        <div className="grid md:grid-cols-3 gap-6">
          <div className="p-6 rounded-2xl bg-neutral-50 dark:bg-neutral-800 border border-neutral-100 dark:border-neutral-700">
            <div className="text-2xl mb-3">🏙️</div>
            <div className="text-sm font-semibold text-neutral-900 dark:text-neutral-100 mb-2">
              Su menh / Mission
            </div>
            <div className="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
              Giup ban <strong>tim phong tro phu hop nhanh hon</strong> tai noi thanh Ha Noi, giam thoi gian
              di xem lan man bang cach tong hop thong tin trong yeu: gia, vi tri, dien tich,
              tien nghi va khoang cach den noi lam viec.
            </div>
          </div>
          <div className="p-6 rounded-2xl bg-neutral-50 dark:bg-neutral-800 border border-neutral-100 dark:border-neutral-700">
            <div className="text-2xl mb-3">🤝</div>
            <div className="text-sm font-semibold text-neutral-900 dark:text-neutral-100 mb-2">
              Cam ket / Commitment
            </div>
            <div className="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
              Uu tien <strong>minh bach</strong>: phong con trong, anh ro, gia de hieu.
              Tat ca tin dang deu duoc kiem tra thuc te — khong ao, khong lua dao,
              chi co nhung phong tro xung dang voi dong tien cua ban.
            </div>
          </div>
          <div className="p-6 rounded-2xl bg-neutral-50 dark:bg-neutral-800 border border-neutral-100 dark:border-neutral-700">
            <div className="text-2xl mb-3">👥</div>
            <div className="text-sm font-semibold text-neutral-900 dark:text-neutral-100 mb-2">
              Danh cho ai? / Who Is It For?
            </div>
            <div className="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
              Sinh vien, nguoi di lam va freelancer can phong tro tai cac quan noi thanh Ha Noi;
              nguoi can ghep o de tiet kiem chi phi; va chu tro muon dang tin nhanh, quan ly phong ro rang.
            </div>
          </div>
        </div>

        {/* Khu vuc hoat dong */}
        <div className="rounded-2xl bg-primary-50 dark:bg-primary-950/20 border border-primary-100 dark:border-primary-900/40 p-6 md:p-10">
          <div className="text-xl font-bold text-neutral-900 dark:text-neutral-100 mb-4">
            📍 Khu vuc hoat dong / Coverage Area
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            {["Dong Da", "Ba Dinh", "Hoan Kiem", "Hai Ba Trung", "Cau Giay", "Thanh Xuan", "Nam Tu Liem", "Bac Tu Liem"].map((q) => (
              <div key={q} className="bg-white dark:bg-neutral-800 rounded-xl px-3 py-2 text-center text-sm font-medium text-neutral-700 dark:text-neutral-300 shadow-sm">
                {q}
              </div>
            ))}
          </div>
          <p className="mt-4 text-sm text-neutral-500 dark:text-neutral-400">
            Va cac quan lan can: Hoang Mai, Long Bien, Tay Ho, Thanh Tri.
          </p>
        </div>

        {/* Lien he */}
        <div className="rounded-2xl border border-neutral-200 dark:border-neutral-700 p-6 md:p-10">
          <div className="text-xl font-semibold text-neutral-900 dark:text-neutral-100 mb-2">
            Lien he & Hop tac / Contact & Partnership
          </div>
          <div className="text-sm text-neutral-600 dark:text-neutral-300 mb-4">
            Neu ban la chu tro muon dang tin, hop tac hoac can ho tro, hay lien he voi chung toi:
          </div>
          <div className="flex flex-wrap gap-4">
            <a href="/contact" className="inline-flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-xl text-sm font-medium hover:bg-primary-600 transition-colors">
              Trang lien he
            </a>
            <a href="/pricing" className="inline-flex items-center gap-2 px-4 py-2 border border-primary-300 text-primary-600 dark:text-primary-400 rounded-xl text-sm font-medium hover:bg-primary-50 dark:hover:bg-primary-950/30 transition-colors">
              Xem goi dich vu
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
