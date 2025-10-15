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
  webpack: (webpackConfig) => {
    // Ensure TS path alias '@/*' resolves in webpack builds (e.g., on Amplify)
    webpackConfig.resolve = webpackConfig.resolve || {};
    webpackConfig.resolve.alias = {
      ...(webpackConfig.resolve.alias || {}),
      '@': resolve(__dirname, 'src'),
    };
    return webpackConfig;
  },
};

export default withMDX(config);
