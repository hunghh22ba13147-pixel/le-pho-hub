"use client";

import Heading from "@/shared/Heading";
import React, { FC, useState } from "react";
import sectionImage from "@/images/travelhero1.png";
import { MapPinIcon } from "@heroicons/react/24/outline";
import { AnimatePresence, motion, MotionConfig } from "framer-motion";
import Image from "next/image";
import { useSwipeable } from "react-swipeable";
import { variants } from "@/utils/animationVariants";

export interface SectionClientSayProps {
  className?: string;
  data?: typeof DEMO_DATA;
}

const DEMO_DATA = [
  {
    id: 1,
    clientName: "Nguyễn Minh Tuân",
    clientAddress: "Phòng trọ Đống Đa, Hà Nội",
    content:
      "Le Phố Hub giúp mình tìm được phòng ưng ý ở Đống Đa chỉ trong 2 ngày. Thông tin rõ ràng, ảnh thật 100%, chủ nhà dễ tính. Rất hài lòng!",
  },
  {
    id: 2,
    clientName: "Trần Thị Hương",
    clientAddress: "Chung cư mini Cầu Giấy, Hà Nội",
    content:
      "Mình là sinh viên năm 3 ĐHQG, tìm phòng gần trường qua Le Phố Hub. Lọc theo quận rất tiện, tìm được phòng 3 triệu/tháng trong vòng 1 tuần!",
  },
  {
    id: 3,
    clientName: "Lê Văn Đức",
    clientAddress: "Phòng trọ Thanh Xuân, Hà Nội",
    content:
      "Tính năng ghép ở của Le Phố Hub thật sự hay. Mình tìm được người bạn cùng phòng hợp nhau qua Match Score, tiết kiệm được gần 2 triệu/tháng!",
  },
];

const SectionClientSay: FC<SectionClientSayProps> = ({
  className = "",
  data = DEMO_DATA,
}) => {
  const [index, setIndex] = useState(0);
  const [direction, setDirection] = useState(0);

  function changeItemId(newVal: number) {
    if (newVal > index) {
      setDirection(1);
    } else {
      setDirection(-1);
    }
    setIndex(newVal);
  }

  const handlers = useSwipeable({
    onSwipedLeft: () => {
      if (index < data?.length - 1) {
        changeItemId(index + 1);
      }
    },
    onSwipedRight: () => {
      if (index > 0) {
        changeItemId(index - 1);
      }
    },
    trackMouse: true,
  });

  let currentItem = data[index];

  const renderIllustration = () => {
    return (
      <div className="relative flex items-center justify-center">
        <div className="absolute h-64 w-64 rounded-full bg-primary-100/60 dark:bg-primary-900/30 blur-3xl" />
        <Image className="relative mx-auto rounded-3xl shadow-xl" src={sectionImage} alt="Hình ảnh khách hàng" />
      </div>
    );
  };

  return (
    <div className={`nc-SectionClientSay relative ${className} `}>
      <Heading desc="Khách hàng nói gì về Le Phố Hub" isCenter>
        Khách hàng nói gì về Le Phố Hub
      </Heading>
      <div className="relative md:mb-16 max-w-2xl mx-auto">
        {renderIllustration()}
        <div className={`mt-12 lg:mt-16 relative `}>
          <span className="text-4xl text-primary-6000/40 absolute -mr-10 lg:mr-3 right-full top-1">
            "
          </span>
          <span className="text-4xl text-primary-6000/40 absolute -ml-10 lg:ml-3 left-full top-1">
            "
          </span>

          <MotionConfig
            transition={{
              x: { type: "spring", stiffness: 300, damping: 30 },
              opacity: { duration: 0.2 },
            }}
          >
            <div
              className={`relative whitespace-nowrap overflow-hidden`}
              {...handlers}
            >
              <AnimatePresence initial={false} custom={direction}>
                <motion.div
                  key={index}
                  custom={direction}
                  variants={variants(200, 1)}
                  initial="enter"
                  animate="center"
                  // exit="exit"
                  className="inline-flex flex-col items-center text-center whitespace-normal"
                >
                  <>
                    <span className="block text-2xl">
                      {currentItem.content}
                    </span>
                    <span className="block mt-8 text-2xl font-semibold">
                      {currentItem.clientName}
                    </span>
                    <div className="flex items-center space-x-2 text-lg mt-2 text-neutral-400">
                      <MapPinIcon className="h-5 w-5" />
                      <span>{currentItem.clientAddress}</span>
                    </div>
                  </>
                </motion.div>
              </AnimatePresence>

              <div className="mt-10 flex items-center justify-center space-x-2">
                {data.map((item, i) => (
                  <button
                    className={`w-2 h-2 rounded-full ${
                      i === index ? "bg-black/70" : "bg-black/10 "
                    }`}
                    onClick={() => changeItemId(i)}
                    key={i}
                  />
                ))}
              </div>
            </div>
          </MotionConfig>
        </div>
      </div>
    </div>
  );
};

export default SectionClientSay;
