import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract class FirebaseInitializer {
  static Future<FirebaseApp> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }

    try {
      // Android/iOS read their config from the native files
      // (android/app/google-services.json / ios/Runner/GoogleService-Info.plist).
      final app = await Firebase.initializeApp();

      if (kDebugMode) {
        debugPrint(
          'Firebase initialized: app=${app.name}, projectId=${app.options.projectId}, appId=${app.options.appId}',
        );
      }

      return app;
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        return Firebase.app();
      }
      rethrow;
    }
  }
}
