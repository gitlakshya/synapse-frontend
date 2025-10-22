# Configuration Setup

## Overview

This project uses a template-based configuration system to keep sensitive API keys and configuration out of version control while maintaining ease of development.

## Files

- **`app_config.template.dart`**: Template file (committed to git)
- **`app_config.dart`**: Generated config file (ignored by git)

## Local Development

### First Time Setup

1. Copy the template to create your local config:
   ```bash
   cp lib/config/app_config.template.dart lib/config/app_config.dart
   ```

2. Replace the placeholders in `lib/config/app_config.dart` with actual values:
   - `{{ENVIRONMENT}}` → `development` or `production`
   - `{{BACKEND_URL}}` → Your backend URL
   - `{{FIREBASE_PROJECT_ID}}` → Firebase project ID
   - `{{FIREBASE_APP_ID}}` → Firebase app ID
   - `{{FIREBASE_API_KEY}}` → Firebase API key
   - `{{FIREBASE_AUTH_DOMAIN}}` → Firebase auth domain
   - `{{FIREBASE_STORAGE_BUCKET}}` → Firebase storage bucket
   - `{{FIREBASE_MESSAGING_SENDER_ID}}` → Firebase messaging sender ID
   - `{{GOOGLE_CLIENT_ID}}` → Google OAuth client ID

### Example Configuration

```dart
class AppConfig {
  static const String environment = "production";
  static const String backendUrl = "https://your-backend.run.app";
  static const String firebaseProjectId = "your-project-id";
  static const String firebaseAppId = "1:123456789:web:abcdef123456";
  static const String firebaseApiKey = "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  static const String firebaseAuthDomain = "your-project.firebaseapp.com";
  static const String firebaseStorageBucket = "your-project.appspot.com";
  static const String firebaseMessagingSenderId = "123456789";
  static const String googleClientId = "123456789-xxxxxxxx.apps.googleusercontent.com";
}
```

## CI/CD Setup

The GitHub Actions workflows automatically generate `app_config.dart` during the build process. The configuration is embedded directly in the workflow files.

### Workflow Steps

1. Checkout code
2. Setup Flutter
3. Get dependencies
4. **Generate Config File** ← Creates `app_config.dart` from embedded config
5. Build application
6. Deploy

## Security Notes

### ⚠️ Current Setup

**Firebase Configuration Values**: The current implementation includes Firebase configuration values directly in the workflow files. While these are **not secret** (they're meant to be public and are exposed in web apps), it's good practice to be aware:

- Firebase API keys are **safe to expose** in client-side code
- Firebase security relies on **Security Rules**, not on hiding config values
- These values are already visible in your deployed web app's JavaScript

### 🔒 Best Practices

For truly sensitive values (like service account keys):
- ✅ Use GitHub Secrets
- ✅ Never commit to git
- ✅ Rotate keys regularly

### 📝 To Use GitHub Secrets (Optional Enhancement)

If you want to use GitHub Secrets instead:

1. Add secrets in GitHub: Settings → Secrets and variables → Actions
2. Update workflow to use secrets:
   ```yaml
   - name: Generate Config File
     env:
       FIREBASE_API_KEY: ${{ secrets.FIREBASE_API_KEY }}
       BACKEND_URL: ${{ secrets.BACKEND_URL }}
       # ... other secrets
     run: |
       cat > lib/config/app_config.dart << EOF
       class AppConfig {
         static const String environment = "production";
         static const String backendUrl = "$BACKEND_URL";
         static const String firebaseApiKey = "$FIREBASE_API_KEY";
         // ... etc
       }
       EOF
   ```

## Troubleshooting

### Build fails with "Error reading 'app_config.dart'"

**Cause**: The config file doesn't exist.

**Solution**: 
- **Local**: Run `cp lib/config/app_config.template.dart lib/config/app_config.dart` and fill in values
- **CI/CD**: The workflow should generate it automatically. Check workflow logs.

### "Undefined name 'AppConfig'" errors

**Cause**: The `app_config.dart` file is not being generated or imported correctly.

**Solution**:
1. Verify `app_config.dart` exists in `lib/config/`
2. Check that the import path is correct: `import 'app_config.dart';`
3. Run `flutter clean` and rebuild

## Files in .gitignore

The following files are ignored to keep secrets safe:
- `lib/config/app_config.dart` - Generated config with actual values
- `.env*` - Environment variable files
- `config/*.json` - JSON config files with sensitive data

## Migration from Old Setup

If you previously had `app_config.dart` committed:

1. Remove it from git: `git rm --cached lib/config/app_config.dart`
2. Create your local copy from template
3. Commit the `.gitignore` update
4. Workflows will handle CI/CD generation
