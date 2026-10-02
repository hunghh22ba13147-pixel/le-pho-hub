"use client";

import React, { useState, useRef, useEffect, useCallback } from "react";
import Link from "next/link";
import {
  SparklesIcon,
  PaperAirplaneIcon,
  TrashIcon,
  HomeModernIcon,
  UserGroupIcon,
  CurrencyDollarIcon,
  MapPinIcon,
  QuestionMarkCircleIcon,
} from "@heroicons/react/24/outline";
import { SparklesIcon as SparklesSolid } from "@heroicons/react/24/solid";

const MOCK_RULES: { pattern: RegExp; answer: string; listings?: { id: string; title: string; price: string; district: string }[] }[] = [
  {
    pattern: /dong da|dong-da|đống đa/i,
    answer: "Quận Đống Đa có rất nhiều phòng trọ gần các trường ĐH lớn. Giá trung bình 2.5–4 triệu/tháng. Khu vực Xã Đàn, Cát Linh, Kim Liên là những nơi được sinh viên ưa thích nhất.",
    listings: [
      { id: "1", title: "Phòng trọ Xã Đàn đẹp, yên tĩnh", price: "3.200.000đ/tháng", district: "Đống Đa" },
      { id: "2", title: "Chung cư mini Cát Linh, đầy đủ tiện nghi", price: "4.500.000đ/tháng", district: "Đống Đa" },
    ],
  },
  {
    pattern: /cau giay|cau-giay|cầu giấy/i,
    answer: "Cầu Giấy là thiên đường sinh viên với mật độ ĐH cao nhất Hà Nội (Bách Khoa, Quốc Gia, Sư Phạm...). Giá phòng 2–5 triệu/tháng. Khu Dịch Vọng, Mai Dịch có nhiều phòng giá tốt.",
    listings: [
      { id: "3", title: "Phòng Dịch Vọng gần ĐHBK, có bếp", price: "2.800.000đ/tháng", district: "Cầu Giấy" },
      { id: "4", title: "Studio Mai Dịch view đẹp, full nội thất", price: "5.000.000đ/tháng", district: "Cầu Giấy" },
    ],
  },
  {
    pattern: /thanh xuan|thanh xuân/i,
    answer: "Thanh Xuân là khu vực văn phòng và đi làm lý tưởng, phát triển mạnh về chung cư mini. Giá 3–6 triệu/tháng. Nhiều tòa nhà mới có thang máy, bảo vệ 24/7.",
    listings: [
      { id: "5", title: "Chung cư mini Nguyễn Trãi, thoáng mát", price: "3.800.000đ/tháng", district: "Thanh Xuân" },
    ],
  },
  {
    pattern: /gia|bao nhieu|chi phi|giá|bao nhiêu|chi phí/i,
    answer: "Giá phòng trọ nội thành Hà Nội theo khu vực:\n- Hoàn Kiếm / Ba Đình: 4–8 triệu/tháng\n- Đống Đa / Hai Bà Trưng: 2.5–5 triệu/tháng\n- Cầu Giấy / Thanh Xuân: 2.5–6 triệu/tháng\n- Nam/Bắc Từ Liêm: 2–4 triệu/tháng\n\nDiện tích 15–30m², đã bao gồm điện nước cơ bản.",
  },
  {
    pattern: /ghep o|roommate|ban cung phong|ghép ở|bạn cùng phòng/i,
    answer: "Le Phố Hub có tính năng Roommate Matching thông minh! Bạn có thể:\n1. Tạo hồ sơ ghép ở tại /roommate/profile\n2. Xem danh sách người phù hợp tại /roommate/matches\n3. Nhắn tin trực tiếp với người phù hợp\n\nHệ thống match dựa trên: lịch ngủ, ngân sách, sở thích, tính cách. Match Score từ 60–98%.",
  },
  {
    pattern: /pricing|goi|dich vu|tra phi|subscription|gói|dịch vụ/i,
    answer: "Le Phố Hub có 3 gói cho chủ trọ:\n- Miễn Phí: tối đa 3 phòng, tính năng cơ bản\n- Chủ Trọ Pro (299k/tháng): tối đa 20 phòng, hóa đơn tự động, ghi điện nước\n- Doanh Nghiệp (799k/tháng): không giới hạn, CTV & hoa hồng\n\nXem chi tiết tại /pricing. Gói Pro có 14 ngày dùng thử miễn phí!",
  },
  {
    pattern: /lien he|contact|ho tro|support|liên hệ|hỗ trợ/i,
    answer: "Bạn có thể liên hệ Le Phố Hub qua:\n- Trang web: /contact\n- Email: hello@lephohub.vn\n- Zalo OA\n- Facebook Page\n\nThời gian hỗ trợ: 8h–22h tất cả các ngày trong tuần.",
  },
  {
    pattern: /noi thanh|ha noi|quan|nội thành|hà nội|quận/i,
    answer: "Le Phố Hub phục vụ các quận nội thành Hà Nội:\n\nNội thành: Hoàn Kiếm, Đống Đa, Ba Đình, Hai Bà Trưng, Tây Hồ\nVùng ven: Cầu Giấy, Thanh Xuân, Nam Từ Liêm, Bắc Từ Liêm, Hoàng Mai, Long Biên\n\nBạn muốn tìm phòng ở quận nào? Mình sẽ giúp bạn tìm phòng phù hợp!",
  },
];

