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
    // Proxy removed for distributed deployment
    // Frontend will make direct API calls to backend server
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
