import 'package:flutter/material.dart';

/// Game-style "System" color tokens matching the web app style.css
class AppColors {
  AppColors._();

  // Dark Canvas Backgrounds
  static const Color bgMain = Color(0xFF060913);
  static const Color bgSidebar = Color(0xFF0B0F19);
  static const Color bgCard = Color(0x99121929); // rgba(18, 25, 41, 0.6)
  static const Color bgCardSolid = Color(0xFF121929);
  static const Color bgCardHover = Color(0xD91A243B); // rgba(26, 36, 59, 0.85)

  // Electric Cyan (Primary)
  static const Color primary = Color(0xFF22D3EE);
  static const Color primaryGlow = Color(0x5922D3EE); // 35% glow
  static const Color primaryMuted = Color(0x1F22D3EE); // 12% muted

  // System Violet (Secondary - Rank / Level Accent)
  static const Color secondary = Color(0xFFA855F7);
  static const Color secondaryGlow = Color(0x59A855F7);
  static const Color secondaryMuted = Color(0x1FA855F7);

  // Status & Utility Accents
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successGlow = Color(0x4D10B981);
  static const Color successMuted = Color(0x1A10B981);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningGlow = Color(0x4DF59E0B);
  static const Color warningMuted = Color(0x1AF59E0B);

  static const Color danger = Color(0xFFEF4444); // Rose
  static const Color dangerGlow = Color(0x4DEF4444);
  static const Color dangerMuted = Color(0x1AEF4444);

  static const Color orange = Color(0xFFF97316); // Streak / Discipline
  static const Color orangeGlow = Color(0x4DF97316);
  static const Color orangeMuted = Color(0x1AF97316);

  // Borders
  static const Color border = Color(0x245EEAFF); // rgba(94, 234, 255, 0.14)
  static const Color borderHover = Color(0x615EEAFF); // rgba(94, 234, 255, 0.38)

  // Typography
  static const Color textPrimary = Color(0xFFE9F4FB);
  static const Color textSecondary = Color(0xFF93A4C3);
  static const Color textMuted = Color(0xFF5B6B8C);

  // Rank Badges
  static const Color rankE = Color(0xFF64748B);
  static const Color rankD = Color(0xFF0EA5E9);
  static const Color rankC = Color(0xFF10B981);
  static const Color rankB = Color(0xFFF59E0B);
  static const Color rankA = Color(0xFFA855F7);
  static const Color rankS = Color(0xFF22D3EE);
}