function getSmartAnswer(q: string) {
  for (const r of MOCK_RULES) {
    if (r.pattern.test(q)) return { answer: r.answer, listings: r.listings };
  }
  return { answer: "Xin lỗi, mình chưa có thông tin về vấn đề này. Bạn có thể thử hỏi về: tìm phòng theo quận, giá cả, ghép ở, gói dịch vụ, hoặc liên hệ hỗ trợ." };
}

interface Message {
  id: string;
  role: "user" | "assistant";
  content: string;
  listings?: { id: string; title: string; price: string; district: string }[];
  loading?: boolean;
}

const CATEGORIES = [
  { icon: MapPinIcon, label: "Tìm phòng theo quận", q: "Tìm phòng ở Hà Nội theo quận nội thành" },
  { icon: CurrencyDollarIcon, label: "Giá cả & Chi phí", q: "Giá phòng trọ nội thành Hà Nội bao nhiêu?" },
  { icon: UserGroupIcon, label: "Ghép ở / Roommate", q: "Tính năng ghép ở là gì và làm thế nào?" },
  { icon: HomeModernIcon, label: "Gói dịch vụ chủ trọ", q: "Các gói dịch vụ cho chủ trọ là gì?" },
  { icon: QuestionMarkCircleIcon, label: "Liên hệ hỗ trợ", q: "Làm thế nào để liên hệ Le Phố Hub?" },
];

