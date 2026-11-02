import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  // Every route in this app is per-user/auth-gated (time entry, CRM, etc.)
  // so there's nothing worth statically prerendering — keep it simple.
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
