import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_bootstrap.dart';

class PushNotificationService {
  bool configured = false;
  String? token;
  bool _foregroundHooked = false;

  Future<void> initIfConfigured() async {
    try {
      final initialized = await FirebaseBootstrap.ensureInitialized();
      if (!initialized) {
        configured = false;
        return;
      }
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      token = await messaging.getToken();
      if (!_foregroundHooked) {
        FirebaseMessaging.onMessage.listen((message) {
          debugPrint(
            '📩 PUSH FOREGROUND | title=${message.notification?.title} '
            'body=${message.notification?.body} data=${message.data}',
          );
        });
        _foregroundHooked = true;
      }
      configured = true;
    } catch (_) {
      configured = false;
    }
  }
}
