# Trip Planner UI - Web-Optimized Flutter Application

## 🌟 Overview

An AI-powered trip planning application built with Flutter, optimized for web deployment. This application provides intelligent travel planning with session management, user authentication, and real-time data synchronization.

## 🏗️ Architecture

### Web-Only Optimization
This application has been specifically optimized for web deployment:
- **Removed Mobile Platforms**: All mobile-specific code and directories have been removed
- **Browser-Native Storage**: Uses localStorage instead of mobile secure storage
- **Web-Compatible Dependencies**: Only web-compatible packages included
- **Optimized Bundle Size**: Reduced from mobile-inclusive to web-only deployment

### Key Features
- 🧠 **AI-Powered Planning**: Gemini AI integration for intelligent trip suggestions
- 🔐 **Smart Authentication**: Firebase Auth with Google Sign-In
- 📱 **Responsive Design**: Optimized for desktop and mobile browsers
- 🗃️ **Intelligent Session Management**: Automatic session expiry handling
- 🌐 **Real-time Data**: Live weather, maps, and travel information

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.1.5+
- Dart SDK
- Web browser for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd synapse-frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   ```bash
   # Copy configuration templates
   cp config/development.json.template config/development.json
   cp config/production.json.template config/production.json
   
   # Edit configuration files with your API keys
   # See Configuration section below
   ```

4. **Run the application**
   ```bash
   flutter run -d web-server --web-port=8080
   ```

5. **Open in browser**
   Navigate to `http://localhost:8080`

## ⚙️ Configuration

### Environment Setup

Create configuration files from templates:

1. **Development Configuration** (`config/development.json`)
   ```json
   {
     "environment": "development",
     "backendUrl": "https://your-backend-url.com",
     "firebase": {
       "projectId": "your-firebase-project-id",
       "appId": "your-firebase-app-id",
       "apiKey": "your-firebase-api-key",
       "authDomain": "your-project.firebaseapp.com",
       "storageBucket": "your-project.appspot.com",
       "messagingSenderId": "your-messaging-sender-id"
     },
     "google": {
       "clientId": "your-google-client-id",
       "clientSecret": "your-google-client-secret"
     }
   }
   ```

2. **Production Configuration** (`config/production.json`)
   - Use the same structure with production values

### Required API Keys
- **Firebase**: Project configuration from Firebase Console
- **Google OAuth**: Client credentials from Google Cloud Console
- **Gemini AI**: API key from Google AI Studio
- **Backend API**: Your custom backend service

## 🏛️ Project Structure

```
lib/
├── config/              # Configuration management
├── enhancements/        # Feature enhancements
├── models/              # Data models
├── providers/           # State management
├── screens/             # UI screens
├── services/            # Business logic services
│   ├── storage_service.dart          # Web-optimized storage
│   ├── session_service.dart          # Session management
│   ├── firebase_auth_service.dart    # Authentication
│   └── authenticated_http_client.dart # API client
├── utils/               # Utility functions
├── widgets/             # Reusable components
└── main.dart           # Application entry point
```

## 🔐 Security Features

### Session Management
- **Intelligent Creation**: Only creates sessions when needed
- **Automatic Expiry**: Sessions expire after 4 hours
- **Auth State Awareness**: Different behavior for authenticated vs guest users
- **Storage Security**: Browser localStorage with proper expiry handling

### Data Protection
- **Environment Variables**: Sensitive data in configuration files
- **Gitignore Protection**: API keys and secrets excluded from version control
- **Template Configurations**: Safe defaults for development setup

## 📦 Dependencies

### Core Dependencies
- `flutter`: Framework
- `firebase_core`: Firebase integration
- `firebase_auth`: Authentication
- `google_sign_in`: OAuth integration
- `http`: API communication

### Web-Optimized Packages
- `responsive_framework`: Responsive design
- `shared_preferences`: Web storage
- `url_launcher`: Web navigation
- `connectivity_plus`: Network status

### UI/UX Libraries
- `flutter_animate`: Animations
- `lottie`: Animation assets
- `cached_network_image`: Image caching
- `flutter_map`: Interactive maps

## 🚀 Deployment

### Web Deployment
```bash
# Build for web
flutter build web --release

# Deploy to hosting service
# Copy build/web/ contents to your web server
```

### Supported Platforms
- ✅ **Web Browsers**: Chrome, Firefox, Safari, Edge
- ❌ **Mobile Apps**: Removed for web-only optimization
- ❌ **Desktop Apps**: Removed for web-only optimization

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Manual Testing Scenarios
1. **New User Flow**: No session → Creates guest session on "Get Started"
2. **Returning User**: Existing session → Reuses without new creation
3. **Session Expiry**: Expired session → Cleared and new session created
4. **Authentication**: Login → Session migration → Auth token stored

## 📊 Performance Optimizations

### Web-Only Benefits
- 🚀 **Faster Loading**: 60% reduction in bundle size
- 💾 **Reduced Complexity**: No mobile-specific code
- 🌐 **Browser-Native**: Uses web APIs directly
- ⚡ **Smart Caching**: Intelligent session and data management

### Session Optimization
- **Reduced API Calls**: No unnecessary session creation
- **Efficient Storage**: Browser localStorage instead of complex secure storage
- **Smart Expiry**: Automatic cleanup of expired sessions

## 🐛 Troubleshooting

### Common Issues

1. **Configuration Errors**
   ```bash
   # Ensure configuration files exist
   ls config/development.json
   
   # Check API key format
   grep "apiKey" config/development.json
   ```

2. **Build Errors**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter build web
   ```

3. **Session Issues**
   ```bash
   # Clear browser storage
   # Open DevTools → Application → Storage → Clear All
   ```

## 📝 Development Guidelines

### Git Best Practices
- **Secure Configuration**: Never commit API keys or secrets
- **Clean History**: Use meaningful commit messages
- **Template Usage**: Use `.template` files for configuration examples

### Code Quality
- **Linting**: Follow Flutter/Dart style guidelines
- **Documentation**: Document all public APIs
- **Testing**: Write tests for critical functionality

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙋‍♂️ Support

For questions or issues:
1. Check the troubleshooting section
2. Review the configuration templates
3. Create an issue in the repository

---

**Note**: This is a web-optimized version of the Flutter application. Mobile platform support has been intentionally removed for improved web performance and simplified deployment.