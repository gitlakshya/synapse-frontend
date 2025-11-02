# EaseMyTrip AI Planner

Flutter web application for AI-powered trip planning with Firebase authentication and Gemini AI integration.

## Environment Configuration

### Required API Keys

This project uses `--dart-define` for secure environment variable management. Never commit API keys to the repository.

**Required Variables:**
- `FIREBASE_API_KEY` - Firebase Web API Key
- `FIREBASE_APP_ID` - Firebase App ID
- `FIREBASE_MESSAGING_SENDER_ID` - Firebase Messaging Sender ID
- `FIREBASE_PROJECT_ID` - Firebase Project ID
- `GOOGLE_SIGNIN_CLIENT_ID` - Google OAuth Client ID (with .apps.googleusercontent.com)
- `GOOGLE_MAPS_API_KEY` - Google Maps JavaScript API Key
- `OPENWEATHER_API_KEY` - OpenWeatherMap API Key
- `GEMINI_API_KEY` - Google Gemini API Key

### Local Development Setup

**Option 1: Command Line (Single Run)**
```bash
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=your_firebase_key \
  --dart-define=FIREBASE_APP_ID=your_app_id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=GOOGLE_SIGNIN_CLIENT_ID=your_client_id.apps.googleusercontent.com \
  --dart-define=GOOGLE_MAPS_API_KEY=your_maps_key \
  --dart-define=OPENWEATHER_API_KEY=your_weather_key \
  --dart-define=GEMINI_API_KEY=your_gemini_key
```

**Option 2: VS Code Launch Configuration**

Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Web (Chrome)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=FIREBASE_API_KEY=your_firebase_key",
        "--dart-define=FIREBASE_APP_ID=your_app_id",
        "--dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id",
        "--dart-define=FIREBASE_PROJECT_ID=your_project_id",
        "--dart-define=GOOGLE_SIGNIN_CLIENT_ID=your_client_id.apps.googleusercontent.com",
        "--dart-define=GOOGLE_MAPS_API_KEY=your_maps_key",
        "--dart-define=OPENWEATHER_API_KEY=your_weather_key",
        "--dart-define=GEMINI_API_KEY=your_gemini_key"
      ]
    }
  ]
}
```

**Option 3: Environment File (Recommended)**

Create `env.sh` (add to .gitignore):
```bash
#!/bin/bash
export DART_DEFINES="\
FIREBASE_API_KEY=your_firebase_key,\
FIREBASE_APP_ID=your_app_id,\
FIREBASE_MESSAGING_SENDER_ID=your_sender_id,\
FIREBASE_PROJECT_ID=your_project_id,\
GOOGLE_SIGNIN_CLIENT_ID=your_client_id.apps.googleusercontent.com,\
GOOGLE_MAPS_API_KEY=your_maps_key,\
OPENWEATHER_API_KEY=your_weather_key,\
GEMINI_API_KEY=your_gemini_key"
```

Run with:
```bash
source env.sh
flutter run -d chrome $(echo $DART_DEFINES | sed 's/,/ --dart-define=/g' | sed 's/^/--dart-define=/')
```

### Production Build

```bash
flutter build web --release \
  --dart-define=FIREBASE_API_KEY=prod_firebase_key \
  --dart-define=FIREBASE_APP_ID=prod_app_id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=prod_sender_id \
  --dart-define=FIREBASE_PROJECT_ID=prod_project_id \
  --dart-define=GOOGLE_SIGNIN_CLIENT_ID=prod_client_id.apps.googleusercontent.com \
  --dart-define=GOOGLE_MAPS_API_KEY=prod_maps_key \
  --dart-define=OPENWEATHER_API_KEY=prod_weather_key \
  --dart-define=GEMINI_API_KEY=prod_gemini_key
