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
    id: "free", name: "Miễn Phí", nameEn: "Free", icon: SparklesIcon,
    color: "text-neutral-600 dark:text-neutral-300",
    borderColor: "border-neutral-200 dark:border-neutral-700",
    bgGradient: "from-neutral-50 to-neutral-100 dark:from-neutral-800 dark:to-neutral-900",
    isPopular: false, priceMonthly: 0, priceYearly: 0, maxRooms: 3,
    desc: "Dành cho chủ trọ mới bắt đầu, muốn thử nghiệm nền tảng.",
    ctaLabel: "Dùng miễn phí", ctaStyle: "outline",
    features: [
      { label: "Tối đa 3 phòng trọ", included: true },
      { label: "Đăng tin cơ bản", included: true },
      { label: "Xem danh sách khách thuê", included: true },
      { label: "Hỗ trợ email", included: true },
      { label: "Quản lý hóa đơn", included: false },
      { label: "Ghi chỉ số điện nước", included: false },
      { label: "Thông báo tự động", included: false },
      { label: "Báo cáo doanh thu", included: false },
    ],
  },
  {
    id: "pro", name: "Chủ Trọ Pro", nameEn: "Landlord Pro", icon: BuildingOfficeIcon,
    color: "text-primary-600 dark:text-primary-400",
    borderColor: "border-primary-500",
    bgGradient: "from-primary-50 to-orange-50 dark:from-primary-950/30 dark:to-orange-950/20",
    isPopular: true, priceMonthly: 299000, priceYearly: 249000, maxRooms: 20,
    desc: "Giải pháp toàn diện cho chủ trọ quản lý 5–20 phòng.",
    ctaLabel: "Dùng thử 14 ngày miễn phí", ctaStyle: "primary",
    features: [
      { label: "Tối đa 20 phòng trọ", included: true },
      { label: "Đăng tin nâng cao + ảnh đẹp", included: true },
      { label: "Quản lý khách thuê đầy đủ", included: true },
      { label: "Hỗ trợ ưu tiên (chat + email)", included: true },
      { label: "Quản lý hóa đơn tự động", included: true },
      { label: "Ghi chỉ số điện nước", included: true },
      { label: "Thông báo tự động (Zalo/Email)", included: true },
      { label: "Báo cáo doanh thu hàng tháng", included: true },
    ],
  },
  {
    id: "business", name: "Doanh Nghiệp", nameEn: "Business", icon: RocketLaunchIcon,
    color: "text-secondary-600 dark:text-secondary-400",
    borderColor: "border-secondary-500",
    bgGradient: "from-secondary-50 to-amber-50 dark:from-secondary-950/30 dark:to-amber-950/20",
    isPopular: false, priceMonthly: 799000, priceYearly: 649000, maxRooms: "unlimited",
    desc: "Cho các đơn vị quản lý nhà trọ lớn, có nhiều tòa nhà.",
    ctaLabel: "Liên hệ tư vấn", ctaStyle: "secondary",
    features: [
      { label: "Không giới hạn phòng trọ", included: true },
      { label: "Đăng tin VIP ưu tiên hiển thị", included: true },
      { label: "Quản lý khách thuê đầy đủ", included: true },
      { label: "Hỗ trợ 24/7 + account manager riêng", included: true },
      { label: "Quản lý hóa đơn tự động", included: true },
      { label: "Ghi chỉ số điện nước", included: true },
      { label: "Thông báo Zalo/Email/SMS", included: true },
      { label: "Hệ thống CTV và quản lý hoa hồng", included: true },
    ],
  },
];

