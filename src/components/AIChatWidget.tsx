"use client";

import React, { useState, useRef, useEffect, useCallback } from "react";
import Link from "next/link";
import {
  SparklesIcon,
  XMarkIcon,
  PaperAirplaneIcon,
  ArrowTopRightOnSquareIcon,
  TrashIcon,
} from "@heroicons/react/24/outline";
import { SparklesIcon as SparklesSolid } from "@heroicons/react/24/solid";

// ---- Mock AI engine for when API is unavailable ----
const MOCK_RULES: { pattern: RegExp; answer: string; listings?: { id: string; title: string; price: string; district: string }[] }[] = [
  {
    pattern: /dong da|dong-da/i,
    answer: "Quan Dong Da co rat nhieu phong tro gan cac truong DH lon. Gia trung binh 2.5-4 trieu/thang. Khu vuc Xa Dan, Cat Linh, Kim Lien la nhung noi duoc sinh vien ua thich nhat.",
    listings: [
      { id: "1", title: "Phong tro Xa Dan dep, yen tinh", price: "3,200,000d/thang", district: "Dong Da" },
      { id: "2", title: "Chung cu mini Cat Linh, day du tien nghi", price: "4,500,000d/thang", district: "Dong Da" },
    ],
  },
  {
    pattern: /cau giay|cau-giay/i,
    answer: "Cau Giay la thien duong sinh vien voi mat do DH cao nhat Ha Noi (Bach Khoa, Quoc Gia, Su Pham...). Gia phong 2-5 trieu/thang. Khu Dich Vong, Mai Dich co nhieu phong gia tot.",
    listings: [
      { id: "3", title: "Phong Dich Vong gan DHBK, co bep", price: "2,800,000d/thang", district: "Cau Giay" },
      { id: "4", title: "Studio Mai Dich view dep, full NT", price: "5,000,000d/thang", district: "Cau Giay" },
    ],
  },
  {
    pattern: /thanh xuan/i,
    answer: "Thanh Xuan la khu vuc van phong va di lam ly tuong, phat trien manh ve chung cu mini. Gia 3-6 trieu/thang. Nhieu toa nha moi co thang may, bao ve 24/7.",
    listings: [
      { id: "5", title: "Chung cu mini Nguyen Trai, thoang mat", price: "3,800,000d/thang", district: "Thanh Xuan" },
    ],
  },
  {
    pattern: /gia|bao nhieu|chi phi/i,
    answer: "Gia phong tro noi thanh Ha Noi theo khu vuc:\n- Hoan Kiem / Ba Dinh: 4-8 trieu/thang\n- Dong Da / Hai Ba Trung: 2.5-5 trieu/thang\n- Cau Giay / Thanh Xuan: 2.5-6 trieu/thang\n- Nam/Bac Tu Liem: 2-4 trieu/thang\n\nDien tich 15-30m2, da bao gom dien nuoc co ban.",
  },
  {
    pattern: /ghep o|roommate|ban cung phong/i,
    answer: "Le Pho Hub co tinh nang Roommate Matching thong minh! Ban co the:\n1. Tao ho so ghep o tai /roommate/profile\n2. Xem danh sach nguoi phu hop tai /roommate/matches\n3. Nhan tin truc tiep voi nguoi phu hop\n\nHe thong match dua tren: lich ngu, ngan sach, so thich, tinh cach. Match Score tu 60-98%.",
  },
  {
    pattern: /pricing|goi|dich vu|tra phi|subscription/i,
    answer: "Le Pho Hub co 3 goi cho chu tro:\n- Mien Phi: toi da 3 phong, tinh nang co ban\n- Chu Tro Pro (299k/thang): toi da 20 phong, hoa don tu dong, ghi dien nuoc\n- Doanh Nghiep (799k/thang): khong gioi han, CTV & hoa hong\n\nXem chi tiet tai /pricing. Goi Pro co 14 ngay dung thu mien phi!",
  },
  {
    pattern: /dang ky|sign up|tao tai khoan/i,
    answer: "De dang ky tai khoan Le Pho Hub:\n1. Truy cap /signup\n2. Nhap email va mat khau\n3. Xac nhan email\n4. Dien thong tin ho so\n\nMien phi hoan toan cho nguoi tim phong. Chu tro co goi mien phi voi 3 phong tro dau tien.",
  },
  {
    pattern: /lien he|contact|ho tro|support/i,
    answer: "Ban co the lien he Le Pho Hub qua:\n- Trang web: /contact\n- Email: hello@lephohub.vn\n- Zalo: 0372 858 098\n- Facebook: /lephohub\n\nThoi gian ho tro: 8h-22h tat ca cac ngay trong tuan.",
  },
  {
    pattern: /noi thanh|ha noi|quan/i,
    answer: "Le Pho Hub phuc vu cac quan noi thanh Ha Noi:\n\nNoi thanh: Hoan Kiem, Dong Da, Ba Dinh, Hai Ba Trung, Tay Ho\nVung ven: Cau Giay, Thanh Xuan, Nam Tu Liem, Bac Tu Liem, Hoang Mai, Long Bien\n\nBan muon tim phong o quan nao? Minh se giup ban tim phong phu hop!",
  },
];

