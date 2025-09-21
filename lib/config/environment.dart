import 'env_config.dart';

enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment get currentEnvironment {
    if (EnvConfig.isDevelopment) return Environment.development;
    if (EnvConfig.isStaging) return Environment.staging;
    return Environment.production;
  }
  
  static bool get isDevelopment => currentEnvironment == Environment.development;
  static bool get isStaging => currentEnvironment == Environment.staging;
  static bool get isProduction => currentEnvironment == Environment.production;
  
  static String get apiBaseUrl => EnvConfig.backendUrl;
  
  static bool get enableAnalytics => isProduction || isStaging;
  static bool get enableCrashReporting => isProduction;
  static bool get enableLogging => !isProduction;
}