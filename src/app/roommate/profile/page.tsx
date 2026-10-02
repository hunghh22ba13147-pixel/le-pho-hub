"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { CheckCircleIcon } from "@heroicons/react/24/solid";

const DISTRICTS = [
  "Đống Đa", "Ba Đình", "Hoàn Kiếm", "Hai Bà Trưng",
  "Cầu Giấy", "Thanh Xuân", "Nam Từ Liêm", "Bắc Từ Liêm",
  "Hoàng Mai", "Long Biên", "Tây Hồ", "Thanh Trì",
];

const INTERESTS = [
  "Đọc sách", "Thể thao", "Nấu ăn", "Du lịch", "Nhạc sống",
  "Phim ảnh", "Game", "Nhiệt ảnh", "Yoga", "Thiết kế",
  "Lập trình", "Cafe", "Chạy bộ", "Gym", "Bóng đá",
  "Bóng rổ", "Âm nhạc", "Vẽ tranh", "Nuôi thú cưng",
  "Tài chính", "Nghe nhạc", "Tiếng Anh", "Phim Hàn", "Anime",
];

export default function RoommateProfilePage() {
  const router = useRouter();
  const [submitted, setSubmitted] = useState(false);
  const [selectedInterests, setSelectedInterests] = useState<string[]>([]);
  const [form, setForm] = useState({
    name: "", age: "", gender: "female", occupation: "student",
    university: "", workplace: "",
    district: "Cầu Giấy", budgetMin: "2000000", budgetMax: "4000000",
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
            Hồ sơ đã tạo thành công!
          </h2>
          <p className="text-neutral-500 dark:text-neutral-400 mb-8">
            Hệ thống đang tìm người phù hợp với bạn. Kết quả sẽ hiển thị trong vòng 24 giờ.
          </p>
          <button
            onClick={() => router.push("/roommate/matches")}
            className="w-full py-3 bg-primary-500 hover:bg-primary-600 text-white font-semibold rounded-xl transition-colors"
          >
            Xem danh sách phù hợp ngay
          </button>
          <button
            onClick={() => setSubmitted(false)}
            className="w-full mt-3 py-3 border border-neutral-200 dark:border-neutral-600 text-neutral-600 dark:text-neutral-300 rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-700 transition-colors"
          >
            Chỉnh sửa lại hồ sơ
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
            Tạo hồ sơ ghép ở
          </h1>
          <p className="text-neutral-500 dark:text-neutral-400">
            Điền thông tin để hệ thống tìm người phù hợp nhất với bạn · Create Your Roommate Profile
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">

          {/* Basic Info */}
          <div className="bg-white dark:bg-neutral-800 rounded-2xl p-6 shadow-sm">
            <h2 className="font-bold text-lg text-neutral-900 dark:text-white mb-5 pb-3 border-b border-neutral-100 dark:border-neutral-700">
              1. Thông tin cơ bản
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Họ và tên *</label>
                <input required value={form.name} onChange={e => set("name", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
                  placeholder="Nguyễn Thị A" />
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Tuổi *</label>
                <input required type="number" min="18" max="60" value={form.age} onChange={e => set("age", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
                  placeholder="22" />
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Giới tính</label>
                <select value={form.gender} onChange={e => set("gender", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="female">Nữ</option>
                  <option value="male">Nam</option>
                </select>
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Nghề nghiệp</label>
                <select value={form.occupation} onChange={e => set("occupation", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="student">Sinh viên</option>
                  <option value="working">Đi làm</option>
                  <option value="freelance">Freelance</option>
                </select>
              </div>
            </div>
          </div>

          {/* Location & Budget */}
          <div className="bg-white dark:bg-neutral-800 rounded-2xl p-6 shadow-sm">
            <h2 className="font-bold text-lg text-neutral-900 dark:text-white mb-5 pb-3 border-b border-neutral-100 dark:border-neutral-700">
              2. Vị trí & Ngân sách
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Quận mong muốn</label>
                <select value={form.district} onChange={e => set("district", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  {DISTRICTS.map(d => <option key={d} value={d}>{d}</option>)}
                </select>
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Tối thiểu (VND)</label>
                <input type="number" value={form.budgetMin} onChange={e => set("budgetMin", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
                  placeholder="2000000" />
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Tối đa (VND)</label>
                <input type="number" value={form.budgetMax} onChange={e => set("budgetMax", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
                  placeholder="4000000" />
              </div>
            </div>
          </div>

          {/* Lifestyle */}
          <div className="bg-white dark:bg-neutral-800 rounded-2xl p-6 shadow-sm">
            <h2 className="font-bold text-lg text-neutral-900 dark:text-white mb-5 pb-3 border-b border-neutral-100 dark:border-neutral-700">
              3. Phong cách sống
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-4">
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Lịch ngủ</label>
                <select value={form.sleepSchedule} onChange={e => set("sleepSchedule", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="early_bird">Ngủ sớm (trước 11h)</option>
                  <option value="night_owl">Ngủ muộn (sau 12h)</option>
                  <option value="flexible">Linh hoạt</option>
                </select>
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Thói quen nấu ăn</label>
                <select value={form.cookingHabit} onChange={e => set("cookingHabit", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="always">Thường xuyên nấu</option>
                  <option value="sometimes">Đôi khi nấu</option>
                  <option value="never">Không nấu</option>
                </select>
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Tính cách</label>
                <select value={form.personality} onChange={e => set("personality", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="introvert">Hướng nội</option>
                  <option value="extrovert">Hướng ngoại</option>
                  <option value="ambivert">Trung tính</option>
                </select>
              </div>
              <div>
                <label className="text-sm font-medium text-neutral-700 dark:text-neutral-300 block mb-1">Giới tính bạn cùng phòng</label>
                <select value={form.genderPreference} onChange={e => set("genderPreference", e.target.value)}
                  className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-white dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400">
                  <option value="any">Không quan trọng</option>
                  <option value="female">Chỉ nữ</option>
                  <option value="male">Chỉ nam</option>
                </select>
              </div>
            </div>
            <div className="flex gap-6">
              <label className="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" checked={form.smoking} onChange={e => set("smoking", e.target.checked)}
                  className="w-4 h-4 accent-primary-500" />
                <span className="text-sm text-neutral-700 dark:text-neutral-300">Hút thuốc</span>
              </label>
              <label className="flex items-center gap-2 cursor-pointer">
                <input type="checkbox" checked={form.pets} onChange={e => set("pets", e.target.checked)}
                  className="w-4 h-4 accent-primary-500" />
                <span className="text-sm text-neutral-700 dark:text-neutral-300">Nuôi thú cưng</span>
              </label>
            </div>
          </div>

          {/* Interests */}
          <div className="bg-white dark:bg-neutral-800 rounded-2xl p-6 shadow-sm">
            <h2 className="font-bold text-lg text-neutral-900 dark:text-white mb-2 pb-3 border-b border-neutral-100 dark:border-neutral-700">
              4. Sở thích
            </h2>
            <p className="text-sm text-neutral-400 mb-4">Chọn những sở thích của bạn (tối thiểu 3)</p>
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
              5. Giới thiệu bản thân
            </h2>
            <textarea required value={form.bio} onChange={e => set("bio", e.target.value)} rows={4}
              placeholder="Viết vài dòng về bản thân, phong cách sống và điều bạn tìm kiếm ở người bạn cùng phòng..."
              className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400 resize-none" />
          </div>

          {/* Submit */}
          <button type="submit"
            className="w-full py-4 bg-primary-500 hover:bg-primary-600 text-white font-bold text-lg rounded-2xl shadow-lg shadow-primary-500/30 transition-all hover:-translate-y-0.5">
            Tạo hồ sơ ghép ở
          </button>
        </form>
      </div>
    </div>
  );
}
