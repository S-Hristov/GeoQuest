import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import '../models/geo_models.dart';

class LocationCheckResult {
  const LocationCheckResult({required this.status, this.distanceMeters});
  final ChallengeStatus status;
  final double? distanceMeters;
}

class LocationService {
  const LocationService();
  static const completionRadiusMeters = 100.0;

  Future<LocationCheckResult> checkChallenge(Challenge challenge) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationCheckResult(
          status: ChallengeStatus.locationPermissionRequired,
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const LocationCheckResult(
          status: ChallengeStatus.locationPermissionRequired,
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        challenge.latitude,
        challenge.longitude,
      );
      return LocationCheckResult(
        status: distance <= completionRadiusMeters
            ? ChallengeStatus.locationReached
            : ChallengeStatus.tooFar,
        distanceMeters: distance,
      );
    } catch (_) {
      return const LocationCheckResult(
        status: ChallengeStatus.locationPermissionRequired,
      );
    }
  }

  static double haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180;
}
