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

  static TextStyle titleMedium = GoogleFonts.rajdhani(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
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

  static TextStyle labelLarge = GoogleFonts.rajdhani(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = GoogleFonts.rajdhani(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.textMuted,
  );

  static TextStyle badge = GoogleFonts.orbitron(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // Tokenized inline styles (Phase 1 cleanup — preserves exact visual output)
  static const TextStyle rawOnPrimary = TextStyle(color: AppColors.bgMain);
  static const TextStyle rawOnPrimaryBold = TextStyle(
    color: AppColors.bgMain,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle rawBold = TextStyle(fontWeight: FontWeight.bold);
  static const TextStyle rawPrimaryBold = TextStyle(
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle rawDangerText = TextStyle(color: AppColors.danger);
  static const TextStyle rawDangerSmall = TextStyle(
    color: AppColors.danger,
    fontSize: 12,
  );
  static const TextStyle rawTextPrimary = TextStyle(color: AppColors.textPrimary);
  static const TextStyle rawTextSecondary = TextStyle(color: AppColors.textSecondary);
  static const TextStyle rawTextMuted = TextStyle(color: AppColors.textMuted);
  static const TextStyle rawHintMicro = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
  );
  static const TextStyle rawEmojiSmall = TextStyle(fontSize: 14);
  static const TextStyle rawPrefixBullet = TextStyle(
    color: AppColors.primary,
    fontSize: 12,
  );
  static const TextStyle rawPoseAngle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    backgroundColor: AppColors.bgCardSolid,
  );

  static TextStyle rawChipLabel(Color color) => TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      );

  static TextStyle rawChipLabelDefault(Color color) => TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
      );
}

