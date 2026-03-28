import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import 'backend_config.dart';
import 'firebase_bootstrap.dart';

abstract class BackendClient {
  Future<Map<String, dynamic>> getAppState({
    String? name,
    String? email,
    String? initials,
    String? avatarPath,
  });

  Future<Map<String, dynamic>> syncUserProfile({
    required String name,
    required String email,
    required String initials,
    String? avatarPath,
  });

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String initials,
    String? avatarPath,
  });

  Future<List<Map<String, dynamic>>> getChallenges();

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50});

  Future<Map<String, dynamic>> startChallenge(String challengeId);

  Future<Map<String, dynamic>> markRouteShown(String challengeId);

  Future<Map<String, dynamic>> completeChallenge(
    String challengeId, {
    String? proofPath,
  });

  Future<Map<String, dynamic>> registerPushToken({
    required String token,
    String? platform,
    String? locale,
  });

  Future<Map<String, dynamic>> updateNotificationPrefs({
    required Map<String, bool> prefs,
  });

  Future<Map<String, dynamic>> updateUserLocation({
    required double latitude,
    required double longitude,
    String? recordedAt,
  });
}

class FirebaseBackendClient implements BackendClient {
  const FirebaseBackendClient();

  static FirebaseFunctions? _functions;
  static bool _firebaseConfigured = false;

  FirebaseFunctions get _functionsInstance => _functions ??=
      FirebaseFunctions.instanceFor(region: BackendConfig.functionsRegion);

  Future<Map<String, dynamic>> _mapCall(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    await _ensureFirebase();
    debugPrint('🔥 FUNC CALL -> $name | data=${data ?? const {}}');
    final result = await _functionsInstance.httpsCallable(name).call(data);
    debugPrint('✅ FUNC OK <- $name');
    final payload = result.data;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return const {};
  }

  Future<void> _ensureFirebase() async {
    final initialized = await FirebaseBootstrap.ensureInitialized();
    if (!initialized) {
      throw StateError(FirebaseBootstrap.configurationErrorMessage());
    }
    if (_firebaseConfigured) return;
    if (BackendConfig.useEmulators) {
      debugPrint(
        '🧪 FUNCTIONS EMU ON | host=${BackendConfig.emulatorHost} '
        'port=${BackendConfig.functionsPort} '
        'region=${BackendConfig.functionsRegion}',
      );
      _functionsInstance.useFunctionsEmulator(
        BackendConfig.emulatorHost,
        BackendConfig.functionsPort,
      );
    } else {
      debugPrint('☁️ FUNCTIONS PROD | region=${BackendConfig.functionsRegion}');
    }
    _firebaseConfigured = true;
  }

  @override
  Future<Map<String, dynamic>> getAppState({
    String? name,
    String? email,
    String? initials,
    String? avatarPath,
  }) {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (initials != null) data['initials'] = initials;
    if (avatarPath != null) data['avatarPath'] = avatarPath;
    return _mapCall('getAppState', data.isEmpty ? null : data);
  }

  @override
  Future<Map<String, dynamic>> syncUserProfile({
    required String name,
    required String email,
    required String initials,
    String? avatarPath,
  }) {
    return _mapCall('syncUserProfile', {
      'name': name,
      'email': email,
      'initials': initials,
      'avatarPath': avatarPath,
    });
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String initials,
    String? avatarPath,
  }) {
    return _mapCall('updateProfile', {
      'name': name,
      'email': email,
      'initials': initials,
      'avatarPath': avatarPath,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getChallenges() async {
    await _ensureFirebase();
    final result = await _functionsInstance
        .httpsCallable('getChallenges')
        .call();
    final data = result.data;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50}) async {
    await _ensureFirebase();
    final result = await _functionsInstance
        .httpsCallable('getLeaderboard')
        .call({'limit': limit});
    final data = result.data;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> startChallenge(String challengeId) {
    return _mapCall('startChallenge', {'challengeId': challengeId});
  }

  @override
  Future<Map<String, dynamic>> markRouteShown(String challengeId) {
    return _mapCall('markRouteShown', {'challengeId': challengeId});
  }

  @override
  Future<Map<String, dynamic>> completeChallenge(
    String challengeId, {
    String? proofPath,
  }) {
    return _mapCall('completeChallenge', {
      'challengeId': challengeId,
      'proofPath': proofPath,
    });
  }

  @override
  Future<Map<String, dynamic>> registerPushToken({
    required String token,
    String? platform,
    String? locale,
  }) {
    return _mapCall('registerPushToken', {
      'token': token,
      'platform': platform,
      'locale': locale,
    });
  }

  @override
  Future<Map<String, dynamic>> updateNotificationPrefs({
    required Map<String, bool> prefs,
  }) {
    return _mapCall('updateNotificationPrefs', {'prefs': prefs});
  }

  @override
  Future<Map<String, dynamic>> updateUserLocation({
    required double latitude,
    required double longitude,
    String? recordedAt,
  }) {
    return _mapCall('updateUserLocation', {
      'latitude': latitude,
      'longitude': longitude,
      'recordedAt': recordedAt,
    });
  }
}
