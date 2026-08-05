import 'package:flutter/material.dart';

class RoadCareColors {
  static const Color primary = Color(0xFF9E4300);
  static const Color primaryDark = Color(0xFF7A3300);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFFF7000);
  static const Color onPrimaryContainer = Color(0xFF592300);
  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Colors.white;
  static const Color surfaceContainer = Color(0xFFF3F3F4);
  static const Color surfaceVariant = Color(0xFFE5E7EB);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF594236);
  static const Color outline = Color(0xFF8D7164);
  static const Color neutral = Color(0xFF5B5F64);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color brandNavy = Color(0xFF0F172A);
  static const Color brandBlue = Color(0xFF1E40C9);
}

class RoadCareTextStyles {
  static const TextStyle headline = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: RoadCareColors.onSurface,
    height: 1.1,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: RoadCareColors.onSurface,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: RoadCareColors.onSurfaceVariant,
    height: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: RoadCareColors.onPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: RoadCareColors.neutral,
    letterSpacing: 0.5,
  );
}

