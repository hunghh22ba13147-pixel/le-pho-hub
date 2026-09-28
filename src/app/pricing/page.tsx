"use client";

import React, { useState } from "react";
import Link from "next/link";
import { CheckIcon, XMarkIcon } from "@heroicons/react/24/solid";
import { SparklesIcon, BuildingOfficeIcon, RocketLaunchIcon } from "@heroicons/react/24/outline";

type BillingCycle = "monthly" | "yearly";

interface PlanFeature { label: string; included: boolean; }
interface Plan {
  id: string; name: string; nameEn: string;
  icon: React.ElementType; color: string; borderColor: string; bgGradient: string;
  isPopular: boolean; priceMonthly: number; priceYearly: number;
  maxRooms: number | "unlimited"; desc: string;
  features: PlanFeature[]; ctaLabel: string; ctaStyle: "primary" | "secondary" | "outline";
}

const PLANS: Plan[] = [
  {
    id: "free", name: "Mien Phi", nameEn: "Free", icon: SparklesIcon,
    color: "text-neutral-600 dark:text-neutral-300",
    borderColor: "border-neutral-200 dark:border-neutral-700",
    bgGradient: "from-neutral-50 to-neutral-100 dark:from-neutral-800 dark:to-neutral-900",
    isPopular: false, priceMonthly: 0, priceYearly: 0, maxRooms: 3,
    desc: "Danh cho chu tro moi bat dau, muon thu nghiem nen tang.",
    ctaLabel: "Dung mien phi", ctaStyle: "outline",
    features: [
      { label: "Toi da 3 phong tro", included: true },
      { label: "Dang tin co ban", included: true },
      { label: "Xem danh sach khach thue", included: true },
      { label: "Ho tro email", included: true },
      { label: "Quan ly hoa don", included: false },
      { label: "Ghi chi so dien nuoc", included: false },
      { label: "Thong bao tu dong", included: false },
      { label: "Bao cao doanh thu", included: false },
    ],
  },
  {
    id: "pro", name: "Chu Tro Pro", nameEn: "Landlord Pro", icon: BuildingOfficeIcon,
    color: "text-primary-600 dark:text-primary-400",
    borderColor: "border-primary-500",
    bgGradient: "from-primary-50 to-orange-50 dark:from-primary-950/30 dark:to-orange-950/20",
    isPopular: true, priceMonthly: 299000, priceYearly: 249000, maxRooms: 20,
    desc: "Giai phap toan dien cho chu tro quan ly 5-20 phong.",
    ctaLabel: "Dung thu 14 ngay mien phi", ctaStyle: "primary",
    features: [
      { label: "Toi da 20 phong tro", included: true },
      { label: "Dang tin nang cao + anh dep", included: true },
      { label: "Quan ly khach thue day du", included: true },
      { label: "Ho tro uu tien (chat + email)", included: true },
      { label: "Quan ly hoa don tu dong", included: true },
      { label: "Ghi chi so dien nuoc", included: true },
      { label: "Thong bao tu dong (Zalo/Email)", included: true },
      { label: "Bao cao doanh thu hang thang", included: true },
    ],
  },
  {
    id: "business", name: "Doanh Nghiep", nameEn: "Business", icon: RocketLaunchIcon,
    color: "text-secondary-600 dark:text-secondary-400",
    borderColor: "border-secondary-500",
    bgGradient: "from-secondary-50 to-amber-50 dark:from-secondary-950/30 dark:to-amber-950/20",
    isPopular: false, priceMonthly: 799000, priceYearly: 649000, maxRooms: "unlimited",
    desc: "Cho cac don vi quan ly nha tro lon, co nhieu toa nha.",
    ctaLabel: "Lien he tu van", ctaStyle: "secondary",
    features: [
      { label: "Khong gioi han phong tro", included: true },
      { label: "Dang tin VIP uu tien hien thi", included: true },
      { label: "Quan ly khach thue day du", included: true },
      { label: "Ho tro 24/7 + account manager rieng", included: true },
      { label: "Quan ly hoa don tu dong", included: true },
      { label: "Ghi chi so dien nuoc", included: true },
      { label: "Thong bao Zalo/Email/SMS", included: true },
      { label: "He thong CTV va quan ly hoa hong", included: true },
    ],
  },
];

