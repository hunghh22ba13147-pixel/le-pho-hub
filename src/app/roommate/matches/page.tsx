"use client";

import React, { useState, useMemo } from "react";
import Link from "next/link";
import Image from "next/image";
import { MagnifyingGlassIcon, ChatBubbleLeftIcon, HeartIcon } from "@heroicons/react/24/outline";
import { HeartIcon as HeartSolid } from "@heroicons/react/24/solid";
import rawRoommates from "@/data/dataset_roommates.json";
import { RoommateProfile, calculateMatchScore } from "@/data/dataset";

// Hồ sơ mẫu đại diện cho người dùng hiện tại đang tìm phòng ghép (CurrentUser)
const CURRENT_USER = {
  district: "Cầu Giấy",
  budget_min: 2500000,
  budget_max: 4500000,
  sleep_schedule: "early_bird",
  cooking_habit: "always",
  smoking: false,
  pets: false,
  personality: "introvert",
  interests: ["Đọc sách", "Nấu ăn", "Yoga", "Phim Hàn"],
};

function MatchScoreBadge({ score }: { score: number }) {
  const color =
    score >= 90
      ? "bg-emerald-500"
      : score >= 75
      ? "bg-blue-500"
      : "bg-orange-500";
  return (
    <div
      className={`${color} text-white text-xs font-bold px-2.5 py-1 rounded-full flex items-center gap-1 shadow-sm`}
    >
      <span>Match</span>
      <span>{score}%</span>
    </div>
  );
}