```

## Hosting Configuration

### Firebase Hosting

1. **Build with environment variables** (see above)
2. **Deploy:**
   ```bash
   firebase deploy --only hosting
   ```
3. **CI/CD (GitHub Actions):**
   - Store secrets in GitHub Secrets (Settings → Secrets → Actions)
   - Add secrets: `FIREBASE_API_KEY`, `GEMINI_API_KEY`, etc.
   - Use in workflow:
   ```yaml
   - name: Build Flutter Web
     run: |
       flutter build web --release \
         --dart-define=FIREBASE_API_KEY=${{ secrets.FIREBASE_API_KEY }} \
         --dart-define=GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }}
   ```

### AWS Amplify

1. **Connect repository** to AWS Amplify
2. **Add environment variables** in Amplify Console:
   - App Settings → Environment Variables
   - Add each variable: `FIREBASE_API_KEY`, `GEMINI_API_KEY`, etc.
3. **Update build settings** (`amplify.yml`):
   ```yaml
   version: 1
   frontend:
     phases:
       build:
         commands:
           - flutter build web --release \
               --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY \
               --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
     artifacts:
       baseDirectory: build/web
       files:
         - '**/*'
   ```

### Vercel

1. **Add environment variables** in Vercel Dashboard:
   - Project Settings → Environment Variables
   - Add each variable with appropriate scope (Production/Preview/Development)
2. **Build command:**
   ```bash
   flutter build web --release --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY
   ```

## Security Best Practices

### Browser-Exposed Keys (Google Maps, Google Sign-In)

⚠️ **WARNING:** Keys in `web/index.html` are visible to users. Apply these restrictions:

**Google Maps API Key:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Edit API Key → Application Restrictions:
   - Select "HTTP referrers"
   - Add your domains: `yourdomain.com/*`, `*.yourdomain.com/*`
3. API Restrictions:
   - Select "Restrict key"
   - Enable only: Maps JavaScript API
4. **RECOMMENDED:** Use a lightweight proxy endpoint to hide the key:
   ```javascript
   // Instead of direct API calls, proxy through your backend
   fetch('https://your-backend.com/api/maps-proxy?address=...')
   ```

**Google Sign-In Client ID:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Edit OAuth 2.0 Client ID:
   - Authorized JavaScript origins: `https://yourdomain.com`
   - Authorized redirect URIs: `https://yourdomain.com/__/auth/handler`

### Backend-Only Keys (Gemini, OpenWeather)

✅ These keys are compiled into the app and not directly visible in browser:
- `GEMINI_API_KEY`
- `OPENWEATHER_API_KEY`
- `FIREBASE_API_KEY` (safe with Firebase security rules)

**Additional Security:**
1. Enable Firebase Security Rules for Firestore/Storage
2. Set up API key rotation schedule (quarterly recommended)
3. Monitor API usage in respective consoles
4. Use short-lifetime keys for development

## Getting API Keys

- **Firebase:** [Firebase Console](https://console.firebase.google.com/) → Project Settings → General
- **Google Sign-In:** [Google Cloud Console](https://console.cloud.google.com/apis/credentials) → Create OAuth 2.0 Client ID
- **Google Maps:** [Google Cloud Console](https://console.cloud.google.com/apis/credentials) → Create API Key
  - 📍 **Quick Start:** See [MAPS_QUICK_START.md](MAPS_QUICK_START.md) for Google Maps setup
  - 📚 **Full Docs:** See [GOOGLE_MAPS_INTEGRATION.md](GOOGLE_MAPS_INTEGRATION.md) for complete integration guide
- **OpenWeatherMap:** [OpenWeatherMap](https://openweathermap.org/api) → Sign up → API Keys
- **Gemini:** [Google AI Studio](https://makersuite.google.com/app/apikey) → Get API Key

## Features

### ✨ Core Features
- 🤖 **AI-Powered Trip Planning** with Gemini AI
- 🗺️ **Interactive Google Maps** with activity markers and click interactions
- 🔍 **Smart City Search** with Google Places Autocomplete (city-level only)
- 🔐 **Firebase Authentication** with Google Sign-In
- 🌓 **Dark/Light Mode** with smooth transitions
- 🌍 **Multi-language Support** (English, Hindi, Spanish, French, German, Japanese)
- 📱 **Fully Responsive** design for mobile, tablet, and desktop
- 💬 **AI Chat Assistant** for trip recommendations
- 🌤️ **Weather Integration** with OpenWeatherMap
- 📊 **Budget Breakdown** with visual cost analysis
- 🎨 **Modern UI** with EaseMyTrip brand colors

### 🗺️ Google Maps Integration

The itinerary results page includes an interactive Google Maps widget:
- **Activity Markers**: Blue pins for all activities, red for highlighted
- **Click Interactions**: Click activity cards to highlight markers, click markers to highlight cards
- **Fullscreen Modal**: Expandable map view with "🗺 Expand Map" button
- **Dark Mode Support**: Automatic dark map style
- **Responsive Layout**: Side-by-side on desktop, collapsible on mobile
- **Error Handling**: Graceful fallback with "Map unavailable" message

**Quick Setup:** See [MAPS_QUICK_START.md](MAPS_QUICK_START.md)  
**Full Documentation:** See [GOOGLE_MAPS_INTEGRATION.md](GOOGLE_MAPS_INTEGRATION.md)

## Development

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run -d chrome --dart-define=...

# Run in release mode
flutter run -d chrome --release --dart-define=...

# Build for production
flutter build web --release --dart-define=...
```

## Lighthouse Performance Checklist

### Target Metrics
- **Performance:** 90+ (First Contentful Paint < 1.8s, Speed Index < 3.4s)
- **Accessibility:** 95+ (WCAG AA compliance)
- **Best Practices:** 90+
- **SEO:** 90+

### Accessibility (Target: 95+)
- ✅ All images have semantic labels or alt text
- ✅ Buttons have ARIA labels and semantic markup
- ✅ Color contrast ratios meet WCAG AA (4.5:1 for text, 3:1 for UI)
- ✅ Keyboard navigation with Tab/Arrow keys
- ✅ Focus indicators visible on all interactive elements
- ✅ Touch targets minimum 48x48dp
- ✅ Screen reader compatible with Semantics widgets

### Performance (Target: 90+)
- ✅ Deferred imports for large screens (booking, AI result)
- ✅ Image lazy loading with loadingBuilder
- ✅ Cached network images with thumbnails
- ✅ Code splitting with deferred imports (40% bundle reduction)
- ✅ HTTP caching with TTL (weather 10min, maps 24hr)
- ✅ Const constructors throughout
- ✅ ListView.builder for long lists
- ✅ Centralized image caching with lib/utils/image_helper.dart
- ⚠️ Consider: Service Worker for offline support
- ⚠️ Consider: WebP images for better compression

### Image Optimization

**Recommended Image Sizes:**
- **Thumbnails (lists)**: 80x80 to 120x120 pixels
- **Cards**: 300x200 to 600x400 pixels
- **Hero images**: 1200x600 to 1920x1080 pixels
- **Format**: WebP preferred, JPEG fallback
- **Quality**: 80-85% for photos, 90%+ for graphics

**Image Caching Strategy:**
```dart
// Use centralized helper from lib/utils/image_helper.dart
import '../utils/image_helper.dart';

// For list thumbnails (80x80)
cachedThumbnail(imageUrl, size: 80)

// For custom sizes
cachedImage(imageUrl, width: 300, height: 200, fit: BoxFit.cover)

// For full-width hero images
cachedHeroImage(imageUrl, height: 400)
```

**Memory Cache Optimization:**
- Thumbnails: 2x resolution cached (160x160 for 80x80 display)
- Disk cache: 3x resolution max (240x240 for 80x80 display)
- Hero images: Max 1200px width cached
- Automatic memory management by cached_network_image

**CDN Recommendations:**
- Use Unsplash with size parameters: `?w=800&h=600&fit=crop`
- Use Cloudinary transformations: `/w_800,h_600,c_fill/`
- Use imgix with auto-format: `?auto=format,compress&w=800`

### Best Practices (Target: 90+)
- ✅ HTTPS required for production
- ✅ No console errors in production build
- ✅ Error boundaries with try-catch
- ✅ Fallback images on network errors
- ✅ Loading states for async operations
- ✅ API keys secured with --dart-define

### SEO (Target: 90+)
- ⚠️ Add meta description in web/index.html
- ⚠️ Add Open Graph tags for social sharing
- ⚠️ Add structured data (JSON-LD) for rich snippets
- ⚠️ Ensure proper heading hierarchy (h1 → h2 → h3)
- ⚠️ Add robots.txt and sitemap.xml

### Testing Commands
```bash
# Run Lighthouse audit
lighthouse https://your-domain.com --view

# Or use Chrome DevTools
# 1. Open DevTools (F12)
# 2. Go to Lighthouse tab
# 3. Generate report
```

## Image Asset Guidelines

### Using the Image Helper

All images should use the centralized `image_helper.dart` utility:

```dart
import '../utils/image_helper.dart';

// List thumbnails (optimized for 80x80)
ListTile(
  leading: cachedThumbnail(hotel.imageUrl),
)

// Custom sized images
Container(
  child: cachedImage(
    imageUrl,
    width: 300,
    height: 200,
    fit: BoxFit.cover,
  ),
)

// Full-width hero images
cachedHeroImage(
  imageUrl,
  height: 500,
)
```

### Benefits
- ✅ Automatic memory and disk caching
- ✅ Optimized cache sizes (2x memory, 3x disk)
- ✅ Consistent loading placeholders
- ✅ Graceful error handling
- ✅ Theme-aware placeholder colors
- ✅ Reduced bandwidth usage

### Image URL Best Practices

**Use CDN parameters for optimization:**
```dart
// Unsplash
'https://images.unsplash.com/photo-id?w=800&h=600&fit=crop&q=80'

// Cloudinary
'https://res.cloudinary.com/demo/image/upload/w_800,h_600,c_fill,q_auto/sample.jpg'

// imgix
'https://demo.imgix.net/image.jpg?auto=format,compress&w=800&h=600'
```

**Avoid:**
- ❌ Full-resolution images (>2MB)
- ❌ Unoptimized formats (BMP, TIFF)
- ❌ Direct Image.network() calls
- ❌ Missing error handlers
