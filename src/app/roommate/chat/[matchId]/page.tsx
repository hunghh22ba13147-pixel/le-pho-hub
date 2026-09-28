"use client";

import React, { useState, useRef, useEffect } from "react";
import Image from "next/image";
import { PaperAirplaneIcon, ArrowLeftIcon } from "@heroicons/react/24/outline";
import Link from "next/link";

const MOCK_CHATS: Record<string, { name: string; avatar: string; matchScore: number; messages: { id: string; content: string; isOwn: boolean; time: string }[] }> = {
  "rm-001": {
    name: "Nguyen Thi Lan", avatar: "https://i.pravatar.cc/150?img=5", matchScore: 94,
    messages: [
      { id: "1", content: "Chao ban! Minh thay chung ta co nhieu diem chung :)", isOwn: false, time: "10:30" },
      { id: "2", content: "Chao Lan! Minh cung thich nau an. Ban tim phong o quan nao?", isOwn: true, time: "10:32" },
      { id: "3", content: "Minh muon o Cau Giay, ngan sach khoang 3-4 trieu.", isOwn: false, time: "10:35" },
      { id: "4", content: "Hoan hao! Minh cung vay. Chung ta co the gap nhau ban them khong?", isOwn: true, time: "10:36" },
      { id: "5", content: "Duoc! Cuoi tuan nay ban ranh khong?", isOwn: false, time: "10:38" },
    ],
  },
  "rm-002": {
    name: "Tran Van Minh", avatar: "https://i.pravatar.cc/150?img=12", matchScore: 87,
    messages: [
      { id: "1", content: "Hey! Toi thay profile cua ban rat thu vi.", isOwn: false, time: "09:15" },
      { id: "2", content: "Chao Minh! Minh chay bo moi sang. Ban tap mon gi?", isOwn: true, time: "09:20" },
      { id: "3", content: "Minh thich gym. Neu cung phong, di tap cung duoc do!", isOwn: false, time: "09:22" },
    ],
  },
};

export default function ChatPage({ params }: { params: { matchId: string } }) {
  const { matchId } = params;
  const chat = MOCK_CHATS[matchId] || MOCK_CHATS["rm-001"];
  const [messages, setMessages] = useState(chat.messages);
  const [input, setInput] = useState("");
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior: "smooth" }); }, [messages]);

  const sendMessage = () => {
    if (!input.trim()) return;
    const now = new Date();
    const time = now.getHours() + ":" + String(now.getMinutes()).padStart(2, "0");
    setMessages(prev => [...prev, { id: String(Date.now()), content: input.trim(), isOwn: true, time }]);
    setInput("");
    setTimeout(() => {
      const replies = ["Ok ban! De minh suy nghi them.", "Nghe hay do!", "Uh, dong y. Cuoi tuan gap nhau nhe!"];
      const replyTime = new Date();
      const rt = replyTime.getHours() + ":" + String(replyTime.getMinutes()).padStart(2, "0");
      setMessages(prev => [...prev, { id: String(Date.now()), content: replies[Math.floor(Math.random() * replies.length)], isOwn: false, time: rt }]);
    }, 1500);
  };

  return (
    <div className="flex flex-col h-screen bg-neutral-50 dark:bg-neutral-900">
      <div className="bg-white dark:bg-neutral-800 border-b border-neutral-100 dark:border-neutral-700 px-4 py-3 flex items-center gap-3 shadow-sm">
        <Link href="/roommate/matches" className="text-neutral-500 hover:text-primary-500 p-1">
          <ArrowLeftIcon className="w-5 h-5" />
        </Link>
        <div className="relative w-10 h-10 rounded-full overflow-hidden">
          <Image src={chat.avatar} alt={chat.name} fill className="object-cover" />
        </div>
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <span className="font-bold text-neutral-900 dark:text-white text-sm">{chat.name}</span>
            <span className="bg-emerald-500 text-white text-xs px-2 py-0.5 rounded-full">Match {chat.matchScore}%</span>
          </div>
          <p className="text-xs text-emerald-500">Dang hoat dong</p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-6 space-y-4">
        <div className="text-center">
          <span className="text-xs text-neutral-400 bg-neutral-100 dark:bg-neutral-800 px-3 py-1 rounded-full">Hom nay</span>
        </div>
        {messages.map((msg) => (
          <div key={msg.id} className={"flex " + (msg.isOwn ? "justify-end" : "justify-start") + " gap-2"}>
            {!msg.isOwn && (
              <div className="relative w-8 h-8 rounded-full overflow-hidden flex-shrink-0 mt-1">
                <Image src={chat.avatar} alt={chat.name} fill className="object-cover" />
              </div>
            )}
            <div>
              <div className={"px-4 py-2.5 rounded-2xl text-sm max-w-xs " + (msg.isOwn ? "bg-primary-500 text-white rounded-tr-sm" : "bg-white dark:bg-neutral-700 text-neutral-800 dark:text-neutral-100 shadow-sm rounded-tl-sm")}>
                {msg.content}
              </div>
              <p className={"text-xs text-neutral-400 mt-1 " + (msg.isOwn ? "text-right" : "")}>{msg.time}</p>
            </div>
          </div>
        ))}
        <div ref={bottomRef} />
      </div>

      <div className="bg-white dark:bg-neutral-800 border-t border-neutral-100 dark:border-neutral-700 px-4 py-3">
        <div className="flex items-center gap-3">
          <input type="text" value={input} onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => { if (e.key === "Enter") sendMessage(); }}
            placeholder="Nhap tin nhan..."
            className="flex-1 px-4 py-3 rounded-2xl bg-neutral-100 dark:bg-neutral-700 text-neutral-900 dark:text-white text-sm focus:outline-none focus:ring-2 focus:ring-primary-400" />
          <button onClick={sendMessage} disabled={!input.trim()}
            className="w-12 h-12 flex items-center justify-center bg-primary-500 hover:bg-primary-600 disabled:opacity-50 text-white rounded-2xl transition-colors">
            <PaperAirplaneIcon className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}