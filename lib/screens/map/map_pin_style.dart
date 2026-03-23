import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/geo_models.dart';
import '../../theme/app_theme.dart';
import 'map_filters.dart';

enum MapPinVisualState { defaultPin, active, completed }

class MapPinStyleData {
  const MapPinStyleData({
    required this.fillColor,
    required this.iconColor,
    required this.icon,
    required this.visualState,
    required this.key,
    this.glowColor,
  });

  final Color fillColor;
  final Color iconColor;
  final IconData icon;
  final MapPinVisualState visualState;
  final String key;
  final Color? glowColor;
}

MapPinStyleData mapPinStyle({
  required Challenge challenge,
  required bool isActive,
  required bool isCompleted,
}) {
  final category = normalizeCategory(challenge.category);
  final icon = switch (category) {
    'Cultural' => Icons.account_balance,
    'Nature' => Icons.park_outlined,
    'Historical' => Icons.castle_outlined,
    'Adventure' => Icons.landscape_outlined,
    _ => Icons.place_outlined,
  };

  if (isCompleted) {
    return MapPinStyleData(
      fillColor: const Color(0xFFC9D0DB),
      iconColor: const Color(0xFF8C97A8),
      icon: Icons.check_rounded,
      visualState: MapPinVisualState.completed,
      key: 'v7-completed-$category',
    );
  }

  final baseColor = switch (challenge.difficulty) {
    Difficulty.easy => const Color(0xFF10B981),
    Difficulty.medium => const Color(0xFFF59E0B),
    Difficulty.hard => const Color(0xFFEF4444),
  };

  if (isActive) {
    return MapPinStyleData(
      fillColor: baseColor,
      iconColor: const Color(0xFF475569),
      icon: icon,
      visualState: MapPinVisualState.active,
      key: 'v8-active-$category-${challenge.difficulty.name}',
      glowColor: baseColor,
    );
  }

  return MapPinStyleData(
    fillColor: baseColor,
    iconColor: const Color(0xFF475569),
    icon: icon,
    visualState: MapPinVisualState.defaultPin,
    key: 'v7-default-$category-${challenge.difficulty.name}',
  );
}

class MapPinIconFactory {
  MapPinIconFactory._();

  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> create(
    MapPinStyleData style, {
    double imagePixelRatio = 1,
  }) async {
    final cached = _cache[style.key];
    if (cached != null) return cached;

    // Real marker size.
    const logicalWidth = 40.0;
    const logicalHeight = 52.0;

    // Increase sharpness by rendering at higher scale,
    // not by inflating the logical width.
    final scale = math.max(3.0, imagePixelRatio);
    final pixelWidth = (logicalWidth * scale).round();
    final pixelHeight = (logicalHeight * scale).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.scale(scale, scale);
    _paintPin(canvas, style, const Size(logicalWidth, logicalHeight));

    final picture = recorder.endRecording();
    final image = await picture.toImage(pixelWidth, pixelHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final descriptor = BytesMapBitmap(
      bytes,
      imagePixelRatio: scale,
      width: logicalWidth,
      height: logicalHeight,
      bitmapScaling: MapBitmapScaling.auto,
    );

    _cache[style.key] = descriptor;
    return descriptor;
  }

  static Future<BitmapDescriptor> createCluster(
    int count, {
    double imagePixelRatio = 1,
  }) async {
    final key = 'cluster-v1-$count';
    final cached = _cache[key];
    if (cached != null) return cached;

    final digits = count.toString().length;
    final logicalSize = switch (digits) {
      1 => 52.0,
      2 => 56.0,
      _ => 60.0,
    };

    final scale = math.max(3.0, imagePixelRatio);
    final pixelSize = (logicalSize * scale).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(scale, scale);
    _paintCluster(canvas, logicalSize, count.toString());

    final picture = recorder.endRecording();
    final image = await picture.toImage(pixelSize, pixelSize);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final descriptor = BytesMapBitmap(
      bytes,
      imagePixelRatio: scale,
      width: logicalSize,
      height: logicalSize,
      bitmapScaling: MapBitmapScaling.auto,
    );

    _cache[key] = descriptor;
    return descriptor;
  }

  static void clear() => _cache.clear();

  static void _paintPin(Canvas canvas, MapPinStyleData style, Size size) {
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;

    const circleCenterY = 17.0;
    const outerRadius = 15.4;
    const innerRadius = 10.9;

    final tailBottomY = height;

    // Base triangle definition (before scaling)
    const baseWidth = 13.6; // was 12.5
    const baseHeight = 35.0; // controls height (angle)

    // Scale factor → keeps angle identical, just makes it bigger
    const scale = 1.15; // tweak between 1.15–1.25

    final topHalfWidth = baseWidth * scale;

    // Keep triangle from going too deep into the circle
    final triangleTopY = math.max(
      circleCenterY + 1.0,
      tailBottomY - (baseHeight * scale),
    );

    if (style.glowColor != null) {
      final glowRect = Rect.fromCircle(
        center: Offset(centerX, circleCenterY + 1),
        radius: 24,
      );
      canvas.drawCircle(
        Offset(centerX, circleCenterY + 1),
        24,
        Paint()
          ..shader = ui.Gradient.radial(
            glowRect.center,
            24,
            [
              style.glowColor!.withValues(alpha: .55), // was .42
              style.glowColor!.withValues(alpha: .28), // was .18
              style.glowColor!.withValues(alpha: .10), // was .05
              Colors.transparent,
            ],
            const [0, .5, .85, 1],
          ),
      );
    }

    // Symmetric triangle (no arcTo → no offset issues)
    final pinPath = Path()
      ..moveTo(centerX, tailBottomY)
      ..lineTo(centerX - topHalfWidth, triangleTopY)
      ..lineTo(centerX + topHalfWidth, triangleTopY)
      ..close();

    canvas.drawShadow(pinPath, Colors.black.withValues(alpha: .18), 4, false);
    canvas.drawPath(pinPath, Paint()..color = style.fillColor);

    // Outer circle (kept as requested — drawn twice for blending)
    canvas.drawCircle(
      Offset(centerX, circleCenterY),
      outerRadius,
      Paint()..color = style.fillColor,
    );

    canvas.drawCircle(
      Offset(centerX, circleCenterY),
      innerRadius,
      Paint()..color = Colors.white,
    );

    final painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(style.icon.codePoint),
        style: TextStyle(
          fontSize: 14,
          fontFamily: style.icon.fontFamily,
          package: style.icon.fontPackage,
          color: style.iconColor,
        ),
      )
      ..layout();

    painter.paint(
      canvas,
      Offset(centerX - painter.width / 2, circleCenterY - painter.height / 2),
    );
  }

  static void _paintCluster(Canvas canvas, double size, String label) {
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - 4;
    final outerRect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.linear(
          outerRect.topLeft,
          outerRect.bottomRight,
          AppColors.purpleGradient.colors,
        ),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white.withValues(alpha: .92),
    );

    canvas.drawCircle(
      Offset(center.dx - radius * .2, center.dy - radius * .25),
      radius * .48,
      Paint()..color = Colors.white.withValues(alpha: .12),
    );

    final painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: label.length >= 3 ? 16 : 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -.4,
          shadows: const [
            Shadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
      )
      ..layout();

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }
}
