import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path';

const SRC_DIR = path.resolve(__dirname, './src');
const PUBLIC_DIR = path.resolve(__dirname, './public');
const BUILD_DIR = path.resolve(__dirname, './html',);
const BASE_DIR = '/zhihu_web/';

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue({ template: { compilerOptions: { isCustomElement: (tag) => tag.includes('swiper-') } } }),
  ],
  root: SRC_DIR,
  base: BASE_DIR,
  publicDir: PUBLIC_DIR,
  build: {
    outDir: BUILD_DIR,
    assetsInlineLimit: 0,
    emptyOutDir: true,
    rollupOptions: {
      treeshake: false,
    },
  },
  resolve: {
    alias: {
      '@': SRC_DIR,
    },
  },
  server: {
    host: true,
    proxy: {
      '^/zhihu_web/proxy/api': {
        target: 'https://api.zhihu.com',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/zhihu_web\/proxy\/api/, ''),
        configure: (proxy, options) => {
          proxy.on('proxyReq', (proxyReq, req, res) => {
            // Forward custom headers as real headers
            const proxyCookie = req.headers['x-proxy-cookie'];
            if (proxyCookie) {
              proxyReq.setHeader('Cookie', proxyCookie);
            }
            const proxyUA = req.headers['x-proxy-user-agent'];
            if (proxyUA) {
              proxyReq.setHeader('User-Agent', proxyUA);
            }
            const proxyReferer = req.headers['x-proxy-referer'];
             if(proxyReferer) {
                proxyReq.setHeader('Referer', proxyReferer);
             } else {
                proxyReq.setHeader('Referer', 'https://www.zhihu.com/');
             }
             const proxyOrigin = req.headers['x-proxy-origin'];
             if(proxyOrigin) {
                 proxyReq.setHeader('Origin', proxyOrigin);
             } else {
                 proxyReq.setHeader('Origin', 'https://www.zhihu.com');
             }
             // Ensure Host is correct (changeOrigin handles this mostly but sometimes...)
             // proxyReq.setHeader('Host', 'api.zhihu.com');
          });
        }
      },
      '^/zhihu_web/proxy/www': {
          target: 'https://www.zhihu.com',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/zhihu_web\/proxy\/www/, ''),
          configure: (proxy, options) => {
            proxy.on('proxyReq', (proxyReq, req, res) => {
              if (req.headers['x-proxy-cookie']) proxyReq.setHeader('Cookie', req.headers['x-proxy-cookie']);
              if (req.headers['x-proxy-user-agent']) proxyReq.setHeader('User-Agent', req.headers['x-proxy-user-agent']);
               proxyReq.setHeader('Referer', 'https://www.zhihu.com/');
               proxyReq.setHeader('Origin', 'https://www.zhihu.com');
            });
          }
      }
    }
  },

})