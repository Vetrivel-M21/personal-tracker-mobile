import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class QuestCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int xpReward;
  final bool isCompleted;
  final VoidCallback onToggle;

  const QuestCard({
    super.key,
    required this.icon,
    this.iconColor = AppColors.primary,
    required this.title,
    this.xpReward = 10,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: AppSpacing.roundedMd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.successMuted : AppColors.bgCardSolid,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(
              color: isCompleted ? AppColors.success : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY QUEST',
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: 10,
                        color: isCompleted ? AppColors.success : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isCompleted ? AppColors.textPrimary : AppColors.textPrimary,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.primaryMuted,
                  borderRadius: AppSpacing.roundedFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompleted) ...[
                      const Icon(Icons.check, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      '+$xpReward XP',
                      style: AppTypography.badge.copyWith(
                        color: isCompleted ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

