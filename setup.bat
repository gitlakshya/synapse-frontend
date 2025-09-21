@echo off
setlocal EnableDelayedExpansion

REM Firebase Deployment Setup Script for Windows
REM This script helps set up the environment for Firebase deployment

echo ========================================
echo    🔧 FIREBASE DEPLOYMENT SETUP
echo ========================================
echo.

REM Colors
set "GREEN=[92m"
set "BLUE=[94m"
set "YELLOW=[93m"
set "RED=[91m"
set "NC=[0m"

echo %BLUE%[INFO]%NC% Checking prerequisites...

REM Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% Node.js is not installed
    echo Please install Node.js from: https://nodejs.org/
    pause
    exit /b 1
) else (
    for /f %%i in ('node --version') do set NODE_VERSION=%%i
    echo %GREEN%[SUCCESS]%NC% Node.js found: !NODE_VERSION!
)

REM Check npm
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% npm is not installed
    pause
    exit /b 1
) else (
    for /f %%i in ('npm --version') do set NPM_VERSION=%%i
    echo %GREEN%[SUCCESS]%NC% npm found: !NPM_VERSION!
)

REM Check Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% Flutter is not installed
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
) else (
    echo %GREEN%[SUCCESS]%NC% Flutter found
)

REM Install Firebase CLI if not present
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %YELLOW%[WARNING]%NC% Firebase CLI not found. Installing...
    npm install -g firebase-tools
    if %errorlevel% neq 0 (
        echo %RED%[ERROR]%NC% Failed to install Firebase CLI
        pause
        exit /b 1
    ) else (
        echo %GREEN%[SUCCESS]%NC% Firebase CLI installed successfully
    )
) else (
    for /f %%i in ('firebase --version') do set FIREBASE_VERSION=%%i
    echo %GREEN%[SUCCESS]%NC% Firebase CLI found: !FIREBASE_VERSION!
)

echo.
echo %BLUE%[INFO]%NC% Installing Flutter dependencies...
flutter pub get

echo.
echo %BLUE%[INFO]%NC% Checking Flutter doctor...
flutter doctor

echo.
echo %BLUE%[INFO]%NC% Setting up Firebase authentication...
echo Please follow these steps:
echo.
echo 1. Login to Firebase:
echo    firebase login
echo.
echo 2. Verify your project access:
echo    firebase projects:list
echo.
echo 3. Test deployment (optional):
echo    firebase deploy --only hosting --project calcium-ratio-472014-r9
echo.

REM Generate Firebase token for CI/CD
echo.
echo %BLUE%[INFO]%NC% For CI/CD setup, you'll need a Firebase token:
echo.
echo 1. Generate a CI token:
echo    firebase login:ci
echo.
echo 2. Add the token to your GitHub repository secrets:
echo    - Go to: https://github.com/gitlakshya/synapse-frontend/settings/secrets/actions
echo    - Add a new secret named 'FIREBASE_TOKEN'
echo    - Paste the generated token as the value
echo.

echo %BLUE%[INFO]%NC% Environment setup checklist:
echo ✅ Node.js and npm installed
echo ✅ Flutter installed and configured
echo ✅ Firebase CLI installed
echo ✅ Flutter dependencies installed
echo.
echo 📋 Next steps:
echo 1. Run: firebase login
echo 2. Test build: build_scripts\build.bat
echo 3. Test deployment: deploy.bat
echo 4. Set up GitHub secrets for CI/CD
echo.

echo %GREEN%[SUCCESS]%NC% Setup script completed!
echo.
echo 🚀 You're ready to deploy! Run 'deploy.bat' to start deployment.
pause