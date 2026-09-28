import React from "react";
import Image from "next/image";
import logoV from "@/images/logo_trohoalac.png" // Le Pho Hub logo;

const LogoSvg = () => {
  return (
    <Image
      src={logoV}
      alt="Le Phố Hub"
      className="w-full h-auto block dark:hidden"
      width={80}
      height={40}
    />
  );
};

export default LogoSvg;
