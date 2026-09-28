"use client";

import React from "react";
import Link from "next/link";
import {
  UserGroupIcon,
  SparklesIcon,
  ChatBubbleLeftRightIcon,
  ShieldCheckIcon,
  MapPinIcon,
  CurrencyDollarIcon,
  HeartIcon,
  MoonIcon,
} from "@heroicons/react/24/outline";

const FEATURES = [
  {
    icon: SparklesIcon,
    title: "AI Matching Thông Minh",
    subtitle: "Smart AI Matching",
    desc: "Hệ thống phân tích lịch sinh hoạt, thói quen và ngân sách để gợi ý người phù hợp nhất với bạn.",
    color: "bg-orange-100 text-orange-600",
  },
  {
    icon: UserGroupIcon,
    title: "Hồ Sơ Chi Tiết",
    subtitle: "Detailed Profiles",
    desc: "Tạo hồ sơ đầy đủ với thông tin về phong cách sống, sở thích và yêu cầu để tìm đúng người.",
    color: "bg-neutral-800 text-white",
  },
  {
    icon: ChatBubbleLeftRightIcon,
    title: "Nhắn Tin Trực Tiếp",
    subtitle: "Direct Messaging",
    desc: "Kết nối và nhắn tin với những người phù hợp để thảo luận trước khi quyết định ghép ở.",
    color: "bg-green-100 text-green-600",
  },
  {
    icon: ShieldCheckIcon,
    title: "An Toàn & Bảo Mật",
    subtitle: "Safe & Secure",
    desc: "Mọi hồ sơ đều được kiểm duyệt. Thông tin cá nhân được bảo mật, chỉ chia sẻ khi bạn đồng ý.",
    color: "bg-blue-100 text-blue-600",
  },
];

const HOW_IT_WORKS = [
  { step: "01", title: "Tạo hồ sơ", desc: "Điền thông tin về bản thân, lịch sinh hoạt, ngân sách và khu vực mong muốn." },
  { step: "02", title: "Xem gợi ý", desc: "Hệ thống AI sẽ gợi ý những người có chỉ số tương thích cao với bạn." },
  { step: "03", title: "Kết nối", desc: "Nhắn tin, trao đổi và hẹn gặp để hiểu nhau hơn trước khi quyết định." },
  { step: "04", title: "Ghép ở", desc: "Tìm phòng phù hợp cùng nhau và bắt đầu cuộc sống chia sẻ tiết kiệm hơn." },
];

const MATCH_CRITERIA = [
  { icon: MoonIcon, label: "Lịch sinh hoạt (Sáng / Tối)" },
  { icon: CurrencyDollarIcon, label: "Ngân sách & Chi phí" },
  { icon: MapPinIcon, label: "Khu vực mong muốn" },
  { icon: HeartIcon, label: "Sở thích & Phong cách sống" },
];

