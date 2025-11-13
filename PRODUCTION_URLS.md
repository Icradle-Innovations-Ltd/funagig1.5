# Vercel Environment Variables for FunaGig Production

## Frontend Configuration
Add this environment variable in your Vercel project settings:

```
VITE_API_BASE_URL=https://plankton-app-3beec.ondigitalocean.app
```

## How to Update:

### Via Vercel Dashboard:
1. Go to https://vercel.com/icradle-innovations-ltds-projects/funagig1-5
2. Click "Settings" → "Environment Variables"
3. Add:
   - **Name**: `VITE_API_BASE_URL`
   - **Value**: `https://plankton-app-3beec.ondigitalocean.app`
   - **Environments**: Production, Preview, Development

### Via Vercel CLI:
```bash
vercel env add VITE_API_BASE_URL
# Enter: https://plankton-app-3beec.ondigitalocean.app
# Select: Production, Preview, Development

# Redeploy to apply changes
vercel --prod
```

## Benefits of This Setup:

✅ **CDN Performance**: Vercel's global CDN for static assets  
✅ **API Performance**: DigitalOcean close to your database  
✅ **Scalability**: Both platforms handle traffic scaling  
✅ **Reliability**: Distributed across two providers  

## Production URLs:

- **Frontend**: https://funagig1-5.vercel.app (using DigitalOcean API)
- **Backend**: https://plankton-app-3beec.ondigitalocean.app
- **Alternative**: https://plankton-app-3beec.ondigitalocean.app (full app)

Your users can access the app from either URL once configured!