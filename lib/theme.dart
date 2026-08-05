import 'package:flutter/material.dart';

class RoadCareColors {
  static const Color primary = Color(0xFF2563EB); // Vibrant Brand Blue
  static const Color primaryDark = Color(0xFF1E3A8A); // Deep Blue
  static const Color accentOrange = Color(0xFF9E4300); // Warm Accent Orange
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color onPrimaryContainer = Color(0xFF1E40AF);
  static const Color background = Color(0xFFF8FAFC); // Clean Blue-White background
  static const Color surface = Colors.white;
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color surfaceVariant = Color(0xFFE2E8F0);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color outline = Color(0xFF94A3B8);
  static const Color neutral = Color(0xFF64748B);
  static const Color error = Color(0xFFDC2626);
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

