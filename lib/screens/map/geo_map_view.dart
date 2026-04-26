import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/geo_models.dart';
import '../../services/directions_service.dart';
import '../../theme/app_theme.dart';
import 'map_pin_style.dart';

class GeoMapView extends StatefulWidget {
  const GeoMapView({
    super.key,
    required this.challenges,
    required this.activeChallengeId,
    required this.completedChallengeIds,
    required this.onInactiveChallenge,
    required this.onActiveChallenge,
    this.navigationMode = false,
  });

  final List<Challenge> challenges;
  final String? activeChallengeId;
  final Set<String> completedChallengeIds;
  final ValueChanged<Challenge> onInactiveChallenge;
  final ValueChanged<Challenge> onActiveChallenge;
  final bool navigationMode;

  @override
  State<GeoMapView> createState() => GeoMapViewState();
}

class GeoMapViewState extends State<GeoMapView> {
  static const double _initialZoom = 6.4;
  static const double _clusterMaxZoom = 7.2;
  static const double _clusterCellSizePx = 88;
  static const double _clusterUserAvoidancePx = 34;
  static const double _clusterUserOffsetPx = 42;

  final _directions = const DirectionsService();
  final Map<String, BitmapDescriptor> _customIcons = {};

  GoogleMapController? _controller;
  LatLng? _userLocation;
  Challenge? _routingChallenge;
  RouteResult? _route;
  bool _loadingRoute = false;
  int _pinLoadVersion = 0;
  double _zoom = _initialZoom;
  double _pendingZoom = _initialZoom;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureCustomPins();
    _refreshUserLocation();
  }

  @override
  void didUpdateWidget(covariant GeoMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.navigationMode &&
        _activeChallenge != null &&
        oldWidget.activeChallengeId != widget.activeChallengeId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _activeChallenge != null) {
          showDirections(_activeChallenge!);
        }
      });
    }

    if (oldWidget.challenges != widget.challenges ||
        oldWidget.activeChallengeId != widget.activeChallengeId ||
        oldWidget.completedChallengeIds != widget.completedChallengeIds) {
      _ensureCustomPins();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final mapStyle = brightness == Brightness.dark
        ? darkMapStyle
        : lightMapStyle;

    final markers = _buildMarkers();

    final polylines = _route == null
        ? <Polyline>{}
        : {
            Polyline(
              polylineId: const PolylineId('active-route'),
              points: _route!.points,
              color: AppColors.primary,
              width: 6,
              patterns: [PatternItem.dash(24), PatternItem.gap(12)],
            ),
          };

    if (widget.navigationMode &&
        _activeChallenge != null &&
        !_loadingRoute &&
        _routingChallenge?.id != _activeChallenge!.id &&
        _route == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _activeChallenge != null) {
          showDirections(_activeChallenge!);
        }
      });
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(42.7339, 25.4858),
            zoom: _initialZoom,
          ),
          style: mapStyle,
          onMapCreated: (controller) {
            _controller = controller;
            _refreshUserLocation();
          },
          onCameraMove: (position) => _pendingZoom = position.zoom,
          onCameraIdle: _handleCameraIdle,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          markers: markers,
          polylines: polylines,
        ),
        if (_loadingRoute && _routingChallenge != null)
          const Positioned(
            left: 24,
            right: 24,
            bottom: 92,
            child: LinearProgressIndicator(minHeight: 4),
          ),
        if (!widget.navigationMode)
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: AppColors.primary,
              onPressed: _centerOnUser,
              child: const Icon(Icons.my_location_outlined),
            ),
          ),
      ],
    );
  }

  Set<Marker> _buildMarkers() {
    final items = _clusteredItems();
    return items.map(_markerForItem).toSet();
  }

  Marker _markerForItem(_RenderedMapItem item) {
    if (item.cluster != null) {
      return Marker(
        markerId: MarkerId(item.id),
        position: item.position,
        icon: _customIcons[item.iconKey] ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(.5, .5),
        zIndexInt: 2,
        onTap: () => _handleClusterTap(item.cluster!),
      );
    }

    final challenge = item.challenge!;
    return Marker(
      markerId: MarkerId(challenge.id),
      position: item.position,
      infoWindow: InfoWindow(
        title: challenge.title,
        snippet: '+${challenge.points} pts',
      ),
      anchor: const Offset(0.5, 1.0),
      icon: _markerIconFor(challenge),
      onTap: () => _handlePinTap(challenge),
    );
  }

  List<_RenderedMapItem> _clusteredItems() {
    if (widget.navigationMode || _zoom > _clusterMaxZoom) {
      return widget.challenges
          .map(
            (challenge) => _RenderedMapItem.challenge(
              challenge: challenge,
              position: LatLng(challenge.latitude, challenge.longitude),
            ),
          )
          .toList();
    }

    final activeId = widget.activeChallengeId;
    final buckets = <String, _ClusterBucket>{};
    final items = <_RenderedMapItem>[];

    for (final challenge in widget.challenges) {
      if (challenge.id == activeId) {
        items.add(
          _RenderedMapItem.challenge(
            challenge: challenge,
            position: LatLng(challenge.latitude, challenge.longitude),
          ),
        );
        continue;
      }

      final point = _project(
        LatLng(challenge.latitude, challenge.longitude),
        _zoom,
      );
      final bucketX = (point.dx / _clusterCellSizePx).floor();
      final bucketY = (point.dy / _clusterCellSizePx).floor();
      final key = '$bucketX:$bucketY';
      (buckets[key] ??= _ClusterBucket())..add(challenge, point);
    }

    final userPoint = _userLocation == null
        ? null
        : _project(_userLocation!, _zoom);

    for (final bucket in buckets.values) {
      if (bucket.challenges.length == 1) {
        final challenge = bucket.challenges.first;
        items.add(
          _RenderedMapItem.challenge(
            challenge: challenge,
            position: LatLng(challenge.latitude, challenge.longitude),
          ),
        );
        continue;
      }

      var clusterPoint = Offset(
        bucket.sumX / bucket.challenges.length,
        bucket.sumY / bucket.challenges.length,
      );

      if (userPoint != null &&
          (clusterPoint - userPoint).distance < _clusterUserAvoidancePx) {
        clusterPoint = Offset(
          clusterPoint.dx,
          clusterPoint.dy - _clusterUserOffsetPx,
        );
      }

      final cluster = _ChallengeCluster(
        challenges: List<Challenge>.unmodifiable(bucket.challenges),
        position: _unproject(clusterPoint, _zoom),
      );

      items.add(
        _RenderedMapItem.cluster(
          cluster: cluster,
          iconKey: _clusterIconKey(cluster.count),
        ),
      );
    }

    return items;
  }

  Future<void> _handleClusterTap(_ChallengeCluster cluster) async {
    final controller = _controller;
    if (controller == null) return;

    final bounds = cluster.bounds;
    final southWest = bounds.southwest;
    final northEast = bounds.northeast;
    final samePoint =
        southWest.latitude == northEast.latitude &&
        southWest.longitude == northEast.longitude;

    if (samePoint) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          cluster.position,
          (_zoom + 1.4).clamp(9, 16).toDouble(),
        ),
      );
      return;
    }

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 72));
  }

  BitmapDescriptor _markerIconFor(Challenge challenge) {
    final style = mapPinStyle(
      challenge: challenge,
      isActive: challenge.id == widget.activeChallengeId,
      isCompleted: widget.completedChallengeIds.contains(challenge.id),
    );
    return _customIcons[style.key] ?? _defaultMarkerFor(challenge);
  }

  Future<void> _ensureCustomPins() async {
    final version = ++_pinLoadVersion;
    final pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    final icons = <String, BitmapDescriptor>{..._customIcons};

    for (final challenge in widget.challenges) {
      final style = mapPinStyle(
        challenge: challenge,
        isActive: challenge.id == widget.activeChallengeId,
        isCompleted: widget.completedChallengeIds.contains(challenge.id),
      );

      if (icons.containsKey(style.key)) continue;

      try {
        icons[style.key] = await MapPinIconFactory.create(
          style,
          imagePixelRatio: pixelRatio,
        );
      } catch (_) {
        // Fallback stays default marker.
      }
    }

    final clusterCounts = _clusteredItems()
        .where((item) => item.cluster != null)
        .map((item) => item.cluster!.count)
        .toSet();

    for (final count in clusterCounts) {
      final key = _clusterIconKey(count);
      if (icons.containsKey(key)) continue;
      try {
        icons[key] = await MapPinIconFactory.createCluster(
          count,
          imagePixelRatio: pixelRatio,
        );
      } catch (_) {
        // Fallback stays default marker.
      }
    }

    if (!mounted || version != _pinLoadVersion) return;

    setState(() {
      _customIcons
        ..clear()
        ..addAll(icons);
    });
  }

  String _clusterIconKey(int count) => 'cluster-v1-$count';

  void _handleCameraIdle() {
    if ((_pendingZoom - _zoom).abs() < .05) return;
    setState(() {
      _zoom = _pendingZoom;
    });
    _ensureCustomPins();
  }

  BitmapDescriptor _defaultMarkerFor(Challenge challenge) {
    final isCompleted = widget.completedChallengeIds.contains(challenge.id);

    if (isCompleted) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    if (challenge.id == widget.activeChallengeId) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }

    return switch (challenge.difficulty) {
      Difficulty.easy => BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
      Difficulty.medium => BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueOrange,
      ),
      Difficulty.hard => BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
    };
  }

  Challenge? get _activeChallenge {
    final id = widget.activeChallengeId;
    if (id == null) return null;

    for (final challenge in widget.challenges) {
      if (challenge.id == id) return challenge;
    }
    return null;
  }

  void _handlePinTap(Challenge challenge) {
    if (challenge.id == widget.activeChallengeId) {
      widget.onActiveChallenge(challenge);
    } else {
      widget.onInactiveChallenge(challenge);
    }
  }

  Future<void> showDirections(Challenge challenge) async {
    setState(() {
      _routingChallenge = challenge;
      _route = null;
      _loadingRoute = true;
    });

    final origin = await _currentLatLng() ?? const LatLng(42.6977, 23.3219);
    final destination = LatLng(challenge.latitude, challenge.longitude);

    final route = await _directions.route(
      origin: origin,
      destination: destination,
    );

    if (!mounted) return;

    setState(() {
      _route = route;
      _loadingRoute = false;
    });

    final points = route?.points.isNotEmpty == true
        ? route!.points
        : [origin, destination];

    await _fit(points);
  }

  Future<LatLng?> _currentLatLng() async {
    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<void> _refreshUserLocation() async {
    final position = await _currentLatLng();
    if (!mounted || position == null) return;
    setState(() {
      _userLocation = position;
    });
  }

  Future<void> _centerOnUser() async {
    final controller = _controller;
    if (controller == null) return;

    final current = await _currentLatLng();
    if (current == null) return;

    if (!mounted) return;
    setState(() {
      _userLocation = current;
    });

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: current, zoom: 16)),
    );
  }

  Offset _project(LatLng latLng, double zoom) {
    final scale = 256.0 * math.pow(2.0, zoom).toDouble();
    final siny = math
        .sin(latLng.latitude * math.pi / 180.0)
        .clamp(-0.9999, 0.9999);
    final x = (latLng.longitude + 180.0) / 360.0 * scale;
    final y = (.5 - math.log((1 + siny) / (1 - siny)) / (4 * math.pi)) * scale;
    return Offset(x, y);
  }

  LatLng _unproject(Offset point, double zoom) {
    final scale = 256.0 * math.pow(2.0, zoom).toDouble();
    final lng = point.dx / scale * 360.0 - 180.0;
    final mercatorY = math.pi * (1 - 2 * point.dy / scale);
    final latRadians = math.atan(
      (math.exp(mercatorY) - math.exp(-mercatorY)) / 2,
    );
    final lat = latRadians * 180.0 / math.pi;
    return LatLng(lat, lng);
  }

  Future<void> _fit(List<LatLng> points) async {
    final controller = _controller;
    if (controller == null || points.isEmpty) return;

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }
}

