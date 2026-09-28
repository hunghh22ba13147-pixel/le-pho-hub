import React, { FC } from "react";
import rightImgPng from "@/images/hero-apartment.jpg";
import Image, { StaticImageData } from "next/image";
import Badge from "@/shared/Badge";

export interface SectionOurFeaturesProps {
  className?: string;
  rightImg?: StaticImageData;
  type?: "type1" | "type2";
}

const SectionOurFeatures: FC<SectionOurFeaturesProps> = ({
  className = "lg:py-14",
  rightImg = rightImgPng,
  type = "type1",
}) => {
  return (
    <div
      className={`nc-SectionOurFeatures relative flex flex-col items-center ${
        type === "type1" ? "lg:flex-row" : "lg:flex-row-reverse"
      } ${className}`}
      data-nc-id="SectionOurFeatures"
    >
      <div className="flex-grow">
        <Image src={rightImg} alt="Le Pho Hub - Phong tro noi thanh Ha Noi" className="rounded-2xl object-cover" />
      </div>
      <div
        className={`max-w-2xl flex-shrink-0 mt-10 lg:mt-0 lg:w-2/5 ${
          type === "type1" ? "lg:pl-16" : "lg:pr-16"
        }`}
      >
        <ul className="space-y-10">
          <li className="space-y-4">
            <Badge name="Chat luong & Uy tin / Quality & Trust" />
            <span className="block text-xl font-semibold">
              Phong tro xac thuc 100% thuc te
            </span>
            <span className="block mt-5 text-neutral-500 dark:text-neutral-400">
              Moi tin dang tren Le Pho Hub duoc kiem tra thuc te, dam bao hinh
              anh that, gia minh bach, dang tin cay. Khong ao, khong lua dao —
              chi co nhung phong tro xung dang voi dong tien cua ban.{" "}
              <i>Every listing is verified — real photos, transparent pricing, no scams.</i>
            </span>
          </li>

          <li className="space-y-4">
            <Badge name="Ghep o thong minh / Smart Roommate Matching" color="green" />
            <span className="block text-xl font-semibold">
              Ghep o dung nguoi — tiet kiem chi phi, song phu hop
            </span>
            <span className="block mt-5 text-neutral-500 dark:text-neutral-400">
              Tinh nang Roommate Matching giup tim nguoi ban cung phong phu
              hop: lich ngu, so thich, ngan sach phu hop. Chia se chi phi,
              chia se cuoc song — thoai mai hon, tiet kiem hon.{" "}
              <i>AI-powered matching for the perfect roommate.</i>
            </span>
          </li>

          <li className="space-y-4">
            <Badge name="Noi thanh Ha Noi / Inner Hanoi" color="red" />
            <span className="block text-xl font-semibold">
              Tap trung noi thanh — cac Quan trung tam Ha Noi
            </span>
            <span className="block mt-5 text-neutral-500 dark:text-neutral-400">
              Le Pho Hub tap trung vao cac quan noi thanh: Dong Da, Ba Dinh,
              Hoan Kiem, Cau Giay, Thanh Xuan, Hai Ba Trung, Nam Tu Liem, Bac
              Tu Liem — gan trung tam, gan viec lam, gan moi thu ban can.{" "}
              <i>Central districts, near workplaces, near everything that matters.</i>
            </span>
          </li>
        </ul>
      </div>
    </div>
  );
};

export default SectionOurFeatures;