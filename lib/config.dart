class Config {
  // Firebase Configuration
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
  static const String firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
  
  // Google Services
  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
  static const String googleSignInClientId = String.fromEnvironment('GOOGLE_SIGNIN_CLIENT_ID', defaultValue: '');
  
  // API Keys
  static const String openWeatherApiKey = String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: '');
  
  // Backend API Configuration (for AI features)
  static const String backendApiUrl = String.fromEnvironment('BACKEND_API_URL', defaultValue: 'https://synapse-backend-80902795823.asia-south2.run.app');
  
  // Validation
  static bool get isConfigured => 
    firebaseApiKey.isNotEmpty && 
    firebaseProjectId.isNotEmpty;
}
