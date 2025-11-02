# 🚀 GitHub Actions Deployment - Complete Setup

## ✅ Changes Made

### 1. Updated `.github/workflows/deploy.yml`
Added `BACKEND_API_URL` environment variable to ensure deployed app connects to the correct backend:

```yaml
env:
  BACKEND_API_URL: https://synapse-backend-80902795823.asia-south2.run.app
  # ... other vars
run: |
  flutter build web --release \
    --dart-define=BACKEND_API_URL=$BACKEND_API_URL \
    # ... other defines
```

### 2. Updated `lib/config.dart`
Set correct default backend URL:
```dart
static const String backendApiUrl = String.fromEnvironment(
  'BACKEND_API_URL', 
  defaultValue: 'https://synapse-backend-80902795823.asia-south2.run.app'
);
```

### 3. Updated `lib/services/api_middleware.dart`
Backend URL now uses environment variable with fallback.

## 📋 Deployment Checklist

### Before First Deployment
- [x] Backend URL added to workflow
- [x] Config class updated with correct default
- [x] API middleware uses environment variable
- [ ] **GitHub Secrets configured** (if not using defaults)
- [ ] **Firebase Service Account secret added** (required for deployment)

### GitHub Secrets Required
Only needed if overriding defaults:

| Secret Name | Required? | Default Value | Purpose |
|-------------|-----------|---------------|---------|
| `FIREBASE_SERVICE_ACCOUNT_CALCIUM_RATIO_472014_R9` | **YES** | None | Firebase deployment auth |
| `FIREBASE_API_KEY` | No | From Firebase Console | Firebase initialization |
| `FIREBASE_APP_ID` | No | `1:80902795823:web:...` | Firebase app ID |
| `FIREBASE_MESSAGING_SENDER_ID` | No | `80902795823` | FCM sender ID |
| `GOOGLE_CLIENT_ID` | No | `80902795823-0peak8l1...` | Google Sign-In |
| `OPENWEATHER_API_KEY` | No | Empty | Weather service |
| `GEMINI_API_KEY` | No | Empty | AI features |

**Note**: `GOOGLE_MAPS_API_KEY` is hardcoded in workflow (AIzaSyDtOV162bzCWFOsjJHEs5IvRXNr0aebhLQ)

## 🔐 How to Add GitHub Secrets

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each required secret

### Critical: Firebase Service Account
```bash
# Get from Firebase Console:
# Project Settings → Service Accounts → Generate New Private Key
# Copy the JSON content and paste as secret value
```

## 🚀 Deployment Process

### Automatic Deployment
When you push to `main` branch:
```bash
git add .
git commit -m "feat: deploy with Smart Adjust feature"
git push origin main
```

### Manual Deployment
From GitHub:
1. Go to **Actions** tab
2. Select **Deploy to Firebase Hosting**
3. Click **Run workflow**
4. Select `main` branch
5. Click **Run workflow**

## 📊 Deployment Flow

```
Push to main
    ↓
Checkout code
    ↓
Setup Flutter 3.35.3
    ↓
Install dependencies
    ↓
Run analysis (continue on error)
    ↓
Run tests (continue on error)
    ↓
Build web --release
  • With BACKEND_API_URL
  • With Google Maps API Key
  • With Firebase config
    ↓
Deploy to Firebase Hosting
    ↓
Notify success/failure
```

## 🎯 Deployment URL

**Live Site**: https://calcium-ratio-472014-r9.web.app

## ✅ Post-Deployment Verification

### Automated Check
```bash
# Run verification script
chmod +x verify_deployment.sh
./verify_deployment.sh
```

### Manual Testing
1. **Open App**: https://calcium-ratio-472014-r9.web.app
2. **Check Console**: F12 → Console (no errors)
3. **Test Flow**:
   - Plan a trip
   - Generate itinerary
   - Click "Smart Adjust"
   - Enter adjustment request
   - Verify itinerary updates
4. **Check Network**: F12 → Network
   - API calls to `synapse-backend-80902795823.asia-south2.run.app`
   - All return 200/201 (not 422)

