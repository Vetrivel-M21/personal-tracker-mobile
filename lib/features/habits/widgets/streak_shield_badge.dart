import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/streak_stats.dart';

class StreakShieldBadge extends StatelessWidget {
  final StreakStats stats;

  const StreakShieldBadge({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStreakCounter(),
          _buildShieldInventory(),
        ],
      ),
    );
  }

  Widget _buildStreakCounter() {
    return Row(
      children: [
        const Icon(Icons.local_fire_department, color: AppColors.orange, size: 28),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stats.currentStreak} DAYS',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Current Streak', style: AppTypography.labelSmall),
          ],
        ),
      ],
    );
  }

  Widget _buildShieldInventory() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${stats.shieldsRemaining} / 3 SHIELDS',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Auto-protection', style: AppTypography.labelSmall),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),
        Row(
          children: List.generate(3, (index) {
            final isBanked = index < stats.shieldsRemaining;
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                isBanked ? Icons.shield : Icons.shield_outlined,
                color: isBanked ? AppColors.primary : AppColors.textMuted,
                size: 22,
              ),
            );
          }),
        ),
      ],
    );
  }
}

