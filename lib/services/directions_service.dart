import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'app_config_service.dart';

class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceText,
    required this.durationText,
  });
  final List<LatLng> points;
  final String distanceText;
  final String durationText;
}

class DirectionsService {
  const DirectionsService();

  Future<RouteResult?> route({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final key = await AppConfigService.googleMapsApiKey();
    if (key.isEmpty) return null;
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'walking',
      'key': key,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['status'] != 'OK') return null;
    final route = (json['routes'] as List).first as Map<String, dynamic>;
    final leg = (route['legs'] as List).first as Map<String, dynamic>;
    final polyline = route['overview_polyline']['points'] as String;
    return RouteResult(
      points: decodePolyline(polyline),
      distanceText: leg['distance']['text'] as String,
      durationText: leg['duration']['text'] as String,
    );
  }

  List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      var shift = 0, result = 0, byte = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