### Expected Console Output
```
Creating guest session for API access...
✓ Guest session created
✓ Itinerary generated successfully
✓ Smart adjust completed
```

### Common Issues

#### 1. White Screen
**Symptom**: Blank page, no errors
**Fix**: 
- Check if `index.html` loads
- Verify `main.dart.js` exists in build
- Check Firebase Hosting configuration

#### 2. 422 Errors on Smart Adjust
**Symptom**: Smart Adjust fails with 422
**Fix**: 
- ✅ Already fixed! Request format corrected
- Verify `sessionId` is being sent
- Check console logs for request details

#### 3. Maps Not Loading
**Symptom**: Google Maps shows error
**Fix**:
- Verify API key in workflow: `AIzaSyDtOV162bzCWFOsjJHEs5IvRXNr0aebhLQ`
- Check API key restrictions in Google Cloud Console
- Enable required APIs: Maps JavaScript API, Places API

#### 4. Firebase Deployment Fails
**Symptom**: "Firebase deployment failed" in logs
**Fix**:
- Add `FIREBASE_SERVICE_ACCOUNT_CALCIUM_RATIO_472014_R9` secret
- Verify service account JSON is valid
- Check Firebase project permissions

## 🔧 Environment Variables Reference

### In Workflow (deploy.yml)
```yaml
BACKEND_API_URL: https://synapse-backend-80902795823.asia-south2.run.app
GOOGLE_MAPS_API_KEY: AIzaSyDtOV162bzCWFOsjJHEs5IvRXNr0aebhLQ
FIREBASE_PROJECT_ID: calcium-ratio-472014-r9
# ... others from secrets
```

### In Code (lib/config.dart)
```dart
static const String backendApiUrl = String.fromEnvironment(
  'BACKEND_API_URL',
  defaultValue: 'https://synapse-backend-80902795823.asia-south2.run.app'
);
```

### In API Middleware (lib/services/api_middleware.dart)
```dart
static const String _baseUrl = String.fromEnvironment(
  'BACKEND_API_URL',
  defaultValue: 'https://synapse-backend-80902795823.asia-south2.run.app'
);
```

## 📝 Smart Adjust Feature

### API Format (Fixed)
```json
POST /api/v1/smartadjust
{
  "sessionId": "guest_or_auth_token",
  "itinerary": { /* full itinerary object */ },
  "userRequest": "Add more outdoor activities"
}
```

### Response Format
```json
{
  "success": true,
  "data": {
    "adjustedItinerary": { /* updated itinerary */ },
    "changes": [
      "Added hiking activity on Day 2",
      "Replaced museum with nature walk"
    ]
  }
}
```

## 🚨 Troubleshooting

### Check GitHub Actions Logs
1. Go to **Actions** tab
2. Click on latest workflow run
3. Expand each step to see details
4. Look for errors in "Build Web App" or "Deploy to Firebase"

### Check Firebase Console
1. Go to Firebase Console → Hosting
2. View deployment history
3. Check if latest deployment succeeded
4. Review hosting logs

### Check Browser DevTools
```javascript
// In browser console:
console.log('Backend URL:', /* should show production URL */);
localStorage.getItem('session_id'); // Should have guest session
```

## ✨ Next Steps

1. **Test Deployment**: Once GitHub Actions completes, test the live site
2. **Monitor**: Check Firebase Analytics for usage
3. **Iterate**: Make changes, push to main, auto-deploys
4. **Scale**: Add more features, they'll deploy automatically

## 📚 Additional Resources

- **Main Docs**: `PRODUCTION_READINESS.md`
- **Feature Docs**: `SMART_ADJUST_FEATURE.md`
- **Quick Reference**: `QUICK_DEPLOY.md`
- **Repository Status**: `REPOSITORY_STATUS.md`

---

**Status**: ✅ Deployment workflow configured and ready  
**Backend**: https://synapse-backend-80902795823.asia-south2.run.app  
**Production URL**: https://calcium-ratio-472014-r9.web.app  
**Last Updated**: November 2, 2025
