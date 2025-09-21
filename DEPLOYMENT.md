# 🚀 Firebase Deployment Guide

This guide provides comprehensive instructions for deploying the Synapse Frontend to Firebase Hosting with automated CI/CD pipeline.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Manual Deployment](#manual-deployment)
4. [Automated Deployment (CI/CD)](#automated-deployment-cicd)
5. [Environment Configuration](#environment-configuration)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

## 🔧 Prerequisites

### Required Software
- **Node.js** (v18 or higher) - [Download](https://nodejs.org/)
- **Flutter** (v3.24.3 or higher) - [Install Guide](https://flutter.dev/docs/get-started/install)
- **Git** - [Download](https://git-scm.com/)
- **Firebase CLI** - Installed automatically by setup script

### Required Accounts
- **Firebase Account** with access to project `calcium-ratio-472014-r9`
- **GitHub Account** with repository access
- **Google Cloud Platform** account (for backend services)

## 🏗️ Initial Setup

### 1. Run Setup Script

**Windows:**
```cmd
setup.bat
```

**Linux/macOS:**
```bash
chmod +x setup.sh
./setup.sh
```

### 2. Firebase Authentication

```bash
# Login to Firebase
firebase login

# Verify project access
firebase projects:list

# Set default project
firebase use calcium-ratio-472014-r9
```

### 3. Verify Flutter Installation

```bash
flutter doctor
flutter pub get
```

## 🚀 Manual Deployment

### Quick Deployment

**Windows:**
```cmd
deploy.bat
```

**Linux/macOS:**
```bash
chmod +x deploy.sh
./deploy.sh
```

### Step-by-Step Manual Process

1. **Clean Previous Builds**
   ```bash
   flutter clean
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run Code Analysis** (Optional)
   ```bash
   flutter analyze --fatal-infos
   ```

4. **Run Tests** (Optional)
   ```bash
   flutter test
   ```

5. **Build for Production**
   ```bash
   flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true
   ```

6. **Deploy to Firebase**
   ```bash
   firebase deploy --only hosting --project calcium-ratio-472014-r9
   ```

## 🔄 Automated Deployment (CI/CD)

### GitHub Actions Setup

The repository includes a GitHub Actions workflow (`.github/workflows/firebase-deploy.yml`) that automatically deploys on every push to the `main` branch.

### Required Secrets

Add the following secret to your GitHub repository:

1. Go to: `https://github.com/gitlakshya/synapse-frontend/settings/secrets/actions`
2. Click "New repository secret"
3. Name: `FIREBASE_TOKEN`
4. Value: Generate using `firebase login:ci`

### Workflow Features

- ✅ Automatic Flutter setup
- ✅ Dependency installation
- ✅ Code analysis and testing
- ✅ Production build
- ✅ Firebase deployment
- ✅ Deployment status comments on PRs

### Triggering Deployment

```bash
git add .
git commit -m "Deploy to production"
git push origin main
```

## ⚙️ Environment Configuration

### Firebase Configuration

Current project settings in `lib/config/app_config.dart`:

```dart
static const String firebaseProjectId = "calcium-ratio-472014-r9";
static const String firebaseAppId = "1:80902795823:web:07e68e2ea360ad68b0ccda";
static const String firebaseAuthDomain = "calcium-ratio-472014-r9.firebaseapp.com";
```

### Build Configuration

The deployment uses these optimized settings:

- **Web Renderer**: CanvasKit (for better performance)
- **Skia Support**: Enabled for advanced graphics
- **Tree Shaking**: Enabled (reduces bundle size)
- **Minification**: Enabled
- **Source Maps**: Generated for debugging

### Backend Integration

- **Production Backend**: `https://synapse-backend-80902795823.asia-south2.run.app`
- **API Version**: v1
- **Authentication**: Firebase Auth with JWT tokens

## 🔍 Troubleshooting

### Common Issues

#### 1. Build Failures

**Issue**: Flutter build fails
```bash
# Solution: Clean and retry
flutter clean
flutter pub get
flutter build web --release
```

#### 2. Firebase Authentication Issues

**Issue**: "Permission denied" during deployment
```bash
# Solution: Re-authenticate
firebase logout
firebase login
firebase projects:list
```

#### 3. Missing Dependencies

**Issue**: Package resolution errors
```bash
# Solution: Update dependencies
flutter pub get
flutter pub upgrade
```

#### 4. GitHub Actions Failures

**Issue**: CI/CD pipeline fails
- Check `FIREBASE_TOKEN` secret is correctly set
- Verify Flutter version compatibility
- Check for any breaking changes in dependencies

### Deployment Verification

After deployment, verify:

1. **App loads**: Visit `https://calcium-ratio-472014-r9.web.app`
2. **Authentication works**: Test login/logout
3. **API connectivity**: Test chat and trip planning features
4. **Performance**: Check loading times and responsiveness

### Logs and Monitoring

- **Firebase Console**: `https://console.firebase.google.com/project/calcium-ratio-472014-r9`
- **GitHub Actions**: Repository → Actions tab
- **Browser DevTools**: F12 → Console for client-side errors

## 📈 Best Practices

### Pre-Deployment Checklist

- [ ] Code reviewed and tested
- [ ] Dependencies updated and secure
- [ ] Environment variables configured
- [ ] Firebase configuration verified
- [ ] Performance tested on different devices
- [ ] SEO meta tags updated
- [ ] Error handling implemented

### Performance Optimization

1. **Enable Caching**
   - Static assets cached for 1 year
   - HTML files cached with revalidation

2. **Bundle Optimization**
   - Tree shaking enabled
   - Minification enabled
   - Source maps for debugging

3. **Security Headers**
   - X-Frame-Options: DENY
   - X-Content-Type-Options: nosniff
   - Referrer-Policy: strict-origin-when-cross-origin

### Monitoring and Maintenance

1. **Regular Updates**
   - Update Flutter SDK monthly
   - Update dependencies quarterly
   - Security patches immediately

2. **Performance Monitoring**
   - Use Firebase Performance Monitoring
   - Monitor Core Web Vitals
   - Track user engagement metrics

3. **Error Tracking**
   - Implement error reporting
   - Monitor deployment success rates
   - Set up alerts for critical issues

## 🌐 Deployment URLs

### Production
- **Primary**: `https://calcium-ratio-472014-r9.web.app`
- **Alternative**: `https://calcium-ratio-472014-r9.firebaseapp.com`

### Management
- **Firebase Console**: `https://console.firebase.google.com/project/calcium-ratio-472014-r9`
- **GitHub Repository**: `https://github.com/gitlakshya/synapse-frontend`

## 📞 Support

For deployment issues:

1. Check this documentation
2. Review GitHub Actions logs
3. Check Firebase Console
4. Contact the development team

---

**Last Updated**: September 2025  
**Version**: 1.0.0  
**Maintained by**: Synapse Development Team