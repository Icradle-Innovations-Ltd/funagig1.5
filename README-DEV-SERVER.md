# FunaGig Frontend Development Server

## Overview
This setup provides a modern frontend development environment for FunaGig using Vite as the development server. It includes hot reloading, modern JavaScript features, and seamless integration with your existing PHP backend.

## Prerequisites
- Node.js (v16 or higher) - Download from [nodejs.org](https://nodejs.org/)
- XAMPP (for PHP backend) - Download from [apachefriends.org](https://www.apachefriends.org/)
- Modern web browser

## Quick Start

### Option 1: Using the Development Scripts (Recommended)

#### Windows:
```bash
start-dev.bat
```

#### Linux/macOS:
```bash
./start-dev.sh
```

### Option 2: Manual Setup

1. **Install Dependencies:**
   ```bash
   npm install
   ```

2. **Start Development Server:**
   ```bash
   npm run dev
   ```

3. **Access the Application:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080/php/api.php

## Development Server Features

### Hot Reloading
- Automatic page refresh when files change
- Preserves application state during development
- Fast rebuild times

### Modern JavaScript Support
- ES6+ features with automatic transpilation
- Module system support
- Async/await and modern syntax

### API Proxy
- Automatic proxy to PHP backend
- CORS handling
- Seamless API integration

### Build Optimization
- Code splitting
- Asset optimization
- Source maps for debugging

## Available Scripts

### Development
```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build
npm run serve        # Serve production build
```

### Development Server Options
```bash
npm run dev -- --port 4000    # Custom port
npm run dev -- --host         # Allow external access
npm run dev -- --open         # Auto-open browser
```

## Project Structure

```
funagig/
├── package.json              # Node.js dependencies
├── vite.config.js            # Vite configuration
├── dev-server.js             # Custom development server
├── start-dev.bat             # Windows startup script
├── start-dev.sh              # Linux/macOS startup script
├── dist/                     # Production build output
├── node_modules/             # Dependencies
├── css/                      # Your existing CSS
├── js/                       # Your existing JavaScript
├── php/                      # Your existing PHP backend
└── *.html                    # Your existing HTML files
```

## Configuration

### Vite Configuration (`vite.config.js`)
- **Port**: 3000 (frontend), 8080 (backend proxy)
- **Proxy**: Automatic PHP API proxy
- **Build**: Optimized production builds
- **Legacy**: Browser compatibility support

### Development Server Features
- **XAMPP Detection**: Automatically checks if XAMPP is running
- **Dependency Management**: Auto-installs npm packages
- **Error Handling**: Clear error messages and troubleshooting
- **Process Management**: Proper cleanup on exit

## Integration with Existing Code

### No Changes Required
Your existing HTML, CSS, and JavaScript files work without modification. The development server serves them directly.

### Enhanced Development
- **Live Reload**: See changes instantly
- **Error Overlay**: Clear error messages in browser
- **Source Maps**: Debug original source code
- **Hot Module Replacement**: Preserve state during development

### API Integration
```javascript
// Your existing API calls work unchanged
fetch('/php/api.php/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password })
})
```

## Troubleshooting

### Common Issues

#### "Node.js is not installed"
- Download and install Node.js from [nodejs.org](https://nodejs.org/)
- Restart your terminal/command prompt

#### "XAMPP is not running"
- Start XAMPP Control Panel
- Start Apache service
- Ensure Apache is running on port 8080

#### "Port 3000 is already in use"
```bash
npm run dev -- --port 4000
```

#### "Cannot find module"
```bash
npm install
```

### Debug Mode
Enable debug logging:
```bash
DEBUG=vite:* npm run dev
```

### Network Issues
If you can't access the development server:
1. Check firewall settings
2. Try `npm run dev -- --host` for external access
3. Verify port availability

## Production Deployment

### Build for Production
```bash
npm run build
```

### Serve Production Build
```bash
npm run serve
```

### Deploy to Web Server
1. Run `npm run build`
2. Copy `dist/` folder to your web server
3. Configure web server to serve static files

## Development Workflow

### 1. Start Development Environment
```bash
# Windows
start-dev.bat

# Linux/macOS
./start-dev.sh
```

### 2. Make Changes
- Edit HTML, CSS, or JavaScript files
- Changes appear instantly in browser
- Use browser dev tools for debugging

### 3. Test API Integration
- Ensure XAMPP is running
- API calls are automatically proxied
- Check browser network tab for requests

### 4. Build for Production
```bash
npm run build
```

## Advanced Configuration

### Custom Vite Configuration
Edit `vite.config.js` to customize:
- Build options
- Proxy settings
- Plugin configuration
- Asset handling

### Environment Variables
Create `.env` file for environment-specific settings:
```
VITE_API_URL=http://localhost:8080/php
VITE_APP_NAME=FunaGig
```

### Multiple Entry Points
The configuration supports multiple HTML files as entry points:
- `index.html` - Landing page
- `auth.html` - Authentication
- `student-dashboard.html` - Student dashboard
- `business-dashboard.html` - Business dashboard
- And more...

## Performance Benefits

### Development
- **Fast Startup**: Quick server startup
- **Hot Reload**: Instant feedback
- **Source Maps**: Easy debugging
- **Error Overlay**: Clear error messages

### Production
- **Code Splitting**: Optimized loading
- **Asset Optimization**: Minified and compressed
- **Tree Shaking**: Remove unused code
- **Modern Bundling**: Efficient module system

## Next Steps

1. **Start Development**: Run `start-dev.bat` or `./start-dev.sh`
2. **Explore Features**: Try hot reloading and modern JavaScript
3. **Customize**: Modify `vite.config.js` as needed
4. **Deploy**: Use `npm run build` for production

## Support

### Getting Help
- Check browser console for errors
- Review Vite documentation: [vitejs.dev](https://vitejs.dev/)
- Check Node.js documentation: [nodejs.org](https://nodejs.org/)

### Development Tips
- Use browser dev tools for debugging
- Check network tab for API calls
- Use console for JavaScript debugging
- Enable source maps for better debugging

### Performance Tips
- Use `npm run build` for production
- Optimize images and assets
- Enable gzip compression on server
- Use CDN for static assets
