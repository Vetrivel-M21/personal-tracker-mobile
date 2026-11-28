import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_icons.dart';
import '../core/theme/app_motion.dart';
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
    return AppPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      enableHaptics: false,
      child: Material(
        color: isCompleted ? AppColors.successMuted : AppColors.surface1,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedMd,
          side: BorderSide(
            color: isCompleted
                ? AppColors.success.withValues(alpha: 0.45)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onToggle();
          },
          borderRadius: AppSpacing.roundedMd,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DAILY QUEST',
                          style: AppTypography.labelSmall.copyWith(
                            color: isCompleted ? AppColors.success : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.successMuted : AppColors.primaryMuted,
                      borderRadius: AppSpacing.roundedFull,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCompleted) ...[
                          const Icon(AppIcons.check, size: 14, color: AppColors.success),
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
        ),
      ),
    );
  }
}