const FAQ = [
  { q: "Tôi có thể dùng thử trước khi mua không?", a: "Có — gói Chủ Trọ Pro có 14 ngày dùng thử miễn phí, không cần nhập thẻ tín dụng." },
  { q: "Thanh toán bằng hình thức nào?", a: "Hỗ trợ chuyển khoản ngân hàng, VNPay và MoMo. Xuất hóa đơn GTGT theo yêu cầu." },
  { q: "Nếu tôi vượt quá giới hạn phòng thì sao?", a: "Hệ thống sẽ thông báo và đề nghị bạn nâng cấp gói. Dữ liệu không bị mất." },
  { q: "Tôi có thể hủy bất cứ lúc nào không?", a: "Có, bạn có thể hủy gói bất cứ lúc nào. Gói hiện tại vẫn dùng đến hết tháng đã thanh toán." },
  { q: "Dữ liệu của tôi có an toàn không?", a: "Tất cả dữ liệu được mã hóa và lưu trên Supabase (PostgreSQL) với bảo mật RLS. Le Phố Hub không bao giờ bán dữ liệu của bạn." },
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
            Gói dịch vụ / Pricing
          </span>
          <h1 className="text-4xl sm:text-5xl font-black text-neutral-900 dark:text-white mb-4">
            Giải pháp quản lý nhà trọ <span className="text-primary-500">thông minh</span>
          </h1>
          <p className="text-lg text-neutral-500 dark:text-neutral-400 max-w-2xl mx-auto mb-8">
            Từ chủ trọ cá lẻ đến đơn vị quản lý nhiều tòa nhà — Le Phố Hub có gói phù hợp với mọi quy mô.
          </p>
          <div className="inline-flex items-center bg-neutral-100 dark:bg-neutral-700 rounded-full p-1 gap-1">
            <button onClick={() => setBilling("monthly")}
              className={"px-5 py-2 rounded-full text-sm font-semibold transition-all " + (billing === "monthly" ? "bg-white dark:bg-neutral-600 text-neutral-900 dark:text-white shadow-sm" : "text-neutral-500 dark:text-neutral-400")}>
              Theo tháng
            </button>
            <button onClick={() => setBilling("yearly")}
              className={"px-5 py-2 rounded-full text-sm font-semibold transition-all flex items-center gap-2 " + (billing === "yearly" ? "bg-white dark:bg-neutral-600 text-neutral-900 dark:text-white shadow-sm" : "text-neutral-500 dark:text-neutral-400")}>
              Theo năm
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
                      <span className="bg-primary-500 text-white text-xs font-bold px-3 py-1 rounded-full">PHỔ BIẾN NHẤT</span>
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
                          {price === 0 ? "0đ" : new Intl.NumberFormat("vi-VN").format(price) + "đ"}
                        </span>
                        {price > 0 && <span className="text-neutral-500 text-sm pb-1">/{billing === "monthly" ? "tháng" : "tháng"}</span>}
                      </div>
                      {billing === "yearly" && price > 0 && (
                        <p className="text-xs text-emerald-600 dark:text-emerald-400 mt-1">
                          Tiết kiệm {new Intl.NumberFormat("vi-VN").format((plan.priceMonthly - plan.priceYearly) * 12)}đ/năm
                        </p>
                      )}
                      <p className="text-xs text-neutral-400 mt-1">
                        Tối đa: {plan.maxRooms === "unlimited" ? "Không giới hạn" : plan.maxRooms + " phòng"}
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
                    {plan.id === "pro" && <p className="text-center text-xs text-neutral-400 mt-2">Không cần thẻ tín dụng</p>}
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
          <h2 className="text-2xl font-black text-neutral-900 dark:text-white mb-3">Phương thức thanh toán</h2>
          <p className="text-neutral-500 dark:text-neutral-400 mb-10">Hỗ trợ đầy đủ các hình thức thanh toán phổ biến tại Việt Nam</p>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
            {[
              { name: "MoMo", color: "bg-pink-50 dark:bg-pink-950/20 border-pink-200 dark:border-pink-800", icon: "💜", desc: "Ví điện tử MoMo" },
              { name: "VNPay", color: "bg-blue-50 dark:bg-blue-950/20 border-blue-200 dark:border-blue-800", icon: "🏦", desc: "Cổng thanh toán VNPay" },
              { name: "Chuyển khoản", color: "bg-green-50 dark:bg-green-950/20 border-green-200 dark:border-green-800", icon: "🏧", desc: "Chuyển khoản ngân hàng" },
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
          <h2 className="text-2xl font-black text-neutral-900 dark:text-white text-center mb-10">Câu hỏi thường gặp</h2>
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
          <h2 className="text-3xl font-black text-white mb-4">Bắt đầu quản lý nhà trọ thông minh ngay!</h2>
          <p className="text-primary-100 mb-8 max-w-xl mx-auto">
            Dùng thử gói Pro 14 ngày miễn phí — không cần thẻ tín dụng, hủy bất cứ lúc nào.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <button onClick={() => { setSelectedPlan(PLANS[1]); setShowPayModal(true); setPayDone(false); }}
              className="px-8 py-4 bg-white text-primary-600 font-bold rounded-full shadow-xl hover:-translate-y-0.5 transition-all">
              Dùng thử Pro miễn phí 14 ngày
            </button>
            <Link href="/contact" className="px-8 py-4 border-2 border-white/40 text-white font-semibold rounded-full hover:bg-white/10 transition-all">
              Liên hệ tư vấn
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
                <h3 className="text-2xl font-black text-neutral-900 dark:text-white mb-2">Thành công!</h3>
                <p className="text-neutral-500 dark:text-neutral-400 mb-6">
                  Gói <strong>{selectedPlan.name}</strong> đã được kích hoạt. Vui lòng kiểm tra email để xác nhận.
                </p>
                <button onClick={() => { setShowPayModal(false); setPayDone(false); }}
                  className="w-full py-3 bg-primary-500 hover:bg-primary-600 text-white font-bold rounded-xl">
                  Hoàn thành
                </button>
              </div>
            ) : (
              <>
                <div className="bg-gradient-to-r from-primary-500 to-orange-400 p-6">
                  <h3 className="text-xl font-black text-white">Đăng ký gói {selectedPlan.name}</h3>
                  <p className="text-primary-100 text-sm mt-1">
                    {new Intl.NumberFormat("vi-VN").format(getPrice(selectedPlan))}đ/{billing === "monthly" ? "tháng" : "tháng"}
                  </p>
                </div>
                <div className="p-6">
                  <p className="text-sm font-semibold text-neutral-700 dark:text-neutral-300 mb-3">Chọn phương thức thanh toán:</p>
                  <div className="grid grid-cols-3 gap-3 mb-6">
                    {[{ id: "momo", label: "MoMo", icon: "💜" }, { id: "vnpay", label: "VNPay", icon: "🏦" }, { id: "bank", label: "Ngân hàng", icon: "🏧" }].map((m) => (
                      <button key={m.id} onClick={() => setPayMethod(m.id as "bank" | "momo" | "vnpay")}
                        className={"p-3 rounded-xl border-2 text-center transition-all " + (payMethod === m.id ? "border-primary-500 bg-primary-50 dark:bg-primary-950/30" : "border-neutral-200 dark:border-neutral-600 hover:border-primary-300")}>
                        <div className="text-2xl mb-1">{m.icon}</div>
                        <div className="text-xs font-medium text-neutral-700 dark:text-neutral-300">{m.label}</div>
                      </button>
                    ))}
                  </div>
                  {payMethod === "bank" && (
                    <div className="bg-neutral-50 dark:bg-neutral-700/30 rounded-xl p-4 mb-4 text-xs text-neutral-600 dark:text-neutral-400 space-y-1">
                      <p className="font-semibold">Chuyển khoản đến:</p>
                      <p>Ngân hàng: Vietcombank</p>
                      <p>STK: 1234567890</p>
                      <p>Tên TK: LE PHO HUB CO LTD</p>
                      <p>Nội dung: LEPHO_{selectedPlan.id.toUpperCase()}</p>
                    </div>
                  )}
                  {(payMethod === "momo" || payMethod === "vnpay") && (
                    <div className="bg-neutral-50 dark:bg-neutral-700/30 rounded-xl p-4 mb-4 text-center text-xs text-neutral-500">
                      <div className="w-24 h-24 bg-neutral-200 dark:bg-neutral-600 rounded-xl mx-auto mb-2 flex items-center justify-center text-2xl">
                        {payMethod === "momo" ? "💜" : "🏦"}
                      </div>
                      <p>Quét mã QR hoặc click nút bên dưới để thanh toán</p>
                    </div>
                  )}
                  <div className="flex gap-3">
                    <button onClick={() => setShowPayModal(false)}
                      className="flex-1 py-3 border border-neutral-200 dark:border-neutral-600 text-neutral-600 dark:text-neutral-300 rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-700 transition-colors text-sm font-medium">
                      Hủy
                    </button>
                    <button onClick={() => setPayDone(true)}
                      className="flex-1 py-3 bg-primary-500 hover:bg-primary-600 text-white font-bold rounded-xl transition-colors text-sm">
                      Xác nhận thanh toán
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