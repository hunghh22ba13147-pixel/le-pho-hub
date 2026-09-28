import React from "react";
import Image from "next/image";
import logoV from "@/images/logo_trohoalac.png" // Le Pho Hub logo;

const LogoSvgLight = () => {
  return (
    <Image
      src={logoV}
      alt="Le Phố Hub"
      className="w-full h-auto hidden dark:block"
      width={80}
      height={40}
    />
  );
};

export default LogoSvgLight;
