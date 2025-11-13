import { defineConfig } from 'vite'
import legacy from '@vitejs/plugin-legacy'

export default defineConfig({
  plugins: [
    legacy({
      targets: ['defaults', 'not IE 11']
    })
  ],
  server: {
    port: 3000,
    host: true, // Allow external connections
    proxy: {
      // Proxy API requests to local XAMPP server for proper session cookie handling
      '/api': {
        target: 'http://localhost/funagig1.5/php/api.php',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
        configure: (proxy, _options) => {
          proxy.on('error', (err, _req, _res) => {
            console.log('proxy error', err);
          });
          proxy.on('proxyReq', (proxyReq, req, _res) => {
            console.log('Sending Request to the Target:', req.method, req.url);
          });
          proxy.on('proxyRes', (proxyRes, req, _res) => {
            console.log('Received Response from the Target:', proxyRes.statusCode, req.url);
          });
        }
      }
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: true,
    rollupOptions: {
      input: {
        main: 'index.html',
        auth: 'auth.html',
        signup: 'signup.html',
        'home-gigs': 'home-gigs.html',
        'student-dashboard': 'student-dashboard.html',
        'student-profile': 'student-profile.html',
        'student-messaging': 'student-messaging.html',
        'student-gigs': 'student-gigs.html',
        'business-dashboard': 'business-dashboard.html',
        'business-profile': 'business-profile.html',
        'business-messaging': 'business-messaging.html',
        'business-gigs': 'business-gigs.html',
        'post-gig': 'post-gig.html',
        'forgot-password': 'forgot-password.html',
        'notifications': 'notifications.html'
      }
    }
  },
  css: {
    devSourcemap: true
  }
})
