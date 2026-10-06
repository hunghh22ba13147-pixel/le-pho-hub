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
        const q = (searchParams?.get("q") || "").toLowerCase().trim();
        const districtParam = (searchParams?.get("district") || "").toLowerCase().trim();

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

        // 4. Lọc theo từ khóa tìm kiếm
        if (q) {
          transformed = transformed.filter(
            (r) =>
              r.title.toLowerCase().includes(q) ||
              r.address.toLowerCase().includes(q) ||
              (r.description && r.description.toLowerCase().includes(q))
          );
        }

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

        // 5. Lọc theo quận (hỗ trợ cả "dong-da", "Đống Đa", "dong da")
        if (districtParam && districtParam !== "all") {
          const targetNorm = normalizeStr(districtParam);
          transformed = transformed.filter((r) => {
            const distNorm = normalizeStr(r.district || "");
            const addrNorm = normalizeStr(r.address || "");
            return distNorm.includes(targetNorm) || addrNorm.includes(targetNorm);
          });
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