const FAQ = [
  { q: "Toi co the dung thu truoc khi mua khong?", a: "Co - goi Chu Tro Pro co 14 ngay dung thu mien phi, khong can nhap the tin dung." },
  { q: "Thanh toan bang hinh thuc nao?", a: "Ho tro chuyen khoan ngan hang, VNPay va MoMo. Xuat hoa don GTGT theo yeu cau." },
  { q: "Neu toi vuot qua gioi han phong thi sao?", a: "He thong se thong bao va de nghi ban nang cap goi. Du lieu khong bi mat." },
  { q: "Toi co the huy bat cu luc nao khong?", a: "Co, ban co the huy goi bat cu luc nao. Goi hien tai van dung den het thang da thanh toan." },
  { q: "Du lieu cua toi co an toan khong?", a: "Tat ca du lieu duoc ma hoa va luu tren Supabase (PostgreSQL) voi bao mat RLS. Le Pho Hub khong bao gio ban du lieu cua ban." },
];

export default function PricingPage() {
  const [billing, setBilling] = useState<BillingCycle>("monthly");
  const [openFaq, setOpenFaq] = useState<number | null>(null);
  const [showPayModal, setShowPayModal] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null);
  const [payMethod, setPayMethod] = useState<"bank" | "momo" | "vnpay">("momo");
  const [payDone, setPayDone] = useState(false);

  const getPrice = (plan: Plan) => billing === "yearly" ? plan.priceYearly : plan.priceMonthly;

  const handleCta = (plan: Plan) => {
    if (plan.id === "free") { window.location.href = "/signup"; return; }
    if (plan.id === "business") { window.location.href = "/contact"; return; }
    setSelectedPlan(plan); setShowPayModal(true); setPayDone(false);
  };

  return (
    <div className="min-h-screen bg-neutral-50 dark:bg-neutral-900">
      {/* HERO */}
      <section className="bg-white dark:bg-neutral-800 border-b border-neutral-100 dark:border-neutral-700 py-16 lg:py-20">
        <div className="container mx-auto px-6 text-center">
          <span className="inline-block bg-secondary-100 dark:bg-secondary-950/40 text-secondary-700 dark:text-secondary-300 text-xs font-bold uppercase tracking-wider px-4 py-1.5 rounded-full mb-5">
            Goi dich vu / Pricing
          </span>
          <h1 className="text-4xl sm:text-5xl font-black text-neutral-900 dark:text-white mb-4">
            Giai phap quan ly nha tro <span className="text-primary-500">thong minh</span>
          </h1>
          <p className="text-lg text-neutral-500 dark:text-neutral-400 max-w-2xl mx-auto mb-8">
            Tu chu tro ca le den don vi quan ly nhieu toa nha - Le Pho Hub co goi phu hop voi moi quy mo.
          </p>
          <div className="inline-flex items-center bg-neutral-100 dark:bg-neutral-700 rounded-full p-1 gap-1">
            <button onClick={() => setBilling("monthly")}
              className={"px-5 py-2 rounded-full text-sm font-semibold transition-all " + (billing === "monthly" ? "bg-white dark:bg-neutral-600 text-neutral-900 dark:text-white shadow-sm" : "text-neutral-500 dark:text-neutral-400")}>
              Theo thang
            </button>
            <button onClick={() => setBilling("yearly")}
              className={"px-5 py-2 rounded-full text-sm font-semibold transition-all flex items-center gap-2 " + (billing === "yearly" ? "bg-white dark:bg-neutral-600 text-neutral-900 dark:text-white shadow-sm" : "text-neutral-500 dark:text-neutral-400")}>
              Theo nam
              <span className="bg-emerald-500 text-white text-xs px-1.5 py-0.5 rounded-full">-17%</span>
            </button>
          </div>
        </div>
      </section>

      {/* PRICING CARDS */}
      <section className="py-16">
        <div className="container mx-auto px-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl mx-auto">
            {PLANS.map((plan) => {
              const Icon = plan.icon;
              const price = getPrice(plan);
              return (
                <div key={plan.id}
                  className={"relative flex flex-col rounded-3xl border-2 overflow-hidden bg-gradient-to-b " + plan.borderColor + " " + plan.bgGradient + (plan.isPopular ? " shadow-2xl shadow-primary-500/20 scale-105" : " shadow-md")}>
                  {plan.isPopular && <div className="absolute top-0 inset-x-0 h-1 bg-gradient-to-r from-primary-400 via-primary-500 to-orange-400" />}
                  {plan.isPopular && (
                    <div className="absolute top-4 right-4">
                      <span className="bg-primary-500 text-white text-xs font-bold px-3 py-1 rounded-full">PHO BIEN NHAT</span>
                    </div>
                  )}
                  <div className="p-8 flex-1">
                    <div className={"w-12 h-12 rounded-2xl flex items-center justify-center mb-4 bg-white/60 dark:bg-neutral-800/60 " + plan.color}>
                      <Icon className="w-6 h-6" />
                    </div>
                    <h3 className="text-xl font-black text-neutral-900 dark:text-white mb-0.5">{plan.name}</h3>
                    <p className="text-xs text-neutral-400 italic mb-3">{plan.nameEn}</p>
                    <p className="text-sm text-neutral-600 dark:text-neutral-400 mb-6">{plan.desc}</p>
                    <div className="mb-6">
                      <div className="flex items-end gap-1">
                        <span className="text-4xl font-black text-neutral-900 dark:text-white">
                          {price === 0 ? "0d" : new Intl.NumberFormat("vi-VN").format(price) + "d"}
                        </span>
                        {price > 0 && <span className="text-neutral-500 text-sm pb-1">/{billing === "monthly" ? "thang" : "thang"}</span>}
                      </div>
                      {billing === "yearly" && price > 0 && (
                        <p className="text-xs text-emerald-600 dark:text-emerald-400 mt-1">
                          Tiet kiem {new Intl.NumberFormat("vi-VN").format((plan.priceMonthly - plan.priceYearly) * 12)}d/nam
                        </p>
                      )}
                      <p className="text-xs text-neutral-400 mt-1">
                        Toi da: {plan.maxRooms === "unlimited" ? "Khong gioi han" : plan.maxRooms + " phong"}
                      </p>
                    </div>
                    <ul className="space-y-3">
                      {plan.features.map((f, i) => (
                        <li key={i} className={"flex items-start gap-2.5 text-sm " + (f.included ? "text-neutral-700 dark:text-neutral-300" : "text-neutral-400 line-through")}>
                          {f.included
                            ? <CheckIcon className={"w-4 h-4 flex-shrink-0 mt-0.5 " + plan.color} />
                            : <XMarkIcon className="w-4 h-4 flex-shrink-0 mt-0.5 text-neutral-300" />}
                          {f.label}
                        </li>
                      ))}
                    </ul>
                  </div>
                  <div className="p-8 pt-0">
                    <button onClick={() => handleCta(plan)}
                      className={"w-full py-3.5 rounded-2xl font-bold text-sm transition-all " +
                        (plan.ctaStyle === "primary" ? "bg-primary-500 hover:bg-primary-600 text-white shadow-lg shadow-primary-500/30"
                          : plan.ctaStyle === "secondary" ? "bg-secondary-500 hover:bg-secondary-600 text-white"
                          : "border-2 border-neutral-300 dark:border-neutral-600 text-neutral-700 dark:text-neutral-300 hover:border-primary-400 hover:text-primary-600")}>
                      {plan.ctaLabel}
                    </button>
                    {plan.id === "pro" && <p className="text-center text-xs text-neutral-400 mt-2">Khong can the tin dung</p>}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* PAYMENT METHODS */}
      <section className="py-16 bg-white dark:bg-neutral-800">
        <div className="container mx-auto px-6 max-w-3xl text-center">
          <h2 className="text-2xl font-black text-neutral-900 dark:text-white mb-3">Phuong thuc thanh toan</h2>
          <p className="text-neutral-500 dark:text-neutral-400 mb-10">Ho tro day du cac hinh thuc thanh toan pho bien tai Viet Nam</p>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
            {[
              { name: "MoMo", color: "bg-pink-50 dark:bg-pink-950/20 border-pink-200 dark:border-pink-800", icon: "💜", desc: "Vi dien tu MoMo" },
              { name: "VNPay", color: "bg-blue-50 dark:bg-blue-950/20 border-blue-200 dark:border-blue-800", icon: "🏦", desc: "Cong thanh toan VNPay" },
              { name: "Chuyen khoan", color: "bg-green-50 dark:bg-green-950/20 border-green-200 dark:border-green-800", icon: "🏧", desc: "Chuyen khoan ngan hang" },
            ].map((m) => (
              <div key={m.name} className={"rounded-2xl border p-6 " + m.color}>
                <div className="text-3xl mb-3">{m.icon}</div>
                <div className="font-bold text-neutral-800 dark:text-neutral-100 mb-1">{m.name}</div>
                <div className="text-sm text-neutral-500 dark:text-neutral-400">{m.desc}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="py-16 bg-neutral-50 dark:bg-neutral-900">
        <div className="container mx-auto px-6 max-w-3xl">
          <h2 className="text-2xl font-black text-neutral-900 dark:text-white text-center mb-10">Cau hoi thuong gap</h2>
          <div className="space-y-3">
            {FAQ.map((item, i) => (
              <div key={i} className="border border-neutral-200 dark:border-neutral-700 rounded-2xl overflow-hidden">
                <button onClick={() => setOpenFaq(openFaq === i ? null : i)}
                  className="w-full px-6 py-4 text-left flex items-center justify-between bg-white dark:bg-neutral-800 hover:bg-neutral-50 dark:hover:bg-neutral-700/50 transition-colors">
                  <span className="font-semibold text-neutral-800 dark:text-neutral-100 text-sm">{item.q}</span>
                  <span className={"text-primary-500 text-xl transition-transform " + (openFaq === i ? "rotate-45" : "")}>+</span>
                </button>
                {openFaq === i && (
                  <div className="px-6 pb-5 text-sm text-neutral-600 dark:text-neutral-400 bg-neutral-50 dark:bg-neutral-700/30">{item.a}</div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA BOTTOM */}
      <section className="py-16 bg-gradient-to-br from-primary-500 to-orange-500">
        <div className="container mx-auto px-6 text-center">
          <h2 className="text-3xl font-black text-white mb-4">Bat dau quan ly nha tro thong minh ngay!</h2>
          <p className="text-primary-100 mb-8 max-w-xl mx-auto">
            Dung thu goi Pro 14 ngay mien phi - khong can the tin dung, huy bat cu luc nao.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <button onClick={() => { setSelectedPlan(PLANS[1]); setShowPayModal(true); setPayDone(false); }}
              className="px-8 py-4 bg-white text-primary-600 font-bold rounded-full shadow-xl hover:-translate-y-0.5 transition-all">
              Dung thu Pro mien phi 14 ngay
            </button>
            <Link href="/contact" className="px-8 py-4 border-2 border-white/40 text-white font-semibold rounded-full hover:bg-white/10 transition-all">
              Lien he tu van
            </Link>
          </div>
        </div>
      </section>

      {/* PAYMENT MODAL */}
      {showPayModal && selectedPlan && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white dark:bg-neutral-800 rounded-3xl shadow-2xl w-full max-w-md overflow-hidden">
            {payDone ? (
              <div className="p-8 text-center">
                <div className="text-5xl mb-4">🎉</div>
                <h3 className="text-2xl font-black text-neutral-900 dark:text-white mb-2">Thanh cong!</h3>
                <p className="text-neutral-500 dark:text-neutral-400 mb-6">
                  Goi <strong>{selectedPlan.name}</strong> da duoc kich hoat. Vui long kiem tra email de xac nhan.
                </p>
                <button onClick={() => { setShowPayModal(false); setPayDone(false); }}
                  className="w-full py-3 bg-primary-500 hover:bg-primary-600 text-white font-bold rounded-xl">
                  Hoan thanh
                </button>
              </div>
            ) : (
              <>
                <div className="bg-gradient-to-r from-primary-500 to-orange-400 p-6">
                  <h3 className="text-xl font-black text-white">Dang ky goi {selectedPlan.name}</h3>
                  <p className="text-primary-100 text-sm mt-1">
                    {new Intl.NumberFormat("vi-VN").format(getPrice(selectedPlan))}d/{billing === "monthly" ? "thang" : "thang"}
                  </p>
                </div>
                <div className="p-6">
                  <p className="text-sm font-semibold text-neutral-700 dark:text-neutral-300 mb-3">Chon phuong thuc thanh toan:</p>
                  <div className="grid grid-cols-3 gap-3 mb-6">
                    {[{ id: "momo", label: "MoMo", icon: "💜" }, { id: "vnpay", label: "VNPay", icon: "🏦" }, { id: "bank", label: "Ngan hang", icon: "🏧" }].map((m) => (
                      <button key={m.id} onClick={() => setPayMethod(m.id as "bank" | "momo" | "vnpay")}
                        className={"p-3 rounded-xl border-2 text-center transition-all " + (payMethod === m.id ? "border-primary-500 bg-primary-50 dark:bg-primary-950/30" : "border-neutral-200 dark:border-neutral-600 hover:border-primary-300")}>
                        <div className="text-2xl mb-1">{m.icon}</div>
                        <div className="text-xs font-medium text-neutral-700 dark:text-neutral-300">{m.label}</div>
                      </button>
                    ))}
                  </div>
                  {payMethod === "bank" && (
                    <div className="bg-neutral-50 dark:bg-neutral-700/30 rounded-xl p-4 mb-4 text-xs text-neutral-600 dark:text-neutral-400 space-y-1">
                      <p className="font-semibold">Chuyen khoan den:</p>
                      <p>Ngan hang: Vietcombank</p>
                      <p>STK: 1234567890</p>
                      <p>Ten TK: LE PHO HUB CO LTD</p>
                      <p>Noi dung: LEPHO_{selectedPlan.id.toUpperCase()}</p>
                    </div>
                  )}
                  {(payMethod === "momo" || payMethod === "vnpay") && (
                    <div className="bg-neutral-50 dark:bg-neutral-700/30 rounded-xl p-4 mb-4 text-center text-xs text-neutral-500">
                      <div className="w-24 h-24 bg-neutral-200 dark:bg-neutral-600 rounded-xl mx-auto mb-2 flex items-center justify-center text-2xl">
                        {payMethod === "momo" ? "💜" : "🏦"}
                      </div>
                      <p>Quet ma QR hoac click nut ben duoi de thanh toan</p>
                    </div>
                  )}
                  <div className="flex gap-3">
                    <button onClick={() => setShowPayModal(false)}
                      className="flex-1 py-3 border border-neutral-200 dark:border-neutral-600 text-neutral-600 dark:text-neutral-300 rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-700 transition-colors text-sm font-medium">
                      Huy
                    </button>
                    <button onClick={() => setPayDone(true)}
                      className="flex-1 py-3 bg-primary-500 hover:bg-primary-600 text-white font-bold rounded-xl transition-colors text-sm">
                      Xac nhan thanh toan
                    </button>
                  </div>
                </div>
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
}