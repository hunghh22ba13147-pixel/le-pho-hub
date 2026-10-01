"use client";

import React, { FC } from "react";
import Link from "next/link";

export interface SectionStatsProps {
  className?: string;
}

const STATS_DATA = [
  { id: 1, value: "200+", label: "Phòng trọ", subLabel: "đang có sẵn tại Hà Nội" },
  { id: 2, value: "500+", label: "Người ghép ở", subLabel: "đã tìm được bạn cùng phòng" },
  { id: 3, value: "80+", label: "Chủ trọ", subLabel: "đã tin tưởng Le Phố Hub" },
  { id: 4, value: "8", label: "Quận nội thành", subLabel: "Hà Nội được hỗ trợ" },
];

const SectionStats: FC<SectionStatsProps> = ({ className = "" }) => {
  return (
    <div className={`nc-SectionStats ${className}`}>
      <div className="rounded-3xl bg-primary-6000 dark:bg-primary-800 p-8 md:p-12 lg:p-16">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-6 lg:gap-8">
          {STATS_DATA.map((stat) => (
            <div key={stat.id} className="text-center">
              <div className="text-3xl md:text-4xl font-extrabold text-white mb-1">
                {stat.value}
              </div>
              <div className="text-primary-200 font-semibold text-sm md:text-base mb-1">
                {stat.label}
              </div>
              <div className="text-primary-300 text-xs md:text-sm">
                {stat.subLabel}
              </div>
            </div>
          ))}
        </div>
        <div className="mt-10 text-center">
          <p className="text-primary-100 text-sm mb-4">
            Le Pho Hub — Nen tang tim phong tro thong minh tai noi thanh Ha Noi
          </p>
          <div className="flex flex-wrap items-center justify-center gap-3">
            <Link
              href="/phong-tro"
              className="px-5 py-2.5 bg-white text-primary-700 hover:bg-primary-50 rounded-full text-sm font-semibold transition-colors"
            >
              Tìm phòng ngay
            </Link>
            <Link
              href="/roommate"
              className="px-5 py-2.5 border border-white/30 text-white hover:bg-white/10 rounded-full text-sm font-semibold transition-colors"
            >
              Tìm người ghép ở
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SectionStats;