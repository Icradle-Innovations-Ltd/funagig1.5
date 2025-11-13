#!/bin/bash

# FunaGig Deployment Readiness Script
# This script prepares your application for production deployment

echo "🚀 Preparing FunaGig for Production Deployment..."
echo "================================================="

# Check if we're in the right directory
if [[ ! -f "package.json" ]] || [[ ! -f "php/api.php" ]]; then
    echo "❌ Error: Please run this script from the FunaGig root directory"
    exit 1
fi

echo "✅ Found FunaGig project files"

# Check Node.js and npm
echo "🔍 Checking Node.js and npm..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm not found. Please install npm"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2)
echo "✅ Node.js version: $NODE_VERSION"

# Install dependencies
echo "📦 Installing dependencies..."
npm install
if [[ $? -ne 0 ]]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Build for production
echo "🔨 Building frontend for production..."
npm run build
if [[ $? -ne 0 ]]; then
    echo "❌ Build failed"
    exit 1
fi

# Check if dist directory was created
if [[ ! -d "dist" ]]; then
    echo "❌ Build failed: dist directory not created"
    exit 1
fi

echo "✅ Frontend built successfully to dist/ directory"

# Check environment files
echo "🔧 Checking environment configuration..."
if [[ ! -f ".env.production" ]]; then
    echo "❌ .env.production file not found"
    echo "   Please create it with your production database credentials"
    exit 1
fi

if [[ ! -f ".env.digitalocean" ]]; then
    echo "❌ .env.digitalocean file not found"
    echo "   Please create it with your DigitalOcean database credentials"
    exit 1
fi

echo "✅ Environment files found"

# Check database connection (if mysql client available)
echo "🗄️ Testing database connection..."
if command -v mysql &> /dev/null; then
    # Try to connect to DigitalOcean database
    # Note: Replace with your actual credentials
    # if mysql -u your-db-user -pyour-db-password -h your-db-host -P 25060 -e "SELECT 1;" &> /dev/null; then
    #     echo "✅ DigitalOcean database connection successful"
    # else
    echo "⚠️  Database connection test skipped (replace with your credentials in production)"
    fi
else
    echo "⚠️  mysql client not found, skipping database test"
fi

# Check PHP files
echo "🐘 Checking PHP files..."
if [[ ! -f "php/api.php" ]]; then
    echo "❌ php/api.php not found"
    exit 1
fi

if [[ ! -f "php/config.php" ]]; then
    echo "❌ php/config.php not found"
    exit 1
fi

echo "✅ PHP files found"

# Create deployment summary
echo ""
echo "📋 DEPLOYMENT SUMMARY"
echo "===================="
echo "Frontend:"
echo "  - Built to: dist/ directory"
echo "  - Entry points: $(ls dist/*.html | wc -l) HTML pages"
echo "  - Assets: $(ls dist/assets/*.js dist/assets/*.css 2>/dev/null | wc -l) files"
echo ""
echo "Backend:"
echo "  - PHP API: php/api.php"
echo "  - Configuration: php/config.php" 
echo "  - Environment: .env.production"
echo ""
echo "Database:"
echo "  - Provider: DigitalOcean Managed MySQL"
echo "  - Host: your-database-host.ondigitalocean.com"
echo "  - Port: 25060"
echo ""
echo "🎯 READY FOR DEPLOYMENT!"
echo ""
echo "Next Steps:"
echo "1. Choose your hosting option from HOSTING_GUIDE.md"
echo "2. For DigitalOcean App Platform:"
echo "   a. Push code to GitHub"
echo "   b. Create new App on DigitalOcean"
echo "   c. Connect GitHub repository"
echo "   d. Use app.yaml configuration"
echo ""
echo "3. For Vercel (frontend only):"
echo "   a. Connect GitHub to Vercel"
echo "   b. Deploy automatically"
echo ""
echo "4. For manual VPS deployment:"
echo "   a. Use deploy-droplet.sh script"
echo "   b. Configure domain and SSL"
echo ""
echo "💡 See HOSTING_GUIDE.md for detailed instructions!"