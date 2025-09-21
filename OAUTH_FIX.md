# Google OAuth Configuration Fix

## Problem
Error 400: redirect_uri_mismatch when using Google authentication on the deployed Firebase app.

## Root Cause
The Google OAuth client is not configured to allow the Firebase Hosting domain as an authorized JavaScript origin.

## Solution Steps

### 1. Access Google Cloud Console
- Go to: https://console.cloud.google.com
- Project: calcium-ratio-472014-r9
- Navigate: APIs & Services → Credentials

### 2. Find OAuth 2.0 Client
- Client ID: 80902795823-0peak8l1jm8jn0mcchcaik7n33mcnsdg.apps.googleusercontent.com
- Click on the client to edit

### 3. Update Authorized JavaScript Origins
Add these domains to "Authorized JavaScript origins":

**Required Origins:**
- https://calcium-ratio-472014-r9.web.app
- https://calcium-ratio-472014-r9.firebaseapp.com

**Optional (for development):**
- http://localhost:3000
- http://localhost:8080
- http://127.0.0.1:3000
- http://127.0.0.1:8080

### 4. Update Authorized Redirect URIs
Add these URIs to "Authorized redirect URIs":

**Required Redirects:**
- https://calcium-ratio-472014-r9.web.app/__/auth/handler
- https://calcium-ratio-472014-r9.firebaseapp.com/__/auth/handler

**Optional (for development):**
- http://localhost:3000/__/auth/handler
- http://localhost:8080/__/auth/handler

### 5. Save Changes
Click "Save" to apply the changes.

## Quick Access Links

- **Google Cloud Console**: https://console.cloud.google.com/apis/credentials?project=calcium-ratio-472014-r9
- **Firebase Console**: https://console.firebase.google.com/project/calcium-ratio-472014-r9/authentication/providers
- **Live App**: https://calcium-ratio-472014-r9.web.app

## Testing
After updating the configuration:
1. Wait 5-10 minutes for changes to propagate
2. Clear browser cache/cookies
3. Test Google sign-in on the live app

## Alternative: Firebase Authentication Setup
If you prefer using Firebase's simplified OAuth setup:
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable Google provider
3. Use the Web SDK configuration provided by Firebase