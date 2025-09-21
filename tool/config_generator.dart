import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final env = args.isNotEmpty ? args[0] : 'development';
  final configFile = File('config/$env.json');
  
  if (!configFile.existsSync()) {
    print('Config file not found: config/$env.json');
    exit(1);
  }
  
  final config = jsonDecode(configFile.readAsStringSync());
  final output = StringBuffer();
  
  output.writeln('class AppConfig {');
  output.writeln('  static const String environment = "${config['environment']}";');
  output.writeln('  static const String backendUrl = "${config['backendUrl']}";');
  output.writeln('  static const String firebaseProjectId = "${config['firebase']['projectId']}";');
  output.writeln('  static const String firebaseAppId = "${config['firebase']['appId']}";');
  output.writeln('  static const String firebaseApiKey = "${config['firebase']['apiKey']}";');
  output.writeln('  static const String firebaseAuthDomain = "${config['firebase']['authDomain']}";');
  output.writeln('  static const String firebaseStorageBucket = "${config['firebase']['storageBucket']}";');
  output.writeln('  static const String firebaseMessagingSenderId = "${config['firebase']['messagingSenderId']}";');
  output.writeln('  static const String googleClientId = "${config['google']['clientId']}";');
  output.writeln('}');
  
  File('lib/config/app_config.dart').writeAsStringSync(output.toString());
  print('Generated app_config.dart for $env environment');
}