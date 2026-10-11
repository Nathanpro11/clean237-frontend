import 'package:flutter/material.dart';

/// Centralized color palette for Clean237 Admin.
abstract final class AppColors {
  // Brand & Accents
  static const Color primaryGreen = Color(0xFF27AE60);
  static const Color primaryGreenLight = Color(0xFFE8F8F0);
  static const Color primaryGreenDark = Color(0xFF1E8449);

  // Background & Surfaces
  static const Color background = Color(0xFFF5F7FB);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE7ECF3);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Alert & Status colors
  static const Color criticalRed = Color(0xFFEB5757);
  static const Color criticalRedLight = Color(0xFFFDF2F2);
  static const Color warningOrange = Color(0xFFF39C12);
  static const Color warningOrangeLight = Color(0xFFFEF5E7);
  static const Color normalGreen = Color(0xFF27AE60);
  static const Color normalGreenLight = Color(0xFFE8F8F0);

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> floatingNavShadow = [
    BoxShadow(
      color: Color(0x120F172A),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
}
