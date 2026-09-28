"use client";

import React, { useState } from "react";
import {
  MapPinIcon,
  EnvelopeIcon,
  PhoneIcon,
  GlobeAltIcon,
} from "@heroicons/react/24/outline";

export default function ContactPage() {
  const [form, setForm] = useState({ name: "", email: "", message: "" });
  const [sent, setSent] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSent(true);
  };

  return (
    <div className="nc-PageContact min-h-screen">
      {/* Header */}
      <div className="bg-gradient-to-br from-primary-600 to-orange-400 text-white py-16 px-6 text-center">
        <h1 className="text-4xl font-black mb-3">Lien he</h1>
        <p className="text-white/80 text-lg">Chung toi luon san sang lang nghe va ho tro ban</p>
      </div>

      <div className="container max-w-5xl mx-auto px-6 py-16">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">

          {/* Contact Info */}
          <div className="space-y-8">
            <div>
              <h2 className="text-2xl font-black text-neutral-900 dark:text-white mb-6">
                Thong tin lien he
              </h2>
            </div>

            <div className="flex items-start gap-4">
              <div className="w-11 h-11 bg-orange-100 rounded-xl flex items-center justify-center flex-shrink-0">
                <MapPinIcon className="w-5 h-5 text-orange-600" />
              </div>
              <div>
                <p className="font-semibold text-neutral-900 dark:text-white uppercase text-xs tracking-widest mb-1">
                  Dia chi van phong
                </p>
                <p className="text-neutral-600 dark:text-neutral-300">
                  18 Hoang Quoc Viet, Cau Giay, Ha Noi
                </p>
              </div>
            </div>

            <div className="flex items-start gap-4">
              <div className="w-11 h-11 bg-blue-100 rounded-xl flex items-center justify-center flex-shrink-0">
                <EnvelopeIcon className="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <p className="font-semibold text-neutral-900 dark:text-white uppercase text-xs tracking-widest mb-1">
                  Email
                </p>
                <a href="mailto:hunghh.22ba13147@usth.edu.vn" className="text-primary-600 hover:underline">
                  hunghh.22ba13147@usth.edu.vn
                </a>
                <br />
                <a href="mailto:hello@lephohub.vn" className="text-neutral-500 text-sm hover:underline">
                  hello@lephohub.vn
                </a>
              </div>
            </div>

            <div className="flex items-start gap-4">
              <div className="w-11 h-11 bg-green-100 rounded-xl flex items-center justify-center flex-shrink-0">
                <PhoneIcon className="w-5 h-5 text-green-600" />
              </div>
              <div>
                <p className="font-semibold text-neutral-900 dark:text-white uppercase text-xs tracking-widest mb-1">
                  So dien thoai
                </p>
                <a href="tel:0392429998" className="text-neutral-600 dark:text-neutral-300 hover:text-primary-600">
                  0392 429 998
                </a>
              </div>
            </div>

            <div className="flex items-start gap-4">
              <div className="w-11 h-11 bg-purple-100 rounded-xl flex items-center justify-center flex-shrink-0">
                <GlobeAltIcon className="w-5 h-5 text-purple-600" />
              </div>
              <div>
                <p className="font-semibold text-neutral-900 dark:text-white uppercase text-xs tracking-widest mb-1">
                  Ket noi voi Le Pho Hub
                </p>
                <div className="flex gap-3 mt-2 flex-wrap">
                  <a href="#" className="text-neutral-500 hover:text-primary-600 transition-colors">Facebook</a>
                  <span className="text-neutral-300">·</span>
                  <a href="#" className="text-neutral-500 hover:text-primary-600 transition-colors">Instagram</a>
                  <span className="text-neutral-300">·</span>
                  <a href="#" className="text-neutral-500 hover:text-primary-600 transition-colors">TikTok</a>
                </div>
              </div>
            </div>
          </div>

          {/* Contact Form */}
          <div className="bg-white dark:bg-neutral-800 rounded-3xl shadow-lg p-8 border border-neutral-100 dark:border-neutral-700">
            {sent ? (
              <div className="text-center py-8">
                <div className="text-5xl mb-4">✅</div>
                <h3 className="text-xl font-bold text-neutral-900 dark:text-white mb-2">
                  Gui thanh cong!
                </h3>
                <p className="text-neutral-500">Chung toi se phan hoi trong vong 24 gio.</p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-5">
                <h3 className="text-xl font-bold text-neutral-900 dark:text-white mb-6">
                  Gui tin nhan cho chung toi
                </h3>

                <div>
                  <label className="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-1.5">
                    Ho va ten
                  </label>
                  <input
                    type="text"
                    required
                    value={form.name}
                    onChange={(e) => setForm({ ...form, name: e.target.value })}
                    placeholder="Nhap ho va ten"
                    className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-1.5">
                    Email
                  </label>
                  <input
                    type="email"
                    required
                    value={form.email}
                    onChange={(e) => setForm({ ...form, email: e.target.value })}
                    placeholder="example@example.com"
                    className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-1.5">
                    Noi dung
                  </label>
                  <textarea
                    required
                    rows={5}
                    value={form.message}
                    onChange={(e) => setForm({ ...form, message: e.target.value })}
                    placeholder="Nhap noi dung can ho tro..."
                    className="w-full px-4 py-3 rounded-xl border border-neutral-200 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-700 text-neutral-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-400 resize-none"
                  />
                </div>

                <button
                  type="submit"
                  className="w-full py-3.5 bg-primary-500 hover:bg-primary-600 text-white font-bold rounded-xl transition-colors"
                >
                  Gui tin nhan
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