export default function AIAssistantPage() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "welcome",
      role: "assistant",
      content: "Xin chào! Mình là AI tư vấn của Le Phố Hub 🏠\n\nMình có thể giúp bạn:\n- Tìm phòng trọ phù hợp tại Hà Nội\n- Tư vấn giá cả theo từng quận\n- Hướng dẫn tính năng Ghép ở / Roommate Matching\n- Thông tin gói dịch vụ cho chủ trọ\n\nBạn cần giúp gì hôm nay?",
    },
  ]);
  const [input, setInput] = useState("");
  const [isTyping, setIsTyping] = useState(false);
  const [useMock, setUseMock] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const send = useCallback(async (text?: string) => {
    const q = (text ?? input).trim();
    if (!q || isTyping) return;
    setInput("");

    const userMsg: Message = { id: Date.now() + "u", role: "user", content: q };
    const loadingMsg: Message = { id: Date.now() + "l", role: "assistant", content: "", loading: true };
    setMessages((prev) => [...prev, userMsg, loadingMsg]);
    setIsTyping(true);

    await new Promise((r) => setTimeout(r, 900 + Math.random() * 700));

    if (useMock) {
      const { answer, listings } = getSmartAnswer(q);
      setMessages((prev) => prev.map((m) => m.id === loadingMsg.id ? { ...m, content: answer, listings, loading: false } : m));
      setIsTyping(false);
      return;
    }

    try {
      const res = await fetch("/api/rag", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ question: q }),
      });
      if (!res.ok) throw new Error("api_error");
      const data = await res.json();
      setMessages((prev) => prev.map((m) => m.id === loadingMsg.id ? { ...m, content: data.answer || "Không có kết quả.", loading: false } : m));
    } catch {
      setUseMock(true);
      const { answer, listings } = getSmartAnswer(q);
      setMessages((prev) => prev.map((m) => m.id === loadingMsg.id ? { ...m, content: answer, listings, loading: false } : m));
    } finally {
      setIsTyping(false);
    }
  }, [input, isTyping, useMock]);

  const clearChat = () => setMessages([{ id: "w2", role: "assistant", content: "Đã xóa lịch sử. Mình có thể giúp gì cho bạn?" }]);

  const isFirstMessage = messages.length <= 1;

  return (
    <div className="min-h-screen bg-neutral-50 dark:bg-neutral-900 flex flex-col">
      {/* Page Header */}
      <div className="bg-white dark:bg-neutral-800 border-b border-neutral-100 dark:border-neutral-700 px-6 py-4">
        <div className="container max-w-4xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-orange-400 rounded-2xl flex items-center justify-center">
              <SparklesSolid className="w-5 h-5 text-white" />
            </div>
            <div>
              <h1 className="font-black text-neutral-900 dark:text-white text-lg">Le Phố Hub AI</h1>
              <p className="text-xs text-neutral-400">Tư vấn tìm phòng & ghép ở tại Hà Nội</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <button onClick={clearChat} className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm text-neutral-500 dark:text-neutral-400 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors">
              <TrashIcon className="w-4 h-4" />
              <span className="hidden sm:inline">Xóa lịch sử</span>
            </button>
          </div>
        </div>
      </div>

      {/* Chat Area */}
      <div className="flex-1 container max-w-4xl mx-auto px-4 py-6 space-y-6 overflow-y-auto">

        {/* Category Quick Start */}
        {isFirstMessage && (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 mt-2">
            {CATEGORIES.map((cat) => {
              const Icon = cat.icon;
              return (
                <button key={cat.label} onClick={() => send(cat.q)}
                  className="flex items-center gap-3 p-4 bg-white dark:bg-neutral-800 rounded-2xl border border-neutral-200 dark:border-neutral-700 hover:border-primary-300 hover:shadow-md transition-all text-left group">
                  <div className="w-10 h-10 bg-primary-500 rounded-xl flex items-center justify-center flex-shrink-0 group-hover:bg-primary-600 transition-colors">
                    <Icon className="w-5 h-5 text-white" />
                  </div>
                  <span className="text-sm font-medium text-neutral-700 dark:text-neutral-300">{cat.label}</span>
                </button>
              );
            })}
          </div>
        )}

        {/* Messages */}
        {messages.map((msg) => (
          <div key={msg.id} className={"flex " + (msg.role === "user" ? "justify-end" : "justify-start") + " gap-3"}>
            {msg.role === "assistant" && (
              <div className="w-9 h-9 rounded-2xl bg-gradient-to-br from-primary-400 to-orange-400 flex items-center justify-center flex-shrink-0 mt-1 shadow-sm">
                <SparklesIcon className="w-4 h-4 text-white" />
              </div>
            )}
            <div className="max-w-[75%] sm:max-w-[65%]">
              {msg.loading ? (
                <div className="bg-white dark:bg-neutral-800 border border-neutral-100 dark:border-neutral-700 px-5 py-4 rounded-2xl rounded-tl-sm shadow-sm">
                  <div className="flex gap-1.5 items-center">
                    <span className="w-2.5 h-2.5 bg-primary-400 rounded-full animate-bounce" style={{animationDelay:"0ms"}} />
                    <span className="w-2.5 h-2.5 bg-primary-400 rounded-full animate-bounce" style={{animationDelay:"150ms"}} />
                    <span className="w-2.5 h-2.5 bg-primary-400 rounded-full animate-bounce" style={{animationDelay:"300ms"}} />
                  </div>
                </div>
              ) : (
                <>
                  <div className={"px-5 py-3.5 rounded-2xl text-sm whitespace-pre-wrap leading-relaxed shadow-sm " +
                    (msg.role === "user"
                      ? "bg-primary-500 text-white rounded-tr-sm"
                      : "bg-white dark:bg-neutral-800 border border-neutral-100 dark:border-neutral-700 text-neutral-800 dark:text-neutral-100 rounded-tl-sm")}>
                    {msg.content}
                  </div>
                  {msg.listings && msg.listings.length > 0 && (
                    <div className="mt-3 grid grid-cols-1 sm:grid-cols-2 gap-2">
                      {msg.listings.map((l) => (
                        <Link key={l.id} href="/phong-tro"
                          className="bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl p-3 shadow-sm hover:border-primary-300 hover:shadow-md transition-all block">
                          <p className="text-sm font-semibold text-neutral-800 dark:text-neutral-100 line-clamp-1 mb-1">{l.title}</p>
                          <div className="flex items-center justify-between">
                            <span className="text-xs text-neutral-400 flex items-center gap-1">
                              <MapPinIcon className="w-3 h-3" />{l.district}
                            </span>
                            <span className="text-xs font-bold text-primary-600">{l.price}</span>
                          </div>
                        </Link>
                      ))}
                      <Link href="/phong-tro" className="col-span-full text-center text-xs text-primary-600 dark:text-primary-400 hover:underline py-1">
                        Xem tất cả phòng trọ tại Hà Nội →
                      </Link>
                    </div>
                  )}
                </>
              )}
            </div>
          </div>
        ))}
        <div ref={bottomRef} />
      </div>

      {/* Input Area */}
      <div className="bg-white dark:bg-neutral-800 border-t border-neutral-100 dark:border-neutral-700 px-4 py-4">
        <div className="container max-w-4xl mx-auto">
          <div className="flex items-end gap-3">
            <div className="flex-1 relative">
              <textarea
                ref={inputRef}
                rows={1}
                value={input}
                onChange={(e) => {
                  setInput(e.target.value);
                  e.target.style.height = "auto";
                  e.target.style.height = Math.min(e.target.scrollHeight, 120) + "px";
                }}
                onKeyDown={(e) => {
                  if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(); }
                }}
                placeholder="Hỏi về tìm phòng, ghép ở, giá cả tại Hà Nội..."
                disabled={isTyping}
                className="w-full px-4 py-3 rounded-2xl bg-neutral-100 dark:bg-neutral-700 text-neutral-900 dark:text-white text-sm focus:outline-none focus:ring-2 focus:ring-primary-400 resize-none disabled:opacity-50 min-h-[48px] max-h-[120px]"
              />
            </div>
            <button onClick={() => send()} disabled={!input.trim() || isTyping}
              className="w-12 h-12 flex items-center justify-center bg-primary-500 hover:bg-primary-600 disabled:opacity-40 text-white rounded-2xl transition-colors flex-shrink-0 shadow-md">
              <PaperAirplaneIcon className="w-5 h-5" />
            </button>
          </div>
          <p className="text-xs text-neutral-400 text-center mt-2">
            AI có thể mắc lỗi — xác minh thông tin quan trọng trước khi quyết định.
            {" "}<Link href="/phong-tro" className="text-primary-500 hover:underline">Tìm phòng trực tiếp →</Link>
          </p>
        </div>
      </div>
    </div>
  );
}