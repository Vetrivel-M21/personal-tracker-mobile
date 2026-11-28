import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class ExpBar extends StatelessWidget {
  final int xpIntoLevel;
  final int xpForNextLevel;

  const ExpBar({
    super.key,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = xpForNextLevel > 0
        ? (xpIntoLevel / xpForNextLevel).clamp(0.0, 1.0)
        : 0.0;
    final reduce = AppMotion.reduceMotion(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXP PROGRESS',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '$xpIntoLevel / $xpForNextLevel XP',
              style: AppTypography.badge.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 8,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: AppSpacing.roundedFull,
            border: Border.all(color: AppColors.border),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: percent),
            duration: reduce ? Duration.zero : AppMotion.ring,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppSpacing.roundedFull,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
