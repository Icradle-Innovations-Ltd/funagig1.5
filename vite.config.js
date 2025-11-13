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
      // Proxy API requests to production server to avoid CORS issues in development
      '/api': {
        target: 'https://plankton-app-3beec.ondigitalocean.app',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
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
