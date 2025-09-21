#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "========================================"
echo "🚀 SYNAPSE FRONTEND DEPLOYMENT"
echo "========================================"
echo

print_status "Starting Firebase deployment process..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI is not installed"
    print_status "Installing Firebase CLI..."
    npm install -g firebase-tools
    if [ $? -ne 0 ]; then
        print_error "Failed to install Firebase CLI"
        echo "Please install manually: npm install -g firebase-tools"
        exit 1
    fi
fi

print_status "Step 1: Cleaning previous builds..."
flutter clean

print_status "Step 2: Installing dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    print_error "Failed to get dependencies"
    exit 1
fi

print_status "Step 3: Running code analysis..."
flutter analyze --fatal-infos || print_warning "Code analysis found issues, continuing..."

print_status "Step 4: Running tests..."
flutter test || print_warning "Some tests failed, continuing..."

print_status "Step 5: Building web app for production..."
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true
if [ $? -ne 0 ]; then
    print_error "Build failed"
    exit 1
fi

print_status "Step 6: Verifying build output..."
if [ ! -f "build/web/index.html" ]; then
    print_error "Build output is invalid - index.html not found"
    exit 1
fi

print_success "Build verification passed!"

print_status "Step 7: Deploying to Firebase Hosting..."
firebase deploy --only hosting --project calcium-ratio-472014-r9
if [ $? -ne 0 ]; then
    print_error "Deployment failed"
    echo "Please check your Firebase authentication:"
    echo "  - Run: firebase login"
    echo "  - Verify project access: firebase projects:list"
    exit 1
fi

echo
echo "========================================"
print_success "Deployment completed successfully!"
echo "========================================"
echo
echo "🌐 Your app is now live at:"
echo "   https://calcium-ratio-472014-r9.web.app"
echo "   https://calcium-ratio-472014-r9.firebaseapp.com"
echo
echo "📊 Firebase Console:"
echo "   https://console.firebase.google.com/project/calcium-ratio-472014-r9"
echo
echo "✅ Next steps:"
echo "   - Test the live application"
echo "   - Monitor performance in Firebase Console"
echo "   - Check Analytics if enabled"
echo