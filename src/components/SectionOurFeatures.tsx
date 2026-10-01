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
        <Image src={rightImg} alt="Le Phố Hub - Phòng trọ nội thành Hà Nội" className="rounded-2xl object-cover" />
      </div>
      <div
        className={`max-w-2xl flex-shrink-0 mt-10 lg:mt-0 lg:w-2/5 ${
          type === "type1" ? "lg:pl-16" : "lg:pr-16"
        }`}
      >
        <ul className="space-y-10">
          <li className="space-y-4">
            <Badge name="Chất lượng & Uy tín / Quality & Trust" />
            <span className="block text-xl font-semibold">
              Phòng trọ xác thực 100% thực tế
            </span>
            <span className="block mt-5 text-neutral-500 dark:text-neutral-400">
              Mọi tin đăng trên Le Phố Hub được kiểm tra thực tế, đảm bảo hình
              ảnh thật, giá minh bạch, đáng tin cậy. Không ảo, không lừa đảo —
              chỉ có những phòng trọ xứng đáng với đồng tiền của bạn.{" "}
              <i>Every listing is verified — real photos, transparent pricing, no scams.</i>
            </span>
          </li>

          <li className="space-y-4">
            <Badge name="Ghép ở thông minh / Smart Roommate Matching" color="green" />
            <span className="block text-xl font-semibold">
              Ghép ở đúng người — tiết kiệm chi phí, sống phù hợp
            </span>
            <span className="block mt-5 text-neutral-500 dark:text-neutral-400">
              Tính năng Roommate Matching giúp tìm người bạn cùng phòng phù
              hợp: lịch ngủ, sở thích, ngân sách phù hợp. Chia sẻ chi phí,
              chia sẻ cuộc sống — thoải mái hơn, tiết kiệm hơn.{" "}
              <i>AI-powered matching for the perfect roommate.</i>
            </span>
          </li>

          <li className="space-y-4">
            <Badge name="Nội thành Hà Nội / Inner Hanoi" color="red" />
            <span className="block text-xl font-semibold">
              Tập trung nội thành — các Quận trung tâm Hà Nội
            </span>
            <span className="block mt-5 text-neutral-500 dark:text-neutral-400">
              Le Phố Hub tập trung vào các quận nội thành: Đống Đa, Ba Đình,
              Hoàn Kiếm, Cầu Giấy, Thanh Xuân, Hai Bà Trưng, Nam Từ Liêm, Bắc
              Từ Liêm — gần trung tâm, gần việc làm, gần mọi thứ bạn cần.{" "}
              <i>Central districts, near workplaces, near everything that matters.</i>
            </span>
          </li>
        </ul>
      </div>
    </div>
  );
};

export default SectionOurFeatures;