export default function RoommatePage() {
  return (
    <div className="min-h-screen bg-neutral-50 dark:bg-neutral-900">
      {/* Hero */}
      <div className="relative bg-gradient-to-br from-primary-600 via-primary-500 to-orange-400 text-white py-20 px-6 overflow-hidden">
        <div className="pointer-events-none absolute inset-0 opacity-10"
          style={{ backgroundImage: "radial-gradient(circle at 20% 50%, white 1px, transparent 1px), radial-gradient(circle at 80% 20%, white 1px, transparent 1px)", backgroundSize: "60px 60px" }} />
        <div className="container max-w-4xl mx-auto text-center relative z-10">
          <div className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-sm rounded-full px-4 py-2 text-sm font-medium mb-6">
            <SparklesIcon className="w-4 h-4" />
            <span>AI-powered Roommate Matching</span>
          </div>
          <h1 className="text-4xl md:text-5xl font-black mb-4 leading-tight">
            Tìm người ghép ở<br />
            <span className="text-yellow-300">phù hợp & tiết kiệm</span>
          </h1>
          <p className="text-lg text-white/80 mb-8 max-w-2xl mx-auto">
            Le Phố Hub kết nối bạn với người cùng phòng lý tưởng tại nội thành Hà Nội.
            Tiết kiệm 30–50% chi phí thuê nhà mỗi tháng.
          </p>
          <div className="flex flex-col sm:flex-row gap-3 justify-center">
            <Link href="/roommate/profile"
              className="px-8 py-3.5 bg-white text-primary-700 font-bold rounded-2xl hover:bg-yellow-50 transition-colors shadow-lg">
              Tạo hồ sơ miễn phí
            </Link>
            <Link href="/roommate/matches"
              className="px-8 py-3.5 border-2 border-white/60 text-white font-bold rounded-2xl hover:bg-white/10 transition-colors">
              Xem người phù hợp →
            </Link>
          </div>
        </div>
      </div>

      {/* Why Le Pho Hub */}
      <div className="container max-w-5xl mx-auto px-6 py-16">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-black text-neutral-900 dark:text-white mb-3">
            Tại sao chọn Le Phố Hub?
          </h2>
          <p className="text-neutral-500 dark:text-neutral-400">
            Why Choose Le Phố Hub for Roommate Matching?
          </p>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {FEATURES.map((f) => {
            const Icon = f.icon;
            return (
              <div key={f.title} className="bg-white dark:bg-neutral-800 rounded-2xl p-6 shadow-sm border border-neutral-100 dark:border-neutral-700 flex flex-col gap-4">
                <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${f.color}`}>
                  <Icon className="w-6 h-6" />
                </div>
                <div>
                  <h3 className="font-bold text-neutral-900 dark:text-white">{f.title}</h3>
                  <p className="text-xs text-neutral-400 mb-2">{f.subtitle}</p>
                  <p className="text-sm text-neutral-500 dark:text-neutral-400">{f.desc}</p>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Match Criteria */}
      <div className="bg-white dark:bg-neutral-800 py-12">
        <div className="container max-w-4xl mx-auto px-6">
          <h2 className="text-2xl font-black text-center text-neutral-900 dark:text-white mb-8">
            Tiêu chí ghép ở
          </h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {MATCH_CRITERIA.map((c) => {
              const Icon = c.icon;
              return (
                <div key={c.label} className="flex flex-col items-center gap-2 p-4 rounded-2xl bg-neutral-50 dark:bg-neutral-700">
                  <div className="w-10 h-10 bg-orange-100 dark:bg-orange-900/30 rounded-xl flex items-center justify-center">
                    <Icon className="w-5 h-5 text-orange-600 dark:text-orange-400" />
                  </div>
                  <p className="text-sm font-medium text-neutral-700 dark:text-neutral-200 text-center">{c.label}</p>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* How It Works */}
      <div className="container max-w-4xl mx-auto px-6 py-16">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-black text-neutral-900 dark:text-white mb-3">Cách thức hoạt động</h2>
          <p className="text-neutral-500">How It Works — 4 bước đơn giản</p>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {HOW_IT_WORKS.map((step) => (
            <div key={step.step} className="relative">
              <div className="text-5xl font-black text-primary-100 dark:text-primary-900/40 mb-3">{step.step}</div>
              <h3 className="font-bold text-neutral-900 dark:text-white mb-2">{step.title}</h3>
              <p className="text-sm text-neutral-500 dark:text-neutral-400">{step.desc}</p>
            </div>
          ))}
        </div>

        <div className="mt-12 text-center">
          <Link href="/roommate/profile"
            className="inline-block px-10 py-4 bg-primary-500 hover:bg-primary-600 text-white font-bold rounded-2xl shadow-lg transition-colors text-lg">
            Bắt đầu tìm người ghép ở →
          </Link>
          <p className="text-sm text-neutral-400 mt-3">Miễn phí · Không cần thẻ tín dụng</p>
        </div>
      </div>
    </div>
  );
}
