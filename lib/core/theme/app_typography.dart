import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography supporting both Latin and Tamil scripts with proper fallbacks
class AppTypography {
  AppTypography._();

  static const List<String> fontFallbacks = ['Noto Sans Tamil', 'Roboto', 'Arial'];

  // Display style (Level, Big Rank, Rep Counters)
  static TextStyle displayLarge = GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  static TextStyle displayMedium = GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.0,
  );

  // Headings (Screen titles, game sections)
  static TextStyle headingLarge = GoogleFonts.rajdhani(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle headingMedium = GoogleFonts.rajdhani(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  static TextStyle headingSmall = GoogleFonts.rajdhani(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  // Body styles (Readable, scales with accessibility settings)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Buttons & Badges
  static TextStyle button = GoogleFonts.rajdhani(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
  );

  static TextStyle badge = GoogleFonts.orbitron(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}
