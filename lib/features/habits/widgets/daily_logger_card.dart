import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/daily_progress.dart';

class DailyLoggerCard extends StatelessWidget {
  final DailyProgress progress;
  final ValueChanged<double> onHoursChanged;
  final ValueChanged<String> onMoodChanged;

  const DailyLoggerCard({
    super.key,
    required this.progress,
    required this.onHoursChanged,
    required this.onMoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Reflection & Focus', style: AppTypography.titleMedium),
              _buildHoursCounter(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('HOW WAS YOUR ENERGY TODAY?', style: AppTypography.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          _buildMoodChips(),
        ],
      ),
    );
  }

  Widget _buildHoursCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondaryMuted,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (progress.learningHours >= 0.5) {
                onHoursChanged(progress.learningHours - 0.5);
              }
            },
            child: const Icon(Icons.remove, size: 16, color: AppColors.secondary),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${progress.learningHours.toStringAsFixed(1)} hrs',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () => onHoursChanged(progress.learningHours + 0.5),
            child: const Icon(Icons.add, size: 16, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChips() {
    final moods = ['Great', 'Good', 'Average', 'Bad'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((m) {
        final isSelected = progress.mood == m;
        return InkWell(
          onTap: () => onMoodChanged(m),
          borderRadius: AppSpacing.roundedSm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryMuted : AppColors.bgMain,
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              m,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

