import type { NextConfig } from "next";

const GH_SHA = process.env.GH_SHA;
console.log("GH_SHA", GH_SHA);
const nextConfig: NextConfig = {
  /* config options here */
  assetPrefix: GH_SHA ? `/${GH_SHA}/` : undefined,
  generateBuildId: () => GH_SHA || "local",
  reactStrictMode: true,
  output: "standalone",
};

export default nextConfig;
