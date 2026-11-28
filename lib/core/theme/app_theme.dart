import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgMain,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.rankViolet,
        surface: AppColors.surface1,
        surfaceContainerHigh: AppColors.surface2,
        surfaceContainerHighest: AppColors.surface3,
        error: AppColors.danger,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgMain,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headingMedium,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface1,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedMd,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface3,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedLg,
          side: const BorderSide(color: AppColors.borderStrong, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface3,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.roundedMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedMd,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        labelStyle: AppTypography.bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderStrong, width: 1),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface2,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
