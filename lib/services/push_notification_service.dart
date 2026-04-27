import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_bootstrap.dart';

typedef OnPushMessage = void Function(String title, String body, String type);

class PushNotificationService {
  bool configured = false;
  String? token;
  bool _hooked = false;

  OnPushMessage? onMessage;
  OnPushMessage? onMessageOpenedApp;

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

      if (!_hooked) {
        // foreground — app is open
        FirebaseMessaging.onMessage.listen((message) {
          debugPrint(
            '📩 PUSH FOREGROUND | title=${message.notification?.title} '
            'body=${message.notification?.body} data=${message.data}',
          );
          _dispatch(onMessage, message);
        });

        // background tap — user tapped system notification
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
          debugPrint('📩 PUSH TAP | title=${message.notification?.title}');
          _dispatch(onMessageOpenedApp, message);
        });

        // terminated tap — app was killed, user tapped notification
        final initial = await messaging.getInitialMessage();
        if (initial != null) {
          debugPrint(
            '📩 PUSH INITIAL | title=${initial.notification?.title}',
          );
          _dispatch(onMessageOpenedApp, initial);
        }

        _hooked = true;
      }
      configured = true;
    } catch (_) {
      configured = false;
    }
  }

  void _dispatch(OnPushMessage? callback, RemoteMessage message) {
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    final type = message.data['type'] as String? ?? 'general';
    if (title.isNotEmpty || body.isNotEmpty) {
      callback?.call(title, body, type);
    }
  }
}
