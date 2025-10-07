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
  async redirects() {
    return [
      { source: '/', destination: '/docs', permanent: true },
      // Normalize legacy/mixed-case doc section paths to lowercase
      { source: '/docs/Quick-Start/:path*', destination: '/docs/quick-start/:path*', permanent: true },
      { source: '/docs/Setup-Infrastructure/:path*', destination: '/docs/setup-infrastructure/:path*', permanent: true },
      { source: '/docs/Core-Concepts/:path*', destination: '/docs/core-concepts/:path*', permanent: true },
      { source: '/docs/DeFi-Applications/:path*', destination: '/docs/defi-applications/:path*', permanent: true },
      { source: '/docs/Help-Resources/:path*', destination: '/docs/help-resources/:path*', permanent: true },
      // Handle space-containing directory name in old links
      { source: '/docs/APIs and Tools/:path*', destination: '/docs/tools-apis/:path*', permanent: true },
      { source: '/docs/APIs%20and%20Tools/:path*', destination: '/docs/tools-apis/:path*', permanent: true },
    ];
  },
  webpack: (config, { isServer }) => {
    // Explicitly handle @ path aliases for Amplify compatibility
    config.resolve.alias = {
      ...config.resolve.alias,
      '@': resolve(__dirname, 'src'),
      '@/.source': resolve(__dirname, '.source'),
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
