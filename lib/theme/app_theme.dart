import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF5B5FF0);
  static const primary2 = Color(0xFF8B5CF6);
  static const magenta = Color(0xFFE6007E);
  static const orange = Color(0xFFFF8A00);
  static const green = Color(0xFF09B77F);
  static const red = Color(0xFFEF4444);
  static const yellow = Color(0xFFFFC400);
  static const ink = Color(0xFF1F2430);
  static const muted = Color(0xFF6B7280);
  static const line = Color(0xFFE8EAF1);
  static const surface = Color(0xFFF7F8FC);
  static const card = Colors.white;

  static const purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primary2],
  );

  static const actionGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF8A19FF), magenta],
  );

  static const fireGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFA000), Color(0xFFFF6B00)],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8A19FF), magenta, Color(0xFFFF5B14)],
  );
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

class AppTextStyles {
  static const title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );
  static const h1 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.15,
    letterSpacing: .5,
  );
  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const h3 = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const body = TextStyle(fontSize: 16, height: 1.55);
  static const small = TextStyle(fontSize: 12, height: 1.35);
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary);
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: scheme,
    cardColor: AppColors.card,
    textTheme: TextTheme(
      titleLarge: AppTextStyles.title.copyWith(color: scheme.onSurface),
      titleMedium: AppTextStyles.h2.copyWith(color: scheme.onSurface),
      titleSmall: AppTextStyles.h3.copyWith(color: scheme.onSurface),
      bodyMedium: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
      bodySmall: AppTextStyles.small.copyWith(color: scheme.onSurfaceVariant),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F1F6),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
    ),
  );
}

ThemeData buildDarkAppTheme() {
  final base = buildAppTheme();
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  );
  return base.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF111827),
    colorScheme: scheme,
    cardColor: const Color(0xFF1F2937),
    textTheme: base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        color: scheme.onSurface,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(color: scheme.onSurface),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        color: const Color(0xFFD1D5DB),
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      fillColor: const Color(0xFF243041),
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF1F2937),
      indicatorColor: Colors.transparent,
    ),
  );
}
