"use client";

import React, { FC, useEffect, useMemo, useState } from "react";
import { StayDataType, TaxonomyType, AuthorType } from "@/data/types";
import { useSearchParams } from "next/navigation";
import TabFilters from "./TabFilters";
import Heading2 from "@/shared/Heading2";
import StayCard2 from "@/components/StayCard2";
import datasetListings from "@/data/dataset_listings.json";
import { supabase } from "@/lib/supabaseClient";
import { Route } from "@/routers/types";

export interface SectionGridFilterCardProps {
  className?: string;
  data?: StayDataType[];
}

interface RawListing {
  id: string;
  title: string;
  description: string;
  price: number;
  area: number;
  district: string;
  address: string;
  images: string[];
}

function transformRawListingToStayData(item: RawListing): StayDataType {
  const author: AuthorType = {
    id: "author_default",
    firstName: "Chủ",
    lastName: "Trọ",
    displayName: "Chủ Nhà Trọ",
    avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face",
    count: 1,
    desc: "Chính chủ cho thuê",
    jobName: "Chủ trọ Le Phố Hub",
    href: "/author" as Route,
    starRating: 5,
  };

  const listingCategory: TaxonomyType = {
    id: item.district,
    name: `Quận ${item.district}`,
    href: `/phong-tro?district=${encodeURIComponent(item.district)}` as Route,
    taxonomy: "category",
    listingType: "stay",
  };

  const gallery = item.images && item.images.length > 0 
    ? item.images 
    : ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80"];

  return {
    id: item.id,
    author,
    date: "10/2026",
    href: `/phong-tro-detail?id=${item.id}` as Route,
    title: item.title,
    description: item.description,
    featuredImage: gallery[0],
    roomStatus: "available",
    commentCount: 12,
    viewCount: 156,
    address: item.address,
    district: item.district,
    reviewStart: 4.9,
    reviewCount: 18,
    like: false,
    galleryImgs: gallery,
    price: new Intl.NumberFormat("vi-VN").format(item.price) + "đ",
    area: item.area,
    listingCategory,
    maxGuests: 2,
    bedrooms: 1,
    bathrooms: 1,
    saleOff: "-10% hôm nay",
    isAds: false,
    map: { lat: 21.0285, lng: 105.8542 },
  };
}

