#!/bin/bash

# Firebase Deployment Setup Script
# This script helps set up the environment for Firebase deployment

set -e

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
echo "🔧 FIREBASE DEPLOYMENT SETUP"
echo "========================================"
echo

# Check prerequisites
print_status "Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed"
    echo "Please install Node.js from: https://nodejs.org/"
    exit 1
else
    NODE_VERSION=$(node --version)
    print_success "Node.js found: $NODE_VERSION"
fi

# Check npm
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed"
    exit 1
else
    NPM_VERSION=$(npm --version)
    print_success "npm found: $NPM_VERSION"
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
else
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "Flutter found: $FLUTTER_VERSION"
fi

# Install Firebase CLI if not present
if ! command -v firebase &> /dev/null; then
    print_warning "Firebase CLI not found. Installing..."
    npm install -g firebase-tools
    if [ $? -eq 0 ]; then
        print_success "Firebase CLI installed successfully"
    else
        print_error "Failed to install Firebase CLI"
        exit 1
    fi
else
    FIREBASE_VERSION=$(firebase --version)
    print_success "Firebase CLI found: $FIREBASE_VERSION"
fi

print_status "Installing Flutter dependencies..."
flutter pub get

print_status "Checking Flutter doctor..."
flutter doctor

echo
print_status "Setting up Firebase authentication..."
echo "Please follow these steps:"
echo
echo "1. Login to Firebase:"
echo "   firebase login"
echo
echo "2. Verify your project access:"
echo "   firebase projects:list"
echo
echo "3. Test deployment (optional):"
echo "   firebase deploy --only hosting --project calcium-ratio-472014-r9"
echo

# Generate Firebase token for CI/CD
echo
print_status "For CI/CD setup, you'll need a Firebase token:"
echo
echo "1. Generate a CI token:"
echo "   firebase login:ci"
echo
echo "2. Add the token to your GitHub repository secrets:"
echo "   - Go to: https://github.com/gitlakshya/synapse-frontend/settings/secrets/actions"
echo "   - Add a new secret named 'FIREBASE_TOKEN'"
echo "   - Paste the generated token as the value"
echo

print_status "Environment setup checklist:"
echo "✅ Node.js and npm installed"
echo "✅ Flutter installed and configured"
echo "✅ Firebase CLI installed"
echo "✅ Flutter dependencies installed"
echo
echo "📋 Next steps:"
echo "1. Run: firebase login"
echo "2. Test build: ./build_scripts/build.sh"
echo "3. Test deployment: ./deploy.sh"
echo "4. Set up GitHub secrets for CI/CD"
echo

print_success "Setup script completed!"
echo
echo "🚀 You're ready to deploy! Run './deploy.sh' to start deployment."