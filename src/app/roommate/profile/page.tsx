"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { CheckCircleIcon } from "@heroicons/react/24/solid";

const DISTRICTS = [
  "Dong Da","Ba Dinh","Hoan Kiem","Hai Ba Trung",
  "Cau Giay","Thanh Xuan","Nam Tu Liem","Bac Tu Liem",
  "Hoang Mai","Long Bien","Tay Ho","Thanh Tri",
];

const INTERESTS = [
  "Doc sach","The thao","Nau an","Du lich","Nhac song",
  "Phim anh","Game","Nhiet anh","Yoga","Thiet ke",
  "Lap trinh","Cafe","Chay bo","Gym","Bong da",
  "Bong ro","Am nhac","Ve tranh","Nau an","Nuoi thu cung",
  "Tai chinh","Nghe nhac","Tieng Anh","Phim Han","Anime",
];

export default function RoommateProfilePage() {
  const router = useRouter();
  const [submitted, setSubmitted] = useState(false);
  const [selectedInterests, setSelectedInterests] = useState<string[]>([]);
  const [form, setForm] = useState({
    name: "", age: "", gender: "female", occupation: "student",
    university: "", workplace: "",
    district: "Cau Giay", budgetMin: "2000000", budgetMax: "4000000",
    sleepSchedule: "flexible", cookingHabit: "sometimes",
    smoking: false, pets: false, personality: "ambivert",
    genderPreference: "any", bio: "", moveInDate: "2026-10-01",
  });

  const set = (key: string, val: unknown) => setForm(prev => ({ ...prev, [key]: val }));

  const toggleInterest = (item: string) => {
    setSelectedInterests(prev =>
      prev.includes(item) ? prev.filter(x => x !== item) : [...prev, item]
    );
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
  };

  if (submitted) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-neutral-50 dark:bg-neutral-900 p-6">
        <div className="bg-white dark:bg-neutral-800 rounded-3xl shadow-xl p-10 max-w-md w-full text-center">
          <CheckCircleIcon className="w-20 h-20 text-emerald-500 mx-auto mb-5" />
          <h2 className="text-2xl font-black text-neutral-900 dark:text-white mb-3">
            Ho so da tao thanh cong!
          </h2>
          <p className="text-neutral-500 dark:text-neutral-400 mb-8">
            He thong dang tim nguoi phu hop voi ban. Ket qua se hien thi trong vong 24 gio.
          </p>
          <button
            onClick={() => router.push("/roommate/matches")}
            className="w-full py-3 bg-primary-500 hover:bg-primary-600 text-white font-semibold rounded-xl transition-colors"
          >
            Xem danh sach phu hop ngay
          </button>
          <button
            onClick={() => setSubmitted(false)}
            className="w-full mt-3 py-3 border border-neutral-200 dark:border-neutral-600 text-neutral-600 dark:text-neutral-300 rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-700 transition-colors"
          >
            Chinh sua lai ho so
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-neutral-50 dark:bg-neutral-900 py-10">
      <div className="container max-w-2xl mx-auto px-6">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-black text-neutral-900 dark:text-white mb-2">
            Tao ho so ghep o
          </h1>
          <p className="text-neutral-500 dark:text-neutral-400">
            Dien thong tin de he thong tim nguoi phu hop nhat voi ban · Create Your Roommate Profile
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">

          {/* Basic Info */}
          <div className="bg-white dark:bg-neutral-800 rounded-2xl p-6 shadow-sm">
            <h2 className="font-bold text-lg text-neutral-900 dark:text-white mb-5 pb-3 border-b border-neutral-100 dark:border-neutral-700">
              1. Thong tin co ban
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Ho va ten *</label>
                <input required value={form.name} onChange={e => set("name", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
                  placeholder="Nguyen Thi A" />
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Tuoi *</label>
                <input required type="number" min="18" max="60" value={form.age} onChange={e => set("age", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
                  placeholder="22" />
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Gioi tinh</label>
                <select value={form.gender} onChange={e => set("gender", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="female">Nu</option>
                  <option value="male">Nam</option>
                </select>
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Nghe nghiep</label>
                <select value={form.occupation} onChange={e => set("occupation", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="student">Sinh vien</option>
                  <option value="working">Di lam</option>
                  <option value="freelance">Freelance</option>
                </select>
              </div>
            </div>
          </div>

          {/* Location & Budget */}
          <div className="bg-white dark:bg-neutral-800 rounded-2xl p-6 shadow-sm">
            <h2 className="font-bold text-lg text-neutral-900 dark:text-white mb-5 pb-3 border-b border-neutral-100 dark:border-neutral-700">
              2. Vi tri & Ngan sach
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Quan mong muon</label>
                <select value={form.district} onChange={e => set("district", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  {DISTRICTS.map(d => <option key={d} value={d}>{d}</option>)}
                </select>
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Toi thieu (VND)</label>
                <input type="number" value={form.budgetMin} onChange={e => set("budgetMin", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
                  placeholder="2000000" />
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Toi da (VND)</label>
                <input type="number" value={form.budgetMax} onChange={e => set("budgetMax", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
                  placeholder="4000000" />
              </div>
            </div>
          </div>

          {/* Lifestyle */}
          <div className="bg-white dark:bg-neutral-800 rounded-2xl p-6 shadow-sm">
            <h2 className="font-bold text-lg text-neutral-900 dark:text-white mb-5 pb-3 border-b border-neutral-100 dark:border-neutral-700">
              3. Phong cach song
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-4">
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Lich ngu</label>
                <select value={form.sleepSchedule} onChange={e => set("sleepSchedule", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="early_bird">Ngu som (truoc 11h)</option>
                  <option value="night_owl">Ngu muon (sau 12h)</option>
                  <option value="flexible">Linh hoat</option>
                </select>
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Thoi quen nau an</label>
                <select value={form.cookingHabit} onChange={e => set("cookingHabit", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="always">Thuong xuyen nau</option>
                  <option value="sometimes">Doi khi nau</option>
                  <option value="never">Khong nau</option>
                </select>
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Tinh cach</label>
                <select value={form.personality} onChange={e => set("personality", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="introvert">Huong noi</option>
                  <option value="extrovert">Huong ngoai</option>
                  <option value="ambivert">Trung tinh</option>
                </select>
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Gioi tinh ban cung phong</label>
                <select value={form.genderPreference} onChange={e => set("genderPreference", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="any">Khong quan trong</option>
                  <option value="female">Chi nu</option>
                  <option value="male">Chi nam</option>
                </select>
              </div>
            </div>
            <div className="flex gap-6">
              <label className="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" checked={form.smoking} onChange={e => set("smoking", e.target.checked)}
                  className="w-4 h-4 accent-primary-500" />
                <span className="text-sm text-neutral-700 dark:text-neutral-300">Hut thuoc</span>
              </label>
              <label className="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" checked={form.pets} onChange={e => set("pets", e.target.checked)}
                  className="w-4 h-4 accent-primary-500" />
                <span className="text-sm text-neutral-700 dark:text-neutral-300">Nuoi thu cung</span>
              </label>
            </div>
          </div>

          {/* Interests */}
          <div className="bg-white dark:bg-neutral-800 rounded-2xl p-6 shadow-sm">
            <h2 className="font-bold text-lg text-neutral-900 dark:text-white mb-2 pb-3 border-b border-neutral-100 dark:border-neutral-700">
              4. So thich
            </h2>
            <p className="text-sm text-neutral-400 mb-4">Chon nhung so thich cua ban (toi thieu 3)</p>
            <div className="flex flex-wrap gap-2">
              {INTERESTS.map((item) => (
                <button
                  key={item} type="button" onClick={() => toggleInterest(item)}
                  className={`px-3 py-1.5 rounded-full text-sm font-medium transition-all border ${
                    selectedInterests.includes(item)
                      ? "bg-primary-500 text-white border-primary-500"
                      : "bg-neutral-50 dark:bg-neutral-700 text-neutral-600 dark:text-neutral-300 border-neutral-200 dark:border-neutral-600 hover:border-primary-300"
                  }`}
                >
                  {item}
                </button>
              ))}
            </div>
          </div>

          {/* Bio */}
          <div className="bg-white dark:bg-neutral-800 rounded-2xl p-6 shadow-sm">
            <h2 className="font-bold text-lg text-neutral-900 dark:text-white mb-5 pb-3 border-b border-neutral-100 dark:border-neutral-700">
              5. Gioi thieu ban than
            </h2>
            <textarea required value={form.bio} onChange={e => set("bio", e.target.value)} rows={4}
              placeholder="Viet vai dong ve ban than, phong cach song va dieu ban tim kiem o nguoi ban cung phong..."
              className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400 resize-none" />
          </div>

          {/* Submit */}
          <button type="submit"
            className="w-full py-4 bg-primary-500 hover:bg-primary-600 text-white font-bold text-lg rounded-2xl shadow-lg shadow-primary-500/30 transition-all hover:-translate-y-0.5">
            Tao ho so ghep o
          </button>
        </form>
      </div>
    </div>
  );
}
