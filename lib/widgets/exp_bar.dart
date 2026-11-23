import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXP PROGRESS',
              style: AppTypography.headingSmall.copyWith(fontSize: 12),
            ),
            Text(
              '$xpIntoLevel / $xpForNextLevel XP',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgMain,
            borderRadius: AppSpacing.roundedFull,
            border: Border.all(color: AppColors.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * percent,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: AppSpacing.roundedFull,
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.primaryGlow,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
