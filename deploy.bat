@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo    🚀 SYNAPSE FRONTEND DEPLOYMENT
echo ========================================
echo.

REM Colors and formatting
set "GREEN=[92m"
set "BLUE=[94m"
set "YELLOW=[93m"
set "RED=[91m"
set "NC=[0m"

echo %BLUE%[INFO]%NC% Starting Firebase deployment process...
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% Flutter is not installed or not in PATH
    echo Please install Flutter: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% Firebase CLI is not installed
    echo Installing Firebase CLI...
    npm install -g firebase-tools
    if %errorlevel% neq 0 (
        echo %RED%[ERROR]%NC% Failed to install Firebase CLI
        echo Please install manually: npm install -g firebase-tools
        pause
        exit /b 1
    )
)

echo %BLUE%[INFO]%NC% Step 1: Cleaning previous builds...
flutter clean

echo.
echo %BLUE%[INFO]%NC% Step 2: Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo %BLUE%[INFO]%NC% Step 3: Running code analysis...
flutter analyze --fatal-infos
if %errorlevel% neq 0 (
    echo %YELLOW%[WARNING]%NC% Code analysis found issues, continuing...
)

echo.
echo %BLUE%[INFO]%NC% Step 4: Running tests...
flutter test
if %errorlevel% neq 0 (
    echo %YELLOW%[WARNING]%NC% Some tests failed, continuing...
)

echo.
echo %BLUE%[INFO]%NC% Step 5: Building web app for production...
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% Build failed
    pause
    exit /b 1
)

echo.
echo %BLUE%[INFO]%NC% Step 6: Verifying build output...
if not exist "build\web\index.html" (
    echo %RED%[ERROR]%NC% Build output is invalid - index.html not found
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]%NC% Build verification passed!

echo.
echo %BLUE%[INFO]%NC% Step 7: Deploying to Firebase Hosting...
firebase deploy --only hosting --project calcium-ratio-472014-r9
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% Deployment failed
    echo Please check your Firebase authentication:
    echo   - Run: firebase login
    echo   - Verify project access: firebase projects:list
    pause
    exit /b 1
)

echo.
echo ========================================
echo %GREEN%[SUCCESS]%NC% Deployment completed successfully!
echo ========================================
echo.
echo 🌐 Your app is now live at:
echo    https://calcium-ratio-472014-r9.web.app
echo    https://calcium-ratio-472014-r9.firebaseapp.com
echo.
echo 📊 Firebase Console:
echo    https://console.firebase.google.com/project/calcium-ratio-472014-r9
echo.
echo ✅ Next steps:
echo    - Test the live application
echo    - Monitor performance in Firebase Console
echo    - Check Analytics if enabled
echo.
pause