# EaseMyTrip AI Planner - Development Run Script
# This script runs the Flutter web app with all necessary environment variables

Write-Host "🚀 EaseMyTrip AI Planner - Development Mode" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Flutter found: " -NoNewline -ForegroundColor Green
flutter --version | Select-Object -First 1

Write-Host ""
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "🔑 API Key Configuration Status:" -ForegroundColor Cyan
Write-Host "  - Firebase API Key: " -NoNewline
if ($env:FIREBASE_API_KEY) { Write-Host "✅ Set" -ForegroundColor Green } else { Write-Host "❌ Not Set (Using Mock)" -ForegroundColor Yellow }
Write-Host "  - Google Maps API Key: " -NoNewline
if ($env:GOOGLE_MAPS_API_KEY) { Write-Host "✅ Set" -ForegroundColor Green } else { Write-Host "❌ Not Set (Using Mock)" -ForegroundColor Yellow }
Write-Host "  - OpenWeather API Key: " -NoNewline
if ($env:OPENWEATHER_API_KEY) { Write-Host "✅ Set" -ForegroundColor Green } else { Write-Host "❌ Not Set (Using Mock)" -ForegroundColor Yellow }
Write-Host "  - Gemini API Key: " -NoNewline
if ($env:GEMINI_API_KEY) { Write-Host "✅ Set" -ForegroundColor Green } else { Write-Host "❌ Not Set (Using Mock)" -ForegroundColor Yellow }

Write-Host ""
Write-Host "🌐 Starting Flutter Web App on Chrome..." -ForegroundColor Cyan
Write-Host ""

# Build the dart-define arguments
$dartDefines = @()
$dartDefines += "--dart-define=FIREBASE_API_KEY=$($env:FIREBASE_API_KEY)"
$dartDefines += "--dart-define=FIREBASE_APP_ID=$($env:FIREBASE_APP_ID)"
$dartDefines += "--dart-define=FIREBASE_MESSAGING_SENDER_ID=$($env:FIREBASE_MESSAGING_SENDER_ID)"
$dartDefines += "--dart-define=FIREBASE_PROJECT_ID=$($env:FIREBASE_PROJECT_ID)"
$dartDefines += "--dart-define=GOOGLE_SIGNIN_CLIENT_ID=$($env:GOOGLE_SIGNIN_CLIENT_ID)"
$dartDefines += "--dart-define=GOOGLE_MAPS_API_KEY=$($env:GOOGLE_MAPS_API_KEY)"
$dartDefines += "--dart-define=OPENWEATHER_API_KEY=$($env:OPENWEATHER_API_KEY)"
$dartDefines += "--dart-define=GEMINI_API_KEY=$($env:GEMINI_API_KEY)"

# Run Flutter
flutter run -d chrome @dartDefines

Write-Host ""
Write-Host "✅ Application closed" -ForegroundColor Green
