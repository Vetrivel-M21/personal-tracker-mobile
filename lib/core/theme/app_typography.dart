import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography: Inter for all UI/body/headings with tabular figures for stats,
/// Orbitron strictly for level numbers, and Noto Sans Tamil fallback for Tamil script.
class AppTypography {
  AppTypography._();

  static const List<String> fontFallbacks = ['Noto Sans Tamil', 'Roboto', 'sans-serif'];
  static const List<FontFeature> tabularFeatures = [FontFeature.tabularFigures()];

  // Level Number ONLY (Orbitron)
  static TextStyle levelNumber = GoogleFonts.orbitron(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
    height: 1.2,
  ).copyWith(fontFamilyFallback: fontFallbacks, fontFeatures: tabularFeatures);

  // Numeric Stat Readouts (Inter + tabular figures)
  static TextStyle statNumber = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  ).copyWith(fontFamilyFallback: fontFallbacks, fontFeatures: tabularFeatures);

  // Display styles (Inter + tabular figures)
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  ).copyWith(fontFamilyFallback: fontFallbacks, fontFeatures: tabularFeatures);

  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  ).copyWith(fontFamilyFallback: fontFallbacks, fontFeatures: tabularFeatures);

  // Headings (Inter, generous line height for Tamil & 1.3x font scale)
  static TextStyle headingLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  static TextStyle headingMedium = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  static TextStyle headingSmall = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.35,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  // Body styles (Readable, scales with accessibility settings)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  // Buttons & Labels
  static TextStyle button = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.25,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.25,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.3,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textMuted,
    height: 1.3,
  ).copyWith(fontFamilyFallback: fontFallbacks);

  static TextStyle badge = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    height: 1.25,
  ).copyWith(fontFamilyFallback: fontFallbacks, fontFeatures: tabularFeatures);

  // Tokenized inline styles (Phase 1 cleanup, now inheriting Inter + Tamil fallback)
  static TextStyle get rawOnPrimary => button.copyWith(color: AppColors.onPrimary);
  static TextStyle get rawOnPrimaryBold =>
      button.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700);
  static TextStyle get rawBold => button.copyWith(fontWeight: FontWeight.w700);
  static TextStyle get rawPrimaryBold =>
      button.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700);
  static TextStyle get rawDangerText => bodyMedium.copyWith(color: AppColors.danger);
  static TextStyle get rawDangerSmall => bodySmall.copyWith(color: AppColors.danger);
  static TextStyle get rawTextPrimary => bodyMedium.copyWith(color: AppColors.textPrimary);
  static TextStyle get rawTextSecondary => bodyMedium.copyWith(color: AppColors.textSecondary);
  static TextStyle get rawTextMuted => bodyMedium.copyWith(color: AppColors.textMuted);
  static TextStyle get rawHintMicro => bodySmall.copyWith(color: AppColors.textMuted);
  static const TextStyle rawEmojiSmall = TextStyle(fontSize: 14);
  static TextStyle get rawPrefixBullet => bodySmall.copyWith(color: AppColors.primary);
  static TextStyle get rawPoseAngle => labelMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        backgroundColor: AppColors.surface1,
      ).copyWith(fontFeatures: tabularFeatures);

  static TextStyle rawChipLabel(Color color) => labelSmall.copyWith(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  static TextStyle rawChipLabelDefault(Color color) => labelMedium.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      );
}
