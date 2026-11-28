import 'package:flutter/material.dart';

/// Premium Dark UI + Athletic Minimalism color tokens.
/// 3-step near-black elevation (lighter = higher), 1px white hairlines (~8%),
/// cyan as single interactive accent, violet for rank/level only, gold for achievements only.
class AppColors {
  AppColors._();

  // Near-Black Canvas & 3-Step Elevation Surfaces (lighter = higher)
  static const Color bgMain = Color(0xFF080A0F); // Canvas (0dp)
  static const Color surface1 = Color(0xFF11151E); // Primary cards, list tiles (1dp)
  static const Color surface2 = Color(0xFF181E2A); // Raised cards, inputs, bottom nav (2dp)
  static const Color surface3 = Color(0xFF202838); // Modals, sheets, active pills (3dp)

  // Legacy surface aliases (kept for compatibility across phases)
  static const Color bgSidebar = surface1;
  static const Color bgCard = Color(0xCC11151E);
  static const Color bgCardSolid = surface1;
  static const Color bgCardHover = surface2;
  static const Color navBarBg = surface2;

  // Hairline Borders (~8% white resting, ~14% white focus/active)
  static const Color border = Color(0x14FFFFFF);
  static const Color borderStrong = Color(0x24FFFFFF);
  static const Color borderHover = borderStrong;

  // Single Interactive Accent (Electric Cyan — solid fills only)
  static const Color primary = Color(0xFF22D3EE);
  static const Color onPrimary = Color(0xFF080A0F);
  static const Color primaryGlow = Color(0x4022D3EE); // Earned moments only
  static const Color primaryMuted = Color(0x1A22D3EE); // 10% subtle tint

  // Rank / Level Accent (Violet — strictly for LevelBadge, RankBadge, rank/level-up)
  static const Color rankViolet = Color(0xFFA855F7);
  static const Color secondary = rankViolet;
  static const Color secondaryGlow = Color(0x40A855F7);
  static const Color secondaryMuted = Color(0x1AA855F7);

  // Achievement Accent (Gold — strictly for PRs, achievements, streak milestones)
  static const Color gold = Color(0xFFF59E0B);
  static const Color accentGold = gold;

  // Status & Semantic Accents
  static const Color success = Color(0xFF10B981);
  static const Color successGlow = Color(0x4010B981);
  static const Color successMuted = Color(0x1A10B981);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningGlow = Color(0x40F59E0B);
  static const Color warningMuted = Color(0x1AF59E0B);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerGlow = Color(0x40EF4444);
  static const Color dangerMuted = Color(0x1AEF4444);

  static const Color accentGreen = success;
  static const Color accentRed = danger;

  static const Color orange = Color(0xFFF97316); // Streak / Discipline
  static const Color orangeGlow = Color(0x40F97316);
  static const Color orangeMuted = Color(0x1AF97316);

  // Earned-moment glow ONLY (level-up, rank-up, streak milestone)
  static BoxShadow earnedGlow(Color color) {
    return BoxShadow(
      color: color.withValues(alpha: 0.28),
      blurRadius: 16,
      spreadRadius: 0,
    );
  }

  static BoxShadow glowShadow(Color color) => earnedGlow(color);

  // Typography (WCAG AA >= 4.5:1 on #11151E and #080A0F)
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF7E8DA6);

  // Rank Badges
  static const Color rankE = Color(0xFF7E8DA6);
  static const Color rankD = Color(0xFF0EA5E9);
  static const Color rankC = Color(0xFF10B981);
  static const Color rankB = gold;
  static const Color rankA = rankViolet;
  static const Color rankS = primary;

  // Leaderboard Podium & Neutral Helpers
  static const Color rankSilver = Color(0xFFE2E8F0);
  static const Color rankBronze = Color(0xFFCD7F32);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
