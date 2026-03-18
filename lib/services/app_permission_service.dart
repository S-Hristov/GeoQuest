import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermissionType { location, camera, notifications }

class AppPermissionState {
  const AppPermissionState({
    required this.granted,
    this.permanentlyDenied = false,
  });

  final bool granted;
  final bool permanentlyDenied;
}

abstract class AppPermissionService {
  const AppPermissionService();

  Future<AppPermissionState> status(AppPermissionType type);
  Future<AppPermissionState> request(AppPermissionType type);
  Future<bool> openSettings();
}

class DevicePermissionService implements AppPermissionService {
  const DevicePermissionService();

  @override
  Future<AppPermissionState> status(AppPermissionType type) => switch (type) {
    AppPermissionType.location => _locationStatus(),
    AppPermissionType.camera => _statusFromPermission(Permission.camera),
    AppPermissionType.notifications => _statusFromPermission(
      Permission.notification,
    ),
  };

  @override
  Future<AppPermissionState> request(AppPermissionType type) => switch (type) {
    AppPermissionType.location => _requestLocation(),
    AppPermissionType.camera => _requestFromPermission(Permission.camera),
    AppPermissionType.notifications => _requestFromPermission(
      Permission.notification,
    ),
  };

  @override
  Future<bool> openSettings() => openAppSettings();

  Future<AppPermissionState> _locationStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      final granted =
          serviceEnabled &&
          (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse);
      return AppPermissionState(
        granted: granted,
        permanentlyDenied: permission == LocationPermission.deniedForever,
      );
    } catch (_) {
      return const AppPermissionState(granted: false);
    }
  }

  Future<AppPermissionState> _requestLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return const AppPermissionState(granted: false);

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return AppPermissionState(
        granted:
            permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse,
        permanentlyDenied: permission == LocationPermission.deniedForever,
      );
    } catch (_) {
      return const AppPermissionState(granted: false);
    }
  }

  Future<AppPermissionState> _statusFromPermission(
    Permission permission,
  ) async {
    try {
      final status = await permission.status;
      return _fromPermissionStatus(status);
    } catch (_) {
      return const AppPermissionState(granted: false);
    }
  }

  Future<AppPermissionState> _requestFromPermission(
    Permission permission,
  ) async {
    try {
      final status = await permission.request();
      return _fromPermissionStatus(status);
    } catch (_) {
      return const AppPermissionState(granted: false);
    }
  }

  AppPermissionState _fromPermissionStatus(PermissionStatus status) {
    final granted =
        status.isGranted || status.isLimited || status.isProvisional;
    return AppPermissionState(
      granted: granted,
      permanentlyDenied: status.isPermanentlyDenied || status.isRestricted,
    );
  }
}
