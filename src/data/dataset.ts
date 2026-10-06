export interface RoommateProfile {
  id: string;
  code?: string;
  full_name: string;
  age: number;
  gender: 'male' | 'female';
  avatar: string;
  occupation: 'student' | 'working' | 'freelance';
  workplace?: string;
  district: string;
  budget_min: number;
  budget_max: number;
  sleep_schedule: 'early_bird' | 'night_owl' | 'flexible';
  cooking_habit: 'always' | 'sometimes' | 'never';
  smoking: boolean;
  pets: boolean;
  personality: 'introvert' | 'extrovert' | 'ambivert';
  interests: string[];
  bio: string;
  is_active?: boolean;
}

export interface ListingItem {
  id: string;
  code?: string;
  title: string;
  description: string;
  price: number;
  area: number;
  district: string;
  address: string;
  images: string[];
  is_active?: boolean;
  created_at?: string;
}

/**
 * Thuật toán tính độ hòa hợp (Match Score) giữa 2 hồ sơ
 * Trọng số thực tế:
 * 1. Ngân sách giao thoa (Budget overlap): 30%
 * 2. Cùng quận ưu tiên (District match): 25%
 * 3. Lịch sinh hoạt (Sleep schedule): 20%
 * 4. Sở thích chung (Interests Jaccard similarity): 15%
 * 5. Thói quen (Hút thuốc & Thú cưng tương thích): 10%
 */
export function calculateMatchScore(
  userA: {
    district: string;
    budget_min: number;
    budget_max: number;
    sleep_schedule: string;
    interests: string[];
    smoking: boolean;
    pets: boolean;
  },
  userB: {
    district: string;
    budget_min: number;
    budget_max: number;
    sleep_schedule: string;
    interests: string[];
    smoking: boolean;
    pets: boolean;
  }
): { score: number; commonInterests: string[] } {
  let score = 0;

  // 1. Ngân sách (Budget overlap) - Max 30đ
  const minOverlap = Math.max(userA.budget_min, userB.budget_min);
  const maxOverlap = Math.min(userA.budget_max, userB.budget_max);
  if (minOverlap <= maxOverlap) {
    score += 30;
  } else {
    const diff = minOverlap - maxOverlap;
    if (diff <= 500000) score += 20;
    else if (diff <= 1000000) score += 10;
  }

  // 2. Khu vực (District) - Max 25đ
  if (userA.district.toLowerCase() === userB.district.toLowerCase()) {
    score += 25;
  } else {
    score += 10; // Cùng khu vực nội thành Hà Nội
  }

  // 3. Giờ ngủ (Sleep Schedule) - Max 20đ
  if (userA.sleep_schedule === userB.sleep_schedule) {
    score += 20;
  } else if (userA.sleep_schedule === 'flexible' || userB.sleep_schedule === 'flexible') {
    score += 15;
  } else {
    score += 5; // early_bird vs night_owl
  }

  // 4. Sở thích chung (Interests) - Max 15đ
  const common = userA.interests.filter((item) =>
    userB.interests.some((b) => b.toLowerCase() === item.toLowerCase())
  );
  if (common.length >= 3) score += 15;
  else if (common.length === 2) score += 12;
  else if (common.length === 1) score += 8;
  else score += 3;

  // 5. Thói quen (Smoking & Pets) - Max 10đ
  let habitsScore = 10;
  if (userA.smoking !== userB.smoking) habitsScore -= 5;
  if (!userA.pets && userB.pets) habitsScore -= 3;
  score += Math.max(0, habitsScore);

  // Giới hạn trong khoảng [50, 98]%
  const finalScore = Math.min(98, Math.max(50, Math.round(score)));

  return {
    score: finalScore,
    commonInterests: common,
  };
}
