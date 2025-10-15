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
};

export default withMDX(config);
