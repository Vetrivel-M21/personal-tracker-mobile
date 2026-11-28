import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Level badge: uses Orbitron strictly for the level number and violet
/// strictly for rank/level identity. Glow appears only on earned moments.
class LevelBadge extends StatelessWidget {
  final int level;
  final bool isEarned;

  const LevelBadge({
    super.key,
    required this.level,
    this.isEarned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.rankViolet.withValues(alpha: 0.16),
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(
          color: AppColors.rankViolet.withValues(alpha: 0.55),
          width: 1,
        ),
        boxShadow: isEarned ? [AppColors.earnedGlow(AppColors.rankViolet)] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LVL ',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.rankViolet,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '$level',
            style: AppTypography.levelNumber.copyWith(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