class _ClusterBucket {
  final List<Challenge> challenges = [];
  double sumX = 0;
  double sumY = 0;

  void add(Challenge challenge, Offset point) {
    challenges.add(challenge);
    sumX += point.dx;
    sumY += point.dy;
  }
}

class _RenderedMapItem {
  _RenderedMapItem.challenge({
    required Challenge challenge,
    required LatLng position,
  }) : challenge = challenge,
       position = position,
       cluster = null,
       iconKey = null,
       id = challenge.id;

  _RenderedMapItem.cluster({
    required _ChallengeCluster cluster,
    required String iconKey,
  }) : challenge = null,
       cluster = cluster,
       position = cluster.position,
       iconKey = iconKey,
       id = 'cluster-${cluster.id}';

  final String id;
  final Challenge? challenge;
  final _ChallengeCluster? cluster;
  final LatLng position;
  final String? iconKey;
}

class _ChallengeCluster {
  const _ChallengeCluster({required this.challenges, required this.position});

  final List<Challenge> challenges;
  final LatLng position;

  int get count => challenges.length;

  String get id => challenges.map((challenge) => challenge.id).join('_');

  LatLngBounds get bounds {
    var minLat = challenges.first.latitude;
    var maxLat = challenges.first.latitude;
    var minLng = challenges.first.longitude;
    var maxLng = challenges.first.longitude;

    for (final challenge in challenges.skip(1)) {
      if (challenge.latitude < minLat) minLat = challenge.latitude;
      if (challenge.latitude > maxLat) maxLat = challenge.latitude;
      if (challenge.longitude < minLng) minLng = challenge.longitude;
      if (challenge.longitude > maxLng) maxLng = challenge.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

const lightMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      { "color": "#eef2f7" }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#8d97aa" }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#eef2f7" }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#d7deea" }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#c8d2e1" },
      { "weight": 1.2 }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#7f8aa0" }
    ]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [
      { "color": "#eef2f7" }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      { "color": "#e8edf4" }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      { "color": "#ffffff" }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      { "color": "#f8faff" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      { "color": "#f3f6fb" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#dde5f0" }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      { "color": "#dde7f2" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#95a2b6" }
    ]
  }
]
''';

const darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      { "color": "#0f1728" }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#8f9cb4" }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#0f1728" }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#25324a" }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#31415f" },
      { "weight": 1.1 }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#a5b1c6" }
    ]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [
      { "color": "#111b2d" }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      { "color": "#13243a" }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      { "color": "#1e2b44" }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      { "color": "#22324f" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      { "color": "#2a3b5d" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#34486d" }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      { "color": "#0b1220" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#6f819d" }
    ]
  }
]
''';
