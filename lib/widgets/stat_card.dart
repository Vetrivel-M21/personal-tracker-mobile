import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? sublabel;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    this.iconColor = AppColors.primary,
    required this.label,
    required this.value,
    this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: AppColors.surface1,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedMd,
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.roundedMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTypography.statNumber.copyWith(fontSize: 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sublabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sublabel!,
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return onTap != null ? AppPressable(onTap: onTap, child: card) : card;
  }
}
