"use client";

import React, { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { MagnifyingGlassIcon, AdjustmentsHorizontalIcon, ChatBubbleLeftIcon, HeartIcon } from "@heroicons/react/24/outline";
import { HeartIcon as HeartSolid } from "@heroicons/react/24/solid";

// ---- MOCK DATA ----
const MOCK_PROFILES = [
  {
    id: "rm-001", name: "Nguyen Thi Lan", age: 22, gender: "female",
    avatar: "https://i.pravatar.cc/150?img=5",
    occupation: "Sinh vien", university: "DH Bach Khoa Ha Noi",
    district: "Cau Giay", budgetMin: 2500000, budgetMax: 4000000,
    sleepSchedule: "Ngu som (truoc 11h)", cookingHabit: "Thuong xuyen nau",
    smoking: false, pets: false, personality: "Huong noi",
    bio: "Minh la sinh vien nam 3 BK, thich yeu tinh, hop voi nguoi ngu som va don gian.",
    interests: ["Doc sach", "Yoga", "Nau an", "Phim Han"],
    matchScore: 94, commonInterests: ["Nau an", "Phim Han"],
    moveInDate: "2026-10-01", status: "pending",
  },
  {
    id: "rm-002", name: "Tran Van Minh", age: 25, gender: "male",
    avatar: "https://i.pravatar.cc/150?img=12",
    occupation: "Di lam", workplace: "Cau Giay Tech Hub",
    district: "Cau Giay", budgetMin: 3000000, budgetMax: 5000000,
    sleepSchedule: "Linh hoat", cookingHabit: "Doi khi nau",
    smoking: false, pets: false, personality: "Huong ngoai",
    bio: "Fresher dev, thich an uong, them nguoi di gym buoi sang cung.",
    interests: ["The thao", "Cong nghe", "Game", "Du lich"],
    matchScore: 87, commonInterests: ["The thao", "Du lich"],
    moveInDate: "2026-10-15", status: "pending",
  },
  {
    id: "rm-003", name: "Pham Thi Hoa", age: 23, gender: "female",
    avatar: "https://i.pravatar.cc/150?img=9",
    occupation: "Sinh vien", university: "DH Kinh Te Quoc Dan",
    district: "Hai Ba Trung", budgetMin: 2000000, budgetMax: 3500000,
    sleepSchedule: "Ngu muon (sau 12h)", cookingHabit: "Khong nau",
    smoking: false, pets: true, personality: "Trung tinh",
    bio: "Nuoi meo nho, rat sach se. Thich nghe nhac va lam viec trong im lang.",
    interests: ["Nhac song", "Nuoi thu cung", "Art", "Cafe"],
    matchScore: 78, commonInterests: ["Cafe"],
    moveInDate: "2026-11-01", status: "pending",
  },
  {
    id: "rm-004", name: "Le Duc Anh", age: 26, gender: "male",
    avatar: "https://i.pravatar.cc/150?img=15",
    occupation: "Freelance", workplace: "Remote",
    district: "Dong Da", budgetMin: 3500000, budgetMax: 6000000,
    sleepSchedule: "Ngu muon (sau 12h)", cookingHabit: "Doi khi nau",
    smoking: false, pets: false, personality: "Huong ngoai",
    bio: "Freelancer thiet ke, lich lam viec linh hoat. Thich chup anh cuoi tuan.",
    interests: ["Nhiet anh", "Thiet ke", "Cafe", "Du lich"],
    matchScore: 82, commonInterests: ["Cafe", "Du lich"],
    moveInDate: "2026-10-01", status: "accepted",
  },
  {
    id: "rm-005", name: "Vo Thi Mai", age: 21, gender: "female",
    avatar: "https://i.pravatar.cc/150?img=25",
    occupation: "Sinh vien", university: "DH Ngoai Thuong",
    district: "Cau Giay", budgetMin: 2000000, budgetMax: 3000000,
    sleepSchedule: "Ngu som (truoc 11h)", cookingHabit: "Thuong xuyen nau",
    smoking: false, pets: false, personality: "Huong noi",
    bio: "Sinh vien nam 2 FTU. Thich sach va nau an. Tim ban neu phong tiet kiem.",
    interests: ["Doc sach", "Nau an", "Chay bo", "Tai chinh"],
    matchScore: 91, commonInterests: ["Doc sach", "Nau an", "Chay bo"],
    moveInDate: "2026-10-01", status: "pending",
  },
  {
    id: "rm-006", name: "Nguyen Quoc Bao", age: 24, gender: "male",
    avatar: "https://i.pravatar.cc/150?img=18",
    occupation: "Di lam", workplace: "Thanh Xuan Office",
    district: "Thanh Xuan", budgetMin: 3000000, budgetMax: 5500000,
    sleepSchedule: "Linh hoat", cookingHabit: "Doi khi nau",
    smoking: false, pets: false, personality: "Trung tinh",
    bio: "Marketing executive, ve muon nhung giu phong sach. Thich the thao.",
    interests: ["Bong ro", "The thao", "Phim", "Am nhac"],
    matchScore: 75, commonInterests: ["Am nhac"],
    moveInDate: "2026-11-15", status: "pending",
  },
];

function MatchScoreBadge({ score }: { score: number }) {
  const color =
    score >= 90 ? "bg-emerald-500" :
    score >= 75 ? "bg-blue-500" :
    "bg-orange-500";
  return (
    <div className={`${color} text-white text-xs font-bold px-2.5 py-1 rounded-full flex items-center gap-1`}>
      <span>Match</span>
      <span>{score}%</span>
    </div>
  );
}

export default function RoommateMatchesPage() {
  const [searchQ, setSearchQ] = useState("");
  const [filterDistrict, setFilterDistrict] = useState("all");
  const [savedIds, setSavedIds] = useState<string[]>([]);

  const filtered = MOCK_PROFILES.filter((p) => {
    const matchQ = p.name.toLowerCase().includes(searchQ.toLowerCase()) ||
      p.district.toLowerCase().includes(searchQ.toLowerCase()) ||
      p.bio.toLowerCase().includes(searchQ.toLowerCase());
    const matchD = filterDistrict === "all" || p.district === filterDistrict;
    return matchQ && matchD;
  }).sort((a, b) => b.matchScore - a.matchScore);

  const districts = Array.from(new Set(MOCK_PROFILES.map(p => p.district)));

  const toggleSave = (id: string) => {
    setSavedIds(prev => prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]);
  };

  return (
    <div className="nc-RoommateMatches min-h-screen bg-neutral-50 dark:bg-neutral-900">
      {/* HEADER */}
      <div className="bg-white dark:bg-neutral-800 border-b border-neutral-100 dark:border-neutral-700 py-8">
        <div className="container mx-auto px-6">
          <h1 className="text-3xl font-black text-neutral-900 dark:text-white mb-1">
            Tim nguoi ghep o
          </h1>
          <p className="text-neutral-500 dark:text-neutral-400 mb-6">
            {filtered.length} nguoi phu hop voi ban hom nay · Find Your Roommate
          </p>

          {/* Search & Filter */}
          <div className="flex flex-col sm:flex-row gap-3">
            <div className="relative flex-1">
              <MagnifyingGlassIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-neutral-400" />
              <input
                type="text"
                placeholder="Tim theo ten, quan, so thich..."
                value={searchQ}
                onChange={(e) => setSearchQ(e.target.value)}
                className="w-full pl-10 pr-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
              />
            </div>
            <select
              value={filterDistrict}
              onChange={(e) => setFilterDistrict(e.target.value)}
              className="px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-700 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
            >
              <option value="all">Tat ca quan</option>
              {districts.map(d => <option key={d} value={d}>{d}</option>)}
            </select>
          </div>
        </div>
      </div>

      {/* CARDS */}
      <div className="container mx-auto px-6 py-10">
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
          {filtered.map((profile) => (
            <div key={profile.id} className="bg-white dark:bg-neutral-800 rounded-2xl shadow-md hover:shadow-xl transition-all overflow-hidden group">
              {/* Card Header */}
              <div className="relative h-32 bg-gradient-to-br from-primary-100 to-secondary-100 dark:from-primary-900/30 dark:to-secondary-900/30">
                <div className="absolute inset-0 flex items-end p-4 gap-3">
                  <div className="relative w-16 h-16 rounded-2xl overflow-hidden border-2 border-white shadow-lg">
                    <Image src={profile.avatar} alt={profile.name} fill className="object-cover" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <h3 className="font-bold text-neutral-900 dark:text-white text-base">{profile.name}</h3>
                      <span className="text-xs text-neutral-500">{profile.age}t</span>
                    </div>
                    <p className="text-xs text-neutral-600 dark:text-neutral-400 truncate">
                      {profile.occupation} · {profile.district}
                    </p>
                  </div>
                  <div className="flex flex-col items-end gap-1.5">
                    <MatchScoreBadge score={profile.matchScore} />
                    <button onClick={() => toggleSave(profile.id)} className="text-neutral-400 hover:text-red-500 transition-colors">
                      {savedIds.includes(profile.id)
                        ? <HeartSolid className="w-5 h-5 text-red-500" />
                        : <HeartIcon className="w-5 h-5" />}
                    </button>
                  </div>
                </div>
              </div>

              {/* Card Body */}
              <div className="p-5">
                <p className="text-sm text-neutral-600 dark:text-neutral-400 line-clamp-2 mb-4">{profile.bio}</p>

                {/* Details */}
                <div className="grid grid-cols-2 gap-2 text-xs mb-4">
                  <div className="flex items-center gap-1.5 text-neutral-500">
                    <span>🌙</span>
                    <span>{profile.sleepSchedule}</span>
                  </div>
                  <div className="flex items-center gap-1.5 text-neutral-500">
                    <span>💰</span>
                    <span>{(profile.budgetMin/1e6).toFixed(1)}-{(profile.budgetMax/1e6).toFixed(1)}tr</span>
                  </div>
                  <div className="flex items-center gap-1.5 text-neutral-500">
                    <span>{profile.smoking ? "🚬" : "🚭"}</span>
                    <span>{profile.smoking ? "Co hut thuoc" : "Khong hut"}</span>
                  </div>
                  <div className="flex items-center gap-1.5 text-neutral-500">
                    <span>🐾</span>
                    <span>{profile.pets ? "Co nuoi thu" : "Khong nuoi"}</span>
                  </div>
                </div>

                {/* Common interests */}
                {profile.commonInterests.length > 0 && (
                  <div className="mb-4">
                    <p className="text-xs text-neutral-400 mb-1.5">So thich chung:</p>
                    <div className="flex flex-wrap gap-1.5">
                      {profile.commonInterests.map((i) => (
                        <span key={i} className="bg-orange-100 dark:bg-orange-900/30 text-orange-700 dark:text-orange-300 text-xs px-2 py-0.5 rounded-full">{i}</span>
                      ))}
                    </div>
                  </div>
                )}

                {/* Actions */}
                <div className="flex gap-2 pt-3 border-t border-neutral-100 dark:border-neutral-700">
                  <Link
                    href={`/roommate/chat/${profile.id}`}
                    className="flex-1 flex items-center justify-center gap-1.5 py-2.5 bg-primary-500 hover:bg-primary-600 text-white text-sm font-semibold rounded-xl transition-colors"
                  >
                    <ChatBubbleLeftIcon className="w-4 h-4" />
                    Nhan tin
                  </Link>
                  <button className="px-4 py-2.5 border border-neutral-200 dark:border-neutral-600 text-neutral-600 dark:text-neutral-300 text-sm rounded-xl hover:border-primary-300 hover:text-primary-600 transition-colors">
                    Xem ho so
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {filtered.length === 0 && (
          <div className="text-center py-20">
            <p className="text-neutral-400 text-lg">Khong tim thay nguoi phu hop. Thu tim kiem khac.</p>
          </div>
        )}
      </div>
    </div>
  );
}
