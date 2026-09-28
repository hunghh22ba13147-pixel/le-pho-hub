import React from "react";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Ghep o / Roommate Matching — Le Pho Hub",
  description:
    "Tim ban cung phong thong minh tai noi thanh Ha Noi. Smart roommate matching platform.",
};

export default function RoommateLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <div className="roommate-layout">{children}</div>;
}
