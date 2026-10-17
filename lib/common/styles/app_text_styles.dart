import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized text styles matching the Clean237 Figma mockup.
abstract final class AppTextStyles {
  /// Green subtitle e.g. "Clean237 · Administration"
  static TextStyle headerSubtitle = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryGreen,
    letterSpacing: 0.1,
  );

  /// Main screen titles e.g. "Tableau de bord", "Zones", "Rapports"
  static TextStyle pageTitle = GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Section headers e.g. "Zones à surveiller", "Vos rapports"
  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// Green uppercase section label e.g. "ALERTES RÉCENTES"
  static TextStyle sectionLabelGreen = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryGreen,
    letterSpacing: 0.8,
  );

  /// Card primary titles e.g. "Mfoundi Centre", "Zones actives"
  static TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  /// Metric numbers (large) e.g. "12", "2", "7", "4"
  static TextStyle metricNumber = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  /// Big score on zone detail e.g. "42", "61"
  static TextStyle scoreLarge = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  /// Huge score for Analysis page
  static TextStyle scoreGiant = GoogleFonts.poppins(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1,
  );

  /// Secondary helper text e.g. "4 nouvelles aujourd'hui", "il y a 12 min"
  static TextStyle bodySecondary = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Body text e.g. interpretation paragraph
  static TextStyle body = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  /// Badge text (capsules)
  static TextStyle badge = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  /// Button text (primary green button)
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  /// Navigation bar labels
  static TextStyle navLabel = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
}