export default function RoommateMatchesPage() {
  const [searchQ, setSearchQ] = useState("");
  const [filterDistrict, setFilterDistrict] = useState("all");
  const [savedIds, setSavedIds] = useState<string[]>([]);

  // Nạp 20 hồ sơ từ Dataset thật và tính Match Score tự động theo thuật toán
  const enrichedProfiles = useMemo(() => {
    return (rawRoommates as unknown as RoommateProfile[]).map((p) => {
      const matchResult = calculateMatchScore(CURRENT_USER, {
        district: p.district,
        budget_min: p.budget_min,
        budget_max: p.budget_max,
        sleep_schedule: p.sleep_schedule,
        interests: p.interests,
        smoking: p.smoking,
        pets: p.pets,
      });

      return {
        ...p,
        matchScore: matchResult.score,
        commonInterests: matchResult.commonInterests,
      };
    });
  }, []);

  const filtered = enrichedProfiles
    .filter((p) => {
      const matchQ =
        p.full_name.toLowerCase().includes(searchQ.toLowerCase()) ||
        p.district.toLowerCase().includes(searchQ.toLowerCase()) ||
        p.bio.toLowerCase().includes(searchQ.toLowerCase()) ||
        p.interests.some((i) => i.toLowerCase().includes(searchQ.toLowerCase()));
      const matchD = filterDistrict === "all" || p.district === filterDistrict;
      return matchQ && matchD;
    })
    .sort((a, b) => b.matchScore - a.matchScore);

  const districts = Array.from(new Set(enrichedProfiles.map((p) => p.district)));

  const toggleSave = (id: string) => {
    setSavedIds((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );
  };

  const getSleepText = (s: string) => {
    if (s === "early_bird") return "Ngủ sớm (trước 23h)";
    if (s === "night_owl") return "Cú đêm (sau 24h)";
    return "Giờ giấc linh hoạt";
  };

  const getOccText = (o: string) => {
    if (o === "student") return "Sinh viên";
    if (o === "working") return "Đi làm";
    return "Freelance";
  };

  return (
    <div className="nc-RoommateMatches min-h-screen bg-neutral-50 dark:bg-neutral-900 pb-16">
      {/* HEADER */}
      <div className="bg-white dark:bg-neutral-800 border-b border-neutral-100 dark:border-neutral-700 py-8">
        <div className="container mx-auto px-6">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-4">
            <div>
              <h1 className="text-3xl font-black text-neutral-900 dark:text-white mb-1">
                Tìm người ghép ở
              </h1>
              <p className="text-neutral-500 dark:text-neutral-400">
                Hiển thị {filtered.length} hồ sơ từ bộ Dataset ghép ở · Thuật toán Matching theo trọng số
              </p>
            </div>
            <div className="inline-flex items-center gap-2 bg-orange-50 dark:bg-orange-950/30 text-orange-700 dark:text-orange-300 text-xs font-medium px-3.5 py-1.5 rounded-full border border-orange-200 dark:border-orange-800">
              <span>🎯 Điểm match tính theo: Ngân sách (30%), Khu vực (25%), Giờ ngủ (20%), Sở thích (15%), Thói quen (10%)</span>
            </div>
          </div>

          {/* Search & Filter */}
          <div className="flex flex-col sm:flex-row gap-3">
            <div className="relative flex-1">
              <MagnifyingGlassIcon className="absolute left-3.5 top-1/2 -translate-y-1/2 w-5 h-5 text-neutral-400" />
              <input
                type="text"
                placeholder="Tìm theo tên, quận, sở thích, trường học..."
                value={searchQ}
                onChange={(e) => setSearchQ(e.target.value)}
                className="w-full pl-11 pr-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
              />
            </div>
            <select
              value={filterDistrict}
              onChange={(e) => setFilterDistrict(e.target.value)}
              className="px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-700 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400 font-medium"
            >
              <option value="all">Tất cả quận ({districts.length} quận)</option>
              {districts.map((d) => (
                <option key={d} value={d}>
                  Quận {d}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* CARDS GRID */}
      <div className="container mx-auto px-6 py-10">
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
          {filtered.map((profile) => (
            <div
              key={profile.id}
              className="bg-white dark:bg-neutral-800 rounded-2xl shadow-md hover:shadow-xl transition-all overflow-hidden border border-neutral-100 dark:border-neutral-700 flex flex-col justify-between"
            >
              <div>
                {/* Card Header Banner */}
                <div className="relative h-28 bg-gradient-to-r from-orange-400 via-primary-500 to-amber-500">
                  <div className="absolute top-3 right-3 flex items-center gap-2">
                    <MatchScoreBadge score={profile.matchScore} />
                    <button
                      onClick={() => toggleSave(profile.id)}
                      className="p-1.5 bg-black/20 hover:bg-black/40 rounded-full text-white transition-colors"
                      title="Lưu hồ sơ"
                    >
                      {savedIds.includes(profile.id) ? (
                        <HeartSolid className="w-4 h-4 text-red-400" />
                      ) : (
                        <HeartIcon className="w-4 h-4" />
                      )}
                    </button>
                  </div>
                </div>

                {/* Avatar & Basic Info */}
                <div className="px-5 pb-2 -mt-12 flex items-end gap-3">
                  <div className="relative w-20 h-20 rounded-2xl overflow-hidden border-4 border-white dark:border-neutral-800 shadow-md bg-neutral-100 flex-shrink-0">
                    <Image
                      src={profile.avatar}
                      alt={profile.full_name}
                      fill
                      className="object-cover"
                    />
                  </div>
                  <div className="flex-1 min-w-0 pb-1">
                    <div className="flex items-center gap-1.5 flex-wrap">
                      <h3 className="font-bold text-neutral-900 dark:text-white text-base">
                        {profile.full_name}
                      </h3>
                      <span className="text-xs text-neutral-400 font-medium">
                        {profile.age}t · {profile.gender === "female" ? "Nữ" : "Nam"}
                      </span>
                    </div>
                    <p className="text-xs text-neutral-500 dark:text-neutral-400 truncate">
                      {getOccText(profile.occupation)} · {profile.workplace || "Hà Nội"}
                    </p>
                  </div>
                </div>

                {/* Card Body */}
                <div className="p-5 pt-3">
                  <p className="text-xs text-neutral-600 dark:text-neutral-300 line-clamp-2 mb-4 leading-relaxed bg-neutral-50 dark:bg-neutral-700/40 p-2.5 rounded-xl border border-neutral-100 dark:border-neutral-700">
                    &ldquo;{profile.bio}&rdquo;
                  </p>

                  {/* Details Grid */}
                  <div className="grid grid-cols-2 gap-2.5 text-xs mb-4">
                    <div className="flex items-center gap-1.5 text-neutral-600 dark:text-neutral-300">
                      <span>📍</span>
                      <span className="truncate">Quận {profile.district}</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-neutral-600 dark:text-neutral-300 font-semibold text-primary-600 dark:text-primary-400">
                      <span>💰</span>
                      <span>
                        {(profile.budget_min / 1e6).toFixed(1)}–{(profile.budget_max / 1e6).toFixed(1)} tr/th
                      </span>
                    </div>
                    <div className="flex items-center gap-1.5 text-neutral-600 dark:text-neutral-300">
                      <span>🌙</span>
                      <span className="truncate">{getSleepText(profile.sleep_schedule)}</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-neutral-600 dark:text-neutral-300">
                      <span>{profile.smoking ? "🚬 Có hút thuốc" : "🚭 Không hút thuốc"}</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-neutral-600 dark:text-neutral-300">
                      <span>{profile.pets ? "🐾 Có nuôi thú" : "🚫 Không nuôi thú"}</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-neutral-600 dark:text-neutral-300">
                      <span>🍳 {profile.cooking_habit === "always" ? "Thường nấu ăn" : profile.cooking_habit === "sometimes" ? "Thỉnh thoảng nấu" : "Không nấu ăn"}</span>
                    </div>
                  </div>

                  {/* Common interests */}
                  {profile.commonInterests && profile.commonInterests.length > 0 && (
                    <div className="mb-2">
                      <p className="text-[11px] text-neutral-400 mb-1.5 font-medium">
                        Sở thích tương đồng ({profile.commonInterests.length}):
                      </p>
                      <div className="flex flex-wrap gap-1.5">
                        {profile.commonInterests.map((interest) => (
                          <span
                            key={interest}
                            className="bg-emerald-100 dark:bg-emerald-950/40 text-emerald-800 dark:text-emerald-300 text-[11px] font-semibold px-2 py-0.5 rounded-md border border-emerald-200 dark:border-emerald-800"
                          >
                            ✓ {interest}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* All interests */}
                  <div className="mt-2">
                    <p className="text-[11px] text-neutral-400 mb-1 font-medium">Sở thích khác:</p>
                    <div className="flex flex-wrap gap-1">
                      {profile.interests
                        .filter((i) => !profile.commonInterests?.includes(i))
                        .map((interest) => (
                          <span
                            key={interest}
                            className="bg-neutral-100 dark:bg-neutral-700 text-neutral-600 dark:text-neutral-300 text-[11px] px-2 py-0.5 rounded-md"
                          >
                            {interest}
                          </span>
                        ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* Actions Footer */}
              <div className="p-5 pt-0">
                <div className="flex gap-2 pt-3 border-t border-neutral-100 dark:border-neutral-700">
                  <Link
                    href={`/roommate/chat/${profile.id}`}
                    className="flex-1 flex items-center justify-center gap-1.5 py-2.5 bg-primary-500 hover:bg-primary-600 text-white text-sm font-semibold rounded-xl transition-all shadow-md shadow-primary-500/20"
                  >
                    <ChatBubbleLeftIcon className="w-4 h-4" />
                    Nhắn tin
                  </Link>
                  <button className="px-4 py-2.5 border border-neutral-200 dark:border-neutral-600 text-neutral-700 dark:text-neutral-300 hover:bg-neutral-50 dark:hover:bg-neutral-700 text-sm font-medium rounded-xl transition-colors">
                    Xem hồ sơ
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {filtered.length === 0 && (
          <div className="text-center py-20 bg-white dark:bg-neutral-800 rounded-3xl border border-neutral-200 dark:border-neutral-700 mt-6">
            <p className="text-neutral-500 text-lg mb-2">Không tìm thấy người phù hợp với bộ lọc hiện tại.</p>
            <button
              onClick={() => {
                setSearchQ("");
                setFilterDistrict("all");
              }}
              className="px-5 py-2 bg-primary-500 text-white text-sm font-medium rounded-xl hover:bg-primary-600 transition-colors"
            >
              Xóa bộ lọc
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
