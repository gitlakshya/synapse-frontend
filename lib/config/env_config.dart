import 'app_config.dart';

class EnvConfig {
  static String get backendUrl => AppConfig.backendUrl;
  static String get firebaseProjectId => AppConfig.firebaseProjectId;
  static String get firebaseAppId => AppConfig.firebaseAppId;
  static String get firebaseApiKey => AppConfig.firebaseApiKey;
  static String get firebaseAuthDomain => AppConfig.firebaseAuthDomain;
  static String get firebaseStorageBucket => AppConfig.firebaseStorageBucket;
  static String get firebaseMessagingSenderId => AppConfig.firebaseMessagingSenderId;
  static String get googleClientId => AppConfig.googleClientId;
  
  static bool get isDevelopment => AppConfig.environment == 'development';
  static bool get isProduction => AppConfig.environment == 'production';
  static bool get isStaging => AppConfig.environment == 'staging';
}