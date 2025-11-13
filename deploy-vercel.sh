#!/bin/bash
# Quick deployment script for Vercel

echo "🚀 Deploying FunaGig to Vercel with Backend API..."

# Add environment variables (replace with your actual values)
echo "Adding environment variables..."
vercel env add DB_HOST
# Enter: your-database-host.ondigitalocean.com

vercel env add DB_PORT  
# Enter: 25060

vercel env add DB_USER
# Enter: your-database-user

vercel env add DB_PASS
# Enter: your-database-password

vercel env add DB_NAME
# Enter: funagig

vercel env add DB_SSL
# Enter: false

vercel env add PRODUCTION_MODE
# Enter: true

vercel env add DEBUG_MODE  
# Enter: false

vercel env add APP_URL
# Enter: https://funagig1-5.vercel.app

vercel env add HTTPS_REQUIRED
# Enter: true

# Deploy
echo "Deploying to production..."
vercel --prod

echo "✅ Deployment complete!"
echo "Frontend: https://funagig1-5.vercel.app"
echo "API: https://funagig1-5.vercel.app/api"