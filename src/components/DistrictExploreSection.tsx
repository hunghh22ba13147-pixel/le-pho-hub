"use client";

import React, { useState } from "react";
import Link from "next/link";
import Image from "next/image";

// Danh sach quan noi thanh + vung ven Ha Noi
const HANOI_DISTRICTS = [
  {
    id: "dong-da",
    name: "Dong Da",
    nameVi: "Dong Da",
    description: "Trung tam van hoa, nhieu truong DH, gia phong hop ly",
    slug: "dong-da",
    image: "https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800&q=80",
    roomCount: 45,
    type: "Noi thanh",
  },
  {
    id: "cau-giay",
    name: "Cau Giay",
    nameVi: "Cau Giay",
    description: "Khu vuc sinh vien soi dong, gan DH Quoc Gia, DHBK",
    slug: "cau-giay",
    image: "https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=80",
    roomCount: 62,
    type: "Noi thanh",
  },
  {
    id: "thanh-xuan",
    name: "Thanh Xuan",
    nameVi: "Thanh Xuan",
    description: "Nhieu van phong, khu dan cu hien dai, giao thong thuan tien",
    slug: "thanh-xuan",
    image: "https://images.unsplash.com/photo-1516321497487-e288fb19713f?w=800&q=80",
    roomCount: 38,
    type: "Vung ven",
  },
  {
    id: "hai-ba-trung",
    name: "Hai Ba Trung",
    nameVi: "Hai Ba Trung",
    description: "Khu pho cu, kien truc Phap thuoc, gan ho Hoan Kiem",
    slug: "hai-ba-trung",
    image: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80",
    roomCount: 29,
    type: "Noi thanh",
  },
  {
    id: "ba-dinh",
    name: "Ba Dinh",
    nameVi: "Ba Dinh",
    description: "Trung tam chinh tri, pho co Ha Noi, nhieu di tich lich su",
    slug: "ba-dinh",
    image: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80",
    roomCount: 22,
    type: "Noi thanh",
  },
  {
    id: "nam-tu-liem",
    name: "Nam Tu Liem",
    nameVi: "Nam Tu Liem",
    description: "Khu do thi moi, nhieu chung cu mini, gia tot cho sinh vien",
    slug: "nam-tu-liem",
    image: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80",
    roomCount: 55,
    type: "Vung ven",
  },
  {
    id: "bac-tu-liem",
    name: "Bac Tu Liem",
    nameVi: "Bac Tu Liem",
    description: "Gan cac khu cong nghiep, nhieu phong tro gia binh dan",
    slug: "bac-tu-liem",
    image: "https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&q=80",
    roomCount: 41,
    type: "Vung ven",
  },
  {
    id: "long-bien",
    name: "Long Bien",
    nameVi: "Long Bien",
    description: "Khu vuc moi phat trien, giao thong tot, phong rong rai",
    slug: "long-bien",
    image: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&q=80",
    roomCount: 33,
    type: "Vung ven",
  },
];

const DistrictExploreSection = () => {
  const [filter, setFilter] = React.useState<string>("all");

  const filtered =
    filter === "all"
      ? HANOI_DISTRICTS
      : HANOI_DISTRICTS.filter((d) => d.type === filter);

  return (
    <div className="py-16 bg-neutral-50 dark:bg-neutral-900">
      <div className="container mx-auto px-6">
        <div className="text-center mb-10">
          <span className="text-xs font-bold uppercase tracking-wider text-primary-600 bg-primary-50 dark:bg-primary-950/30 px-3 py-1.5 rounded-full">
            Kham pha / Explore
          </span>
          <h2 className="text-3xl font-bold text-neutral-900 dark:text-white mt-4 mb-3">
            Tim phong theo quan Ha Noi
          </h2>
          <p className="text-neutral-600 dark:text-neutral-300 max-w-xl mx-auto">
            Kham pha cac khu vuc noi thanh va vung ven soi dong nhat — phu hop
            voi moi ngan sach va phong cach song.
          </p>
        </div>

        <div className="flex justify-center gap-3 mb-10">
          {["all", "Noi thanh", "Vung ven"].map((tab) => (
            <button
              key={tab}
              onClick={() => setFilter(tab)}
              className={`px-5 py-2 rounded-full text-sm font-medium transition-all ${
                filter === tab
                  ? "bg-primary-500 text-white shadow-md"
                  : "bg-white dark:bg-neutral-800 text-neutral-600 dark:text-neutral-300 hover:bg-primary-50 dark:hover:bg-neutral-700 border border-neutral-200 dark:border-neutral-600"
              }`}
            >
              {tab === "all" ? "Tat ca / All" : tab}
            </button>
          ))}
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {filtered.map((district) => (
            <Link
              key={district.id}
              href={`/phong-tro-theo-quan/${district.slug}`}
              className="group block"
            >
              <div className="bg-white dark:bg-neutral-800 rounded-2xl overflow-hidden shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1">
                <div className="relative h-44 overflow-hidden">
                  <Image
                    src={district.image}
                    alt={district.nameVi}
                    fill
                    className="object-cover group-hover:scale-110 transition-transform duration-300"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
                  <div className="absolute top-3 left-3">
                    <span
                      className={`text-xs font-semibold px-2.5 py-1 rounded-full ${
                        district.type === "Noi thanh"
                          ? "bg-primary-500 text-white"
                          : "bg-secondary-500 text-white"
                      }`}
                    >
                      {district.type}
                    </span>
                  </div>
                  <div className="absolute bottom-3 right-3 bg-white/90 dark:bg-neutral-800/90 backdrop-blur-sm px-3 py-1 rounded-full text-xs font-medium text-neutral-900 dark:text-white">
                    {district.roomCount} phong
                  </div>
                </div>
                <div className="p-5">
                  <h3 className="font-bold text-lg text-neutral-900 dark:text-white mb-1 group-hover:text-primary-500 transition-colors">
                    Quan {district.nameVi}
                  </h3>
                  <p className="text-xs text-neutral-500 dark:text-neutral-400 line-clamp-2 mb-3">
                    {district.description}
                  </p>
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-primary-600 dark:text-primary-400 font-medium">
                      {district.roomCount} listings
                    </span>
                    <div className="text-primary-500 group-hover:translate-x-1 transition-transform">
                      →
                    </div>
                  </div>
                </div>
              </div>
            </Link>
          ))}
        </div>

        <div className="text-center mt-10">
          <Link
            href="/phong-tro-theo-quan"
            className="inline-flex items-center gap-2 px-6 py-3 bg-primary-500 text-white rounded-full font-semibold hover:bg-primary-600 transition-colors shadow-md"
          >
            Xem tat ca quan / View All Districts
            <span>rarr;</span>
          </Link>
        </div>
      </div>
    </div>
  );
};

export default DistrictExploreSection;
