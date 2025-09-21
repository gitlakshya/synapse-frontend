#!/bin/bash

set -e  # Exit on any error

echo "🚀 Starting production build process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
print_status "Checking Flutter version..."
flutter --version

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Check for dependency issues
print_status "Checking for dependency issues..."
flutter pub deps || print_warning "Some dependency issues found, continuing..."

# Run code analysis
print_status "Running code analysis..."
flutter analyze --fatal-infos || print_warning "Analysis issues found, check above output"

# Run tests
print_status "Running tests..."
flutter test || print_warning "Some tests failed, check above output"

# Build web app for production
print_status "Building web app for production..."
flutter build web \
    --release \
    --web-renderer canvaskit \
    --dart-define=FLUTTER_WEB_USE_SKIA=true \
    --dart-define=FLUTTER_WEB_AUTO_DETECT=false \
    --source-maps \
    --base-href="/"

print_success "Build completed successfully!"

# Verify build output
if [ -d "build/web" ]; then
    print_success "Build directory exists"
    print_status "Build contents:"
    ls -la build/web/
else
    print_error "Build directory not found!"
    exit 1
fi

# Check if index.html exists
if [ -f "build/web/index.html" ]; then
    print_success "index.html found"
else
    print_error "index.html not found in build output!"
    exit 1
fi

# Calculate build size
BUILD_SIZE=$(du -sh build/web/ | cut -f1)
print_success "Build size: $BUILD_SIZE"

echo ""
print_success "Production build ready for deployment!"
print_status "Next steps:"
echo "  1. Test locally: flutter packages pub global activate dhttpd && dhttpd --path build/web"
echo "  2. Deploy: firebase deploy --only hosting"
echo "  3. Or run: ./deploy.sh"