const DEFAULT_ANSWER = "Xin loi, minh chua co thong tin ve van de nay. Ban co the thu hoi cac chu de: tim phong theo quan, gia ca, ghep o / roommate, goi dich vu, dang ky tai khoan, hoac lien he ho tro.";

function getSmartAnswer(q: string): { answer: string; listings?: { id: string; title: string; price: string; district: string }[] } {
  for (const rule of MOCK_RULES) {
    if (rule.pattern.test(q)) return { answer: rule.answer, listings: rule.listings };
  }
  return { answer: DEFAULT_ANSWER };
}

interface Message {
  id: string;
  role: "user" | "assistant";
  content: string;
  listings?: { id: string; title: string; price: string; district: string }[];
  loading?: boolean;
}

const QUICK_QUESTIONS = [
  "Tim phong o Cau Giay",
  "Gia phong Dong Da bao nhieu?",
  "Ghep o la gi?",
  "Xem goi dich vu",
];

export default function AIChatWidget() {
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "welcome",
      role: "assistant",
      content: "Xin chao! Minh la AI tu van cua Le Pho Hub 🏙️ Minh co the giup ban tim phong tro phu hop tai Ha Noi, tu van ghep o, goi dich vu. Ban can giup gi?",
    },
  ]);
  const [input, setInput] = useState("");
  const [isTyping, setIsTyping] = useState(false);
  const [useMock, setUseMock] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (open) {
      bottomRef.current?.scrollIntoView({ behavior: "smooth" });
      setTimeout(() => inputRef.current?.focus(), 100);
    }
  }, [open, messages]);

  const send = useCallback(async (text?: string) => {
    const q = (text ?? input).trim();
    if (!q) return;
    setInput("");

    const userMsg: Message = { id: Date.now() + "u", role: "user", content: q };
    const loadingMsg: Message = { id: Date.now() + "l", role: "assistant", content: "", loading: true };
    setMessages((prev) => [...prev, userMsg, loadingMsg]);
    setIsTyping(true);

    // Simulate typing delay
    await new Promise((r) => setTimeout(r, 800 + Math.random() * 600));

    if (useMock) {
      const { answer, listings } = getSmartAnswer(q);
      setMessages((prev) =>
        prev.map((m) => m.id === loadingMsg.id ? { ...m, content: answer, listings, loading: false } : m)
      );
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
      setMessages((prev) =>
        prev.map((m) => m.id === loadingMsg.id ? { ...m, content: data.answer || "Khong co ket qua.", loading: false } : m)
      );
    } catch {
      // Fallback to mock if API fails
      setUseMock(true);
      const { answer, listings } = getSmartAnswer(q);
      setMessages((prev) =>
        prev.map((m) => m.id === loadingMsg.id ? { ...m, content: answer, listings, loading: false } : m)
      );
    } finally {
      setIsTyping(false);
    }
  }, [input, useMock]);

  const clearHistory = () => {
    setMessages([{
      id: "welcome2",
      role: "assistant",
      content: "Da xoa lich su. Minh co the giup gi cho ban?",
    }]);
  };

  return (
    <>
      {/* Floating Button */}
      <button
        onClick={() => setOpen((o) => !o)}
        className={"fixed bottom-6 right-6 z-50 w-14 h-14 rounded-full shadow-2xl flex items-center justify-center transition-all duration-300 " +
          (open ? "bg-neutral-700 rotate-45" : "bg-gradient-to-br from-primary-500 to-orange-400 hover:scale-110")}
        aria-label="AI Chat"
      >
        {open
          ? <XMarkIcon className="w-6 h-6 text-white" />
          : <SparklesSolid className="w-6 h-6 text-white" />}
        {!open && (
          <span className="absolute -top-1 -right-1 w-4 h-4 bg-emerald-500 rounded-full border-2 border-white animate-pulse" />
        )}
      </button>

      {/* Chat Window */}
      {open && (
        <div className="fixed bottom-24 right-6 z-50 w-[360px] max-w-[calc(100vw-3rem)] h-[520px] flex flex-col bg-white dark:bg-neutral-800 rounded-3xl shadow-2xl overflow-hidden border border-neutral-100 dark:border-neutral-700">

          {/* Header */}
          <div className="bg-gradient-to-r from-primary-500 to-orange-400 px-5 py-4 flex items-center gap-3">
            <div className="w-9 h-9 bg-white/20 rounded-full flex items-center justify-center">
              <SparklesIcon className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <p className="text-white font-bold text-sm">Le Pho Hub AI</p>
              <p className="text-white/70 text-xs">Tu van tim phong & ghep o</p>
            </div>
            <div className="flex items-center gap-1">
              <button onClick={clearHistory} title="Xoa lich su" className="p-1.5 rounded-lg hover:bg-white/20 transition-colors">
                <TrashIcon className="w-4 h-4 text-white/80" />
              </button>
              <Link href="/ai-assistant" title="Mo rong" className="p-1.5 rounded-lg hover:bg-white/20 transition-colors">
                <ArrowTopRightOnSquareIcon className="w-4 h-4 text-white/80" />
              </Link>
              <button onClick={() => setOpen(false)} className="p-1.5 rounded-lg hover:bg-white/20 transition-colors">
                <XMarkIcon className="w-4 h-4 text-white" />
              </button>
            </div>
          </div>

          {/* Messages */}
          <div className="flex-1 overflow-y-auto p-4 space-y-4">
            {messages.map((msg) => (
              <div key={msg.id} className={"flex " + (msg.role === "user" ? "justify-end" : "justify-start")}>
                {msg.role === "assistant" && (
                  <div className="w-7 h-7 rounded-full bg-gradient-to-br from-primary-400 to-orange-400 flex items-center justify-center mr-2 flex-shrink-0 mt-0.5">
                    <SparklesIcon className="w-3.5 h-3.5 text-white" />
                  </div>
                )}
                <div className="max-w-[80%]">
                  {msg.loading ? (
                    <div className="bg-neutral-100 dark:bg-neutral-700 px-4 py-3 rounded-2xl rounded-tl-sm">
                      <div className="flex gap-1 items-center h-4">
                        <span className="w-2 h-2 bg-primary-400 rounded-full animate-bounce" style={{animationDelay:"0ms"}} />
                        <span className="w-2 h-2 bg-primary-400 rounded-full animate-bounce" style={{animationDelay:"150ms"}} />
                        <span className="w-2 h-2 bg-primary-400 rounded-full animate-bounce" style={{animationDelay:"300ms"}} />
                      </div>
                    </div>
                  ) : (
                    <>
                      <div className={"px-4 py-2.5 rounded-2xl text-sm whitespace-pre-wrap leading-relaxed " +
                        (msg.role === "user"
                          ? "bg-primary-500 text-white rounded-tr-sm"
                          : "bg-neutral-100 dark:bg-neutral-700 text-neutral-800 dark:text-neutral-100 rounded-tl-sm")}>
                        {msg.content}
                      </div>
                      {msg.listings && msg.listings.length > 0 && (
                        <div className="mt-2 space-y-1.5">
                          {msg.listings.map((l) => (
                            <div key={l.id} className="bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-600 rounded-xl p-3 shadow-sm">
                              <p className="text-xs font-semibold text-neutral-800 dark:text-neutral-100 line-clamp-1">{l.title}</p>
                              <div className="flex items-center justify-between mt-1">
                                <span className="text-xs text-neutral-400">{l.district}</span>
                                <span className="text-xs font-bold text-primary-600">{l.price}</span>
                              </div>
                            </div>
                          ))}
                          <Link href="/phong-tro" className="block text-center text-xs text-primary-600 dark:text-primary-400 hover:underline pt-1">
                            Xem tat ca phong tro →
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

          {/* Quick Questions */}
          {messages.length <= 2 && (
            <div className="px-4 pb-2">
              <p className="text-xs text-neutral-400 mb-2">Goi y cau hoi:</p>
              <div className="flex flex-wrap gap-1.5">
                {QUICK_QUESTIONS.map((q) => (
                  <button key={q} onClick={() => send(q)}
                    className="text-xs px-2.5 py-1 bg-white border border-orange-300 text-orange-700 dark:bg-neutral-700 dark:border-neutral-500 dark:text-neutral-200 rounded-full hover:bg-orange-50 transition-colors">
                    {q}
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* Input */}
          <div className="px-4 py-3 border-t border-neutral-100 dark:border-neutral-700 bg-white dark:bg-neutral-800">
            <div className="flex items-center gap-2">
              <input
                ref={inputRef}
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={(e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(); } }}
                placeholder="Hoi ve phong tro, ghep o, gia ca..."
                disabled={isTyping}
                className="flex-1 px-3 py-2.5 rounded-xl bg-neutral-100 dark:bg-neutral-700 text-neutral-900 dark:text-white text-sm focus:outline-none focus:ring-2 focus:ring-primary-400 disabled:opacity-50"
              />
              <button onClick={() => send()} disabled={!input.trim() || isTyping}
                className="w-10 h-10 flex items-center justify-center bg-primary-500 hover:bg-primary-600 disabled:opacity-40 text-white rounded-xl transition-colors flex-shrink-0">
                <PaperAirplaneIcon className="w-4 h-4" />
              </button>
            </div>
            <p className="text-xs text-neutral-300 dark:text-neutral-500 text-center mt-2">AI co the mac loi. Vui long xac minh thong tin quan trong.</p>
          </div>
        </div>
      )}
    </>
  );
}