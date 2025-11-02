#!/bin/bash

# Deployment Verification Script
# Run this after GitHub Actions deployment completes

echo "🔍 Verifying Deployment..."
echo ""

# Production URL
PROD_URL="https://calcium-ratio-472014-r9.web.app"
BACKEND_URL="https://synapse-backend-80902795823.asia-south2.run.app"

echo "📍 Production URL: $PROD_URL"
echo "🔗 Backend API: $BACKEND_URL"
echo ""

# Check if site is accessible
echo "1️⃣ Checking if site is live..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $PROD_URL)
if [ $HTTP_CODE -eq 200 ]; then
    echo "   ✅ Site is accessible (HTTP $HTTP_CODE)"
else
    echo "   ❌ Site returned HTTP $HTTP_CODE"
fi
echo ""

# Check backend API
echo "2️⃣ Checking backend API..."
BACKEND_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BACKEND_URL)
if [ $BACKEND_CODE -eq 200 ] || [ $BACKEND_CODE -eq 404 ]; then
    echo "   ✅ Backend API is accessible (HTTP $BACKEND_CODE)"
else
    echo "   ❌ Backend API returned HTTP $BACKEND_CODE"
fi
echo ""

# Check if JavaScript is loading (basic check)
echo "3️⃣ Checking if app assets load..."
curl -s $PROD_URL | grep -q "flutter" && echo "   ✅ Flutter app detected" || echo "   ⚠️ Flutter app not detected in HTML"
echo ""

echo "✨ Manual Verification Steps:"
echo "   1. Open $PROD_URL in browser"
echo "   2. Open DevTools Console (F12)"
echo "   3. Check for errors"
echo "   4. Test user flow:"
echo "      - Plan a trip"
echo "      - Generate itinerary"
echo "      - Click 'Smart Adjust'"
echo "      - Enter request and submit"
echo "      - Verify itinerary updates"
echo ""

echo "🔧 If issues found:"
echo "   - Check browser console for errors"
echo "   - Verify environment variables in GitHub Secrets"
echo "   - Check GitHub Actions logs"
echo "   - Ensure BACKEND_API_URL is set correctly"
echo ""

echo "📚 Documentation:"
echo "   - PRODUCTION_READINESS.md"
echo "   - DEPLOYMENT_GUIDE.md"
echo "   - QUICK_DEPLOY.md"
