import { createMDX } from 'fumadocs-mdx/next';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const withMDX = createMDX();

/** @type {import('next').NextConfig} */
const config = {
  reactStrictMode: true,
  outputFileTracingRoot: __dirname,
  typedRoutes: false,
  webpack: (config, { isServer }) => {
    // Explicitly handle @ path alias for Amplify compatibility
    config.resolve.alias = {
      ...config.resolve.alias,
      '@': resolve(__dirname, 'src'),
    };
    return config;
  },
  // async redirects() {
  //   return [
  //     { source: '/docs/Tools-&-APIs/:path*', destination: '/docs/tools-apis/:path*', permanent: true },
  //     { source: '/docs/Quick-Start/:path*', destination: '/docs/Quick-Start/:path*', permanent: true },
  //     { source: '/docs/Setup-Infrastructure/:path*', destination: '/docs/setup-infrastructure/:path*', permanent: true },
  //     { source: '/docs/DeFi-Applications/:path*', destination: '/docs/defi-applications/:path*', permanent: true },
  //     { source: '/docs/Core-Concepts/:path*', destination: '/docs/core-concepts/:path*', permanent: true },
  //     { source: '/docs/Help-Resources/:path*', destination: '/docs/help-resources/:path*', permanent: true },
  //   ];
  // },
};

export default withMDX(config);
