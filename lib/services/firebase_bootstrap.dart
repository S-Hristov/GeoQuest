import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<bool> ensureInitialized() async {
    if (Firebase.apps.isNotEmpty) return true;
    try {
      final options = _optionsForCurrentPlatform();
      if (options != null) {
        await Firebase.initializeApp(options: options);
      } else {
        await Firebase.initializeApp();
      }
      return true;
    } catch (error) {
      debugPrint('❌ FIREBASE INIT FAIL | $error');
      return false;
    }
  }

  static String configurationErrorMessage() => switch (
    defaultTargetPlatform
  ) {
    TargetPlatform.iOS =>
      'Firebase is not configured for iOS. Add GoogleService-Info.plist or '
          'pass FIREBASE_IOS_* dart-defines.',
    TargetPlatform.android =>
      'Firebase is not configured for Android. Check google-services.json.',
    _ =>
      'Firebase is not configured for this platform. Check platform setup.',
  };

  static FirebaseOptions? _optionsForCurrentPlatform() => switch (
    defaultTargetPlatform
  ) {
    TargetPlatform.iOS => _iosOptions(),
    TargetPlatform.android => null,
    _ => null,
  };

  static FirebaseOptions? _iosOptions() {
    const apiKey = String.fromEnvironment('FIREBASE_IOS_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
    const messagingSenderId = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
    );
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const bundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');
    const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

    if (apiKey.isEmpty ||
        appId.isEmpty ||
        messagingSenderId.isEmpty ||
        projectId.isEmpty ||
        bundleId.isEmpty) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      iosBundleId: bundleId,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
    );
  }
}
