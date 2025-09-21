import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'config/env_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform.',
    );
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKey,
    appId: EnvConfig.firebaseAppId,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
    authDomain: EnvConfig.firebaseAuthDomain,
    storageBucket: EnvConfig.firebaseStorageBucket,
  );
}