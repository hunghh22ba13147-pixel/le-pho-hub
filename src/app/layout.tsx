import { Be_Vietnam_Pro } from "next/font/google";
import dynamic from "next/dynamic";
import ClientCommons from "./ClientCommons";

const PerformanceMonitor = dynamic(() => import("@/components/PerformanceMonitor"), {
  ssr: false,
});
import ConditionalLayout from "@/components/ConditionalLayout";
import { AuthProvider } from "@/contexts/AuthContext";
import { CompareProvider } from "@/contexts/CompareContext";
import "./globals.css";
import "@/fonts/line-awesome-1.3.0/css/line-awesome.css";
import "@/styles/index.css";
import "rc-slider/assets/index.css";
import { Metadata } from "next";

const beVietnamPro = Be_Vietnam_Pro({
  subsets: ["vietnamese", "latin"],
  display: "swap",
  weight: ["300", "400", "500", "600", "700"],
  preload: true,
  fallback: ["system-ui", "arial"],
});

export const metadata: Metadata = {
  title: "Le Phố Hub — Tìm phòng trọ & Ghép ở nội thành Hà Nội",
  description:
    "Nền tảng tìm kiếm phòng trọ, chung cư mini và ghép ở thông minh tại nội thành Hà Nội. Smart housing & roommate matching platform for Hanoi.",
  keywords: [
    "phòng trọ Hà Nội",
    "thuê phòng nội thành",
    "ghép ở Hà Nội",
    "roommate Hà Nội",
    "chung cư mini",
    "Le Phố Hub",
  ],
  icons: {
    icon: "/favicon.ico",
    shortcut: "/favicon.ico",
    apple: "/favicon.ico",
  },
};

export default function RootLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: any;
}) {
  return (
    <html lang="vi" className={beVietnamPro.className}>
      <body className="bg-white text-base dark:bg-neutral-900 text-neutral-900 dark:text-neutral-200">
        <AuthProvider>
          <CompareProvider>
            <PerformanceMonitor />
            <ClientCommons />
            <ConditionalLayout>
              {children}
            </ConditionalLayout>
          </CompareProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
