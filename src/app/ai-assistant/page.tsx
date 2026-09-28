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
    pattern: /lien he|contact|ho tro|support/i,
    answer: "Ban co the lien he Le Pho Hub qua:\n- Trang web: /contact\n- Email: hello@lephohub.vn\n- Zalo OA\n- Facebook Page\n\nThoi gian ho tro: 8h-22h tat ca cac ngay trong tuan.",
  },
  {
    pattern: /noi thanh|ha noi|quan/i,
    answer: "Le Pho Hub phuc vu cac quan noi thanh Ha Noi:\n\nNoi thanh: Hoan Kiem, Dong Da, Ba Dinh, Hai Ba Trung, Tay Ho\nVung ven: Cau Giay, Thanh Xuan, Nam Tu Liem, Bac Tu Liem, Hoang Mai, Long Bien\n\nBan muon tim phong o quan nao? Minh se giup ban tim phong phu hop!",
  },
];

function getSmartAnswer(q: string) {
  for (const r of MOCK_RULES) {
    if (r.pattern.test(q)) return { answer: r.answer, listings: r.listings };
  }
  return { answer: "Xin loi, minh chua co thong tin ve van de nay. Ban co the thu hoi ve: tim phong theo quan, gia ca, ghep o, goi dich vu, hoac lien he ho tro." };
}

interface Message {
  id: string;
  role: "user" | "assistant";
  content: string;
  listings?: { id: string; title: string; price: string; district: string }[];
  loading?: boolean;
}

const CATEGORIES = [
  { icon: MapPinIcon, label: "Tim phong theo quan", q: "Tim phong o Ha Noi theo quan noi thanh" },
  { icon: CurrencyDollarIcon, label: "Gia ca & Chi phi", q: "Gia phong tro noi thanh Ha Noi bao nhieu?" },
  { icon: UserGroupIcon, label: "Ghep o / Roommate", q: "Tinh nang ghep o la gi va lam the nao?" },
  { icon: HomeModernIcon, label: "Goi dich vu chu tro", q: "Cac goi dich vu cho chu tro la gi?" },
  { icon: QuestionMarkCircleIcon, label: "Lien he ho tro", q: "Lam the nao de lien he Le Pho Hub?" },
];

export default function AIAssistantPage() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "welcome",
      role: "assistant",
      content: "Xin chao! Minh la AI tu van cua Le Pho Hub 🏙️\n\nMinh co the giup ban:\n- Tim phong tro phu hop tai Ha Noi\n- Tu van gia ca theo tung quan\n- Huong dan tinh nang Ghep o / Roommate Matching\n- Thong tin goi dich vu cho chu tro\n\nBan can giup gi hom nay?",
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
      setMessages((prev) => prev.map((m) => m.id === loadingMsg.id ? { ...m, content: data.answer || "Khong co ket qua.", loading: false } : m));
    } catch {
      setUseMock(true);
      const { answer, listings } = getSmartAnswer(q);
      setMessages((prev) => prev.map((m) => m.id === loadingMsg.id ? { ...m, content: answer, listings, loading: false } : m));
    } finally {
      setIsTyping(false);
    }
  }, [input, isTyping, useMock]);

  const clearChat = () => setMessages([{ id: "w2", role: "assistant", content: "Da xoa lich su. Minh co the giup gi cho ban?" }]);

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
              <h1 className="font-black text-neutral-900 dark:text-white text-lg">Le Pho Hub AI</h1>
              <p className="text-xs text-neutral-400">Tu van tim phong & ghep o tai Ha Noi</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <button onClick={clearChat} className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm text-neutral-500 dark:text-neutral-400 hover:bg-neutral-100 dark:hover:bg-neutral-700 transition-colors">
              <TrashIcon className="w-4 h-4" />
              <span className="hidden sm:inline">Xoa lich su</span>
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
                  <div className="w-10 h-10 bg-primary-50 dark:bg-primary-950/30 rounded-xl flex items-center justify-center flex-shrink-0 group-hover:bg-primary-100 dark:group-hover:bg-primary-900/40 transition-colors">
                    <Icon className="w-5 h-5 text-primary-600 dark:text-primary-400" />
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
                        Xem tat ca phong tro tai Ha Noi →
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
                placeholder="Hoi ve tim phong, ghep o, gia ca tai Ha Noi..."
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
            AI co the mac loi — xac minh thong tin quan trong truoc khi quyet dinh.
            {" "}<Link href="/phong-tro" className="text-primary-500 hover:underline">Tim phong truc tiep →</Link>
          </p>
        </div>
      </div>
    </div>
  );
}