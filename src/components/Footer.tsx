"use client";

import Logo from "@/shared/Logo";
import SocialsList1 from "@/shared/SocialsList1";
import { CustomLink } from "@/data/types";
import React from "react";

export interface WidgetFooterMenu {
  id: string;
  title: string;
  menus: CustomLink[];
}

const widgetMenus: WidgetFooterMenu[] = [
  {
    id: "5",
    title: "He thong / Platform",
    menus: [
      { href: "/", label: "Trang chu / Home" },
      { href: "/phong-tro-theo-quan", label: "Tim phong theo quan" },
      { href: "/roommate", label: "Ghep o / Roommate" },
      { href: "/wishlist", label: "Yeu thich / Wishlist" },
      { href: "/blog", label: "Blog & Tin tuc" },
    ],
  },
  {
    id: "1",
    title: "Thong tin / About",
    menus: [
      { href: "/about", label: "Ve Le Pho Hub" },
      { href: "/pricing", label: "Goi dich vu / Pricing" },
      { href: "/contact", label: "Lien he / Contact" },
      { href: "/term", label: "Dieu khoan su dung" },
      { href: "/privacy", label: "Chinh sach bao mat" },
    ],
  },
  {
    id: "2",
    title: "Ket noi / Social",
    menus: [
      { href: "#", label: "Facebook" },
      { href: "#", label: "Instagram" },
      { href: "#", label: "TikTok" },
      { href: "https://zalo.me/0392429998", label: "Zalo: 0392 429 998" },
    ],
  },
  {
    id: "4",
    title: "Khu vuc / Districts",
    menus: [
      { href: "/phong-tro-theo-quan/dong-da", label: "Dong Da" },
      { href: "/phong-tro-theo-quan/cau-giay", label: "Cau Giay" },
      { href: "/phong-tro-theo-quan/thanh-xuan", label: "Thanh Xuan" },
      { href: "/phong-tro-theo-quan/hai-ba-trung", label: "Hai Ba Trung" },
    ],
  },
];

const Footer: React.FC = () => {
  const renderWidgetMenuItem = (menu: WidgetFooterMenu, index: number) => {
    return (
      <div key={index} className="text-sm">
        <h2 className="font-semibold text-neutral-700 dark:text-neutral-200">
          {menu.title}
        </h2>
        <ul className="mt-5 space-y-4">
          {menu.menus.map((item, index) => (
            <li key={index}>
              <a
                key={index}
                className="text-neutral-6000 dark:text-neutral-300 hover:text-black dark:hover:text-white"
                href={item.href}
              >
                {item.label}
              </a>
            </li>
          ))}
        </ul>
      </div>
    );
  };

  return (
    <>
      <div className="nc-Footer relative py-24 lg:py-28 border-t border-neutral-200 dark:border-neutral-700">
        <div className="container grid grid-cols-2 gap-y-10 gap-x-5 sm:gap-x-8 md:grid-cols-4 lg:grid-cols-5 lg:gap-x-10 ">
          <div className="grid grid-cols-4 gap-5 col-span-2 md:col-span-4 lg:md:col-span-1 lg:flex lg:flex-col">
            <div className="col-span-2 md:col-span-1">
              <Logo />
            </div>
            <div className="col-span-2 flex items-center md:col-span-3">
              <SocialsList1 className="flex items-center space-x-3 lg:space-x-0 lg:flex-col lg:space-y-2.5 lg:items-start" />
            </div>
          </div>
          {widgetMenus.map(renderWidgetMenuItem)}
        </div>
        <div className="container mt-8 pt-6 border-t border-neutral-100 dark:border-neutral-800">
          <p className="text-sm text-neutral-500 dark:text-neutral-400 text-center">
            &copy; 2025 Le Pho Hub &mdash; Tim tro uy tin Ha Noi tai{" "}
            <a href="https://lephohub.vn" className="text-primary-600 hover:underline font-medium">
              lephohub.vn
            </a>
          </p>
        </div>
      </div>
    </>
  );
};

export default Footer;