const SectionGridFilterCard: FC<SectionGridFilterCardProps> = ({
  className = "",
  data,
}) => {
  const [rooms, setRooms] = useState<StayDataType[]>([]);
  const [loading, setLoading] = useState(true);
  const searchParams = useSearchParams();

  useEffect(() => {
    const loadRooms = async () => {
      if (data) return;
      setLoading(true);
      try {
        const rawQ = (searchParams?.get("q") || "").toLowerCase().trim();
        const districtParam = (searchParams?.get("district") || "").toLowerCase().trim();
        const priceParam = (searchParams?.get("price") || "").trim();
        const areaParam = (searchParams?.get("area") || "").trim();

        // Nếu q trùng với district (do form Hero gửi cả 2) thì bỏ q để tránh lọc quá chặt
        const q = rawQ === districtParam ? "" : rawQ;

        // 1. Thử lấy danh sách phòng trực tiếp từ Supabase (bảng listings mới tạo)
        let rawItems: RawListing[] = [];
        try {
          const { data: dbData, error } = await supabase
            .from("listings")
            .select("*")
            .eq("is_active", true)
            .order("created_at", { ascending: false });

          if (!error && dbData && dbData.length > 0) {
            rawItems = dbData as RawListing[];
          }
        } catch {
          // Bỏ qua lỗi Supabase để chuyển sang Dataset JSON
        }

        // 2. Nếu Supabase chưa kết nối hoặc trống, tự động nạp từ Dataset 40 phòng
        if (rawItems.length === 0) {
          rawItems = datasetListings as RawListing[];
        }

        // 3. Chuyển đổi sang StayDataType
        let transformed = rawItems.map(transformRawListingToStayData);

        // Hàm chuẩn hóa chuỗi tiếng Việt (bỏ dấu và gạch ngang) để so sánh slug
        const normalizeStr = (str: string) => {
          return str
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "")
            .replace(/đ/g, "d")
            .replace(/Đ/g, "d")
            .replace(/[^a-zA-Z0-9]/g, "")
            .toLowerCase();
        };

        // 4. Lọc theo từ khóa tìm kiếm (nếu có)
        if (q) {
          const qNorm = normalizeStr(q);
          transformed = transformed.filter((r) => {
            const titleNorm = normalizeStr(r.title);
            const addrNorm = normalizeStr(r.address);
            return titleNorm.includes(qNorm) || addrNorm.includes(qNorm);
          });
        }

        // 5. Lọc theo quận (hỗ trợ cả "dong-da", "Dong Da", "Đống Đa")
        if (districtParam && districtParam !== "all") {
          const targetNorm = normalizeStr(districtParam);
          transformed = transformed.filter((r) => {
            const distNorm = normalizeStr(r.district || "");
            const addrNorm = normalizeStr(r.address || "");
            return distNorm.includes(targetNorm) || addrNorm.includes(targetNorm);
          });
        }

        // 6. Lọc theo khoảng giá (price: 0-2, 2-3, 3-4, 4-6, 6+)
        if (priceParam) {
          if (priceParam === "0-2") {
            transformed = transformed.filter((r) => r.price && (rawItems.find(x => x.id === r.id)?.price || 0) <= 2000000);
          } else if (priceParam === "2-3") {
            transformed = transformed.filter((r) => {
              const p = rawItems.find(x => x.id === r.id)?.price || 0;
              return p >= 2000000 && p <= 3000000;
            });
          } else if (priceParam === "3-4") {
            transformed = transformed.filter((r) => {
              const p = rawItems.find(x => x.id === r.id)?.price || 0;
              return p >= 3000000 && p <= 4000000;
            });
          } else if (priceParam === "4-6") {
            transformed = transformed.filter((r) => {
              const p = rawItems.find(x => x.id === r.id)?.price || 0;
              return p >= 4000000 && p <= 6000000;
            });
          } else if (priceParam === "6+") {
            transformed = transformed.filter((r) => {
              const p = rawItems.find(x => x.id === r.id)?.price || 0;
              return p >= 6000000;
            });
          }
        }

        // 7. Lọc theo diện tích (area: 0-20, 20-30, 30-50, 50+)
        if (areaParam) {
          if (areaParam === "0-20") {
            transformed = transformed.filter((r) => (r.area || 0) <= 20);
          } else if (areaParam === "20-30") {
            transformed = transformed.filter((r) => (r.area || 0) >= 20 && (r.area || 0) <= 30);
          } else if (areaParam === "30-50") {
            transformed = transformed.filter((r) => (r.area || 0) >= 30 && (r.area || 0) <= 50);
          } else if (areaParam === "50+") {
            transformed = transformed.filter((r) => (r.area || 0) >= 50);
          }
        }

        setRooms(transformed);
      } catch (error) {
        console.error("Error loading rooms:", error);
      } finally {
        setLoading(false);
      }
    };

    loadRooms();
  }, [data, searchParams]);

  const displayData = useMemo(() => {
    return data || rooms;
  }, [data, rooms]);

  return (
    <div
      className={`nc-SectionGridFilterCard ${className}`}
      data-nc-id="SectionGridFilterCard"
    >
      <Heading2
        heading="Nhà trọ, phòng trọ Hà Nội"
        subHeading={`Đang hiển thị ${displayData.length} phòng trọ từ hệ thống cơ sở dữ liệu`}
      />

      <div className="mb-8 lg:mb-11">
        <TabFilters />
      </div>

      <div className="grid grid-cols-1 gap-6 md:gap-8 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        {loading ? (
          Array.from({ length: 8 }).map((_, index) => (
            <div key={index} className="animate-pulse">
              <div className="bg-gray-200 dark:bg-neutral-700 h-56 rounded-2xl mb-4"></div>
              <div className="h-4 bg-gray-200 dark:bg-neutral-700 rounded w-3/4 mb-2"></div>
              <div className="h-4 bg-gray-200 dark:bg-neutral-700 rounded w-1/2"></div>
            </div>
          ))
        ) : displayData.length > 0 ? (
          displayData.map((stay) => (
            <StayCard2 key={stay.id} data={stay} />
          ))
        ) : (
          <div className="col-span-full text-center py-16 bg-white dark:bg-neutral-800 rounded-3xl border border-neutral-200 dark:border-neutral-700">
            <div className="text-4xl mb-3">🔍</div>
            <p className="text-neutral-500 font-medium">Không tìm thấy phòng trọ nào phù hợp với bộ lọc.</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default SectionGridFilterCard;
