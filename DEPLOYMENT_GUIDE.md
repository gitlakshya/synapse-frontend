# 🚀 Quick Deployment Guide

## Prerequisites
- Flutter 3.9.2+ installed
- All environment variables configured
- Backend API accessible
- Firebase project set up (optional, for auth)

## Step 1: Environment Configuration

### Create Environment File (Linux/Mac)
```bash
cp .env.example env.sh
# Edit env.sh with your actual values
chmod +x env.sh
```

### Create Environment File (Windows)
```powershell
Copy-Item .env.example env.sh
# Edit env.sh with your actual values
```

### Required Environment Variables
```bash
# Backend API
BACKEND_API_URL=https://synapse-backend-80902795823.asia-south2.run.app

# Google Services
GOOGLE_MAPS_API_KEY=your_google_maps_key
GOOGLE_SIGNIN_CLIENT_ID=your_client_id.apps.googleusercontent.com

# Firebase (Optional)
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id

# Third-Party APIs (Optional)
OPENWEATHER_API_KEY=your_weather_api_key
```

## Step 2: Install Dependencies
```bash
flutter pub get
```

## Step 3: Build for Production

### Web Deployment
```bash
# Build with environment variables
flutter build web --release \
  --dart-define=BACKEND_API_URL=$BACKEND_API_URL \
  --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY \
  --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY \
  --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
  --web-renderer html

# Output will be in: build/web/
```

### Alternative: Using PowerShell Script
```powershell
# Windows users can use the provided script
.\setup_and_run.ps1
```

## Step 4: Deploy to Hosting

### Option A: Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting
# Select existing project or create new
# Public directory: build/web
# Single-page app: Yes
# Automatic builds: No

# Deploy
firebase deploy --only hosting
```

### Option B: Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
cd build/web
vercel --prod
```

### Option C: Netlify
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
cd build/web
netlify deploy --prod --dir .
```

### Option D: GitHub Pages
```bash
# Build with base href
flutter build web --release --base-href "/your-repo-name/"

# Copy build/web contents to gh-pages branch
# Or use GitHub Actions for automated deployment
```

### Option E: Cloud Run (Google Cloud)
```dockerfile
# Dockerfile
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

```bash
# Build and deploy
docker build -t trip-planner-web .
gcloud run deploy trip-planner --source . --region=asia-south2
```

## Step 5: Verify Deployment

### Health Checks
- [ ] App loads successfully
- [ ] API calls work (check network tab)
- [ ] Authentication flows work
- [ ] Maps display correctly
- [ ] Smart Adjust feature works
- [ ] All images load
- [ ] No console errors
- [ ] Responsive on mobile/tablet/desktop

### Test User Flows
1. **Guest Flow**
   - Open app → Should create guest session
   - Plan trip → Should generate itinerary
   - Smart Adjust → Should modify itinerary
   - Save trip → Should save with guest ID

2. **Authenticated Flow**
   - Sign in with Google
   - Plan trip → Should associate with user
   - View saved trips
   - Edit/delete trips

3. **Error Scenarios**
   - No network → Should show error with retry
   - Invalid input → Should show validation
   - API timeout → Should show timeout message

## Step 6: Monitoring Setup

### Add Google Analytics (Optional)
```dart
// pubspec.yaml
dependencies:
  firebase_analytics: ^latest

// main.dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;
```

### Add Sentry for Error Tracking (Optional)
```dart
// pubspec.yaml
dependencies:
  sentry_flutter: ^latest

// main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

await SentryFlutter.init(
  (options) => options.dsn = 'your-sentry-dsn',
  appRunner: () => runApp(MyApp()),
);
```

## Common Issues & Solutions

### Issue: White screen on load
**Solution**: Check console for errors, verify API URL is correct

### Issue: Maps not showing
**Solution**: Verify GOOGLE_MAPS_API_KEY is set and valid

### Issue: API calls failing
**Solution**: 
- Check CORS configuration on backend
- Verify BACKEND_API_URL is accessible
- Check browser console for network errors

### Issue: Build fails
**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

### Issue: Environment variables not working
**Solution**: Ensure you're passing --dart-define flags during build

## Production Optimization

### 1. Enable Caching
```html
<!-- build/web/index.html -->
<meta http-equiv="Cache-Control" content="max-age=31536000">
```

### 2. Configure CDN
- Upload assets to CDN
- Update asset URLs in build

### 3. Enable Compression
```nginx
# nginx.conf
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
```

### 4. Set Up SSL
- Use Let's Encrypt for free SSL
- Configure HTTPS redirect
- Enable HSTS header

### 5. Add robots.txt
```
User-agent: *
Allow: /
Sitemap: https://yourdomain.com/sitemap.xml
```

## Continuous Deployment (CI/CD)

### GitHub Actions Example
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build web
        run: |
          flutter build web --release \
            --dart-define=BACKEND_API_URL=${{ secrets.BACKEND_API_URL }} \
            --dart-define=GOOGLE_MAPS_API_KEY=${{ secrets.GOOGLE_MAPS_API_KEY }}
      
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: your-project-id
```

## Performance Checklist

### Before Deployment
- [ ] Remove all `print()` statements (or wrap in `kDebugMode`)
- [ ] Optimize images (compress, use WebP)
- [ ] Enable tree shaking
- [ ] Test on slow 3G network
- [ ] Check bundle size (< 2MB initial)
- [ ] Verify lazy loading works
- [ ] Test with ad blockers enabled

### Lighthouse Targets
- Performance: > 90
- Accessibility: > 95
- Best Practices: > 90
- SEO: > 90

## Rollback Plan

### Quick Rollback
```bash
# Firebase Hosting
firebase hosting:rollback

# Vercel
vercel rollback <deployment-url>

# Manual
# Redeploy previous working version
```

## Support & Maintenance

### Regular Tasks
- **Daily**: Monitor error rates, API performance
- **Weekly**: Review analytics, user feedback
- **Monthly**: Security updates, dependency updates
- **Quarterly**: Performance audit, feature planning

### Emergency Response
1. Check monitoring dashboard
2. Review recent deployments
3. Check backend API status
4. Roll back if necessary
5. Fix and redeploy
6. Post-mortem review

## Resources

- **Documentation**: See `PRODUCTION_READINESS.md`
- **API Docs**: See `API_INTEGRATION_SUMMARY.md`
- **Feature Guide**: See `SMART_ADJUST_FEATURE.md`
- **Backend**: https://synapse-backend-80902795823.asia-south2.run.app

## Contact

For issues or questions:
- Create GitHub issue
- Contact backend team
- Check documentation files

---

**Last Updated**: November 2, 2025
**Deployment Status**: Ready for staging deployment
