import 'package:flutter/services.dart';

class AppConfigService {
  static const _channel = MethodChannel('geoquest/config');

  static Future<String> googleMapsApiKey() async {
    const fromDefine = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    try {
      return await _channel.invokeMethod<String>('googleMapsApiKey') ?? '';
    } catch (_) {
      return '';
    }
  }
}
