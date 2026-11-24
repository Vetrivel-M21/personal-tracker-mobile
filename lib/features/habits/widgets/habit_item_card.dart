import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/habit.dart';

class HabitItemCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onArchive;

  const HabitItemCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final habitColor = _parseColor(habit.color);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.bgCardSolid : AppColors.bgCard,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: isCompleted ? AppColors.primary : AppColors.border,
          width: isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: isCompleted ? [AppColors.glowShadow(AppColors.primary)] : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        leading: InkWell(
          onTap: onToggle,
          borderRadius: AppSpacing.roundedSm,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary : Colors.transparent,
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(
                color: isCompleted ? AppColors.primary : AppColors.textMuted,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: AppColors.bgMain, size: 20)
                : null,
          ),
        ),
        title: Text(
          habit.name,
          style: AppTypography.bodyMedium.copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: habitColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMuted),
              onPressed: () => _showOptions(context),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCardSolid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: AppColors.warning),
              title:  Text('Archive Habit', style: AppTypography.bodyMedium),
              onTap: () {
                Navigator.of(ctx).pop();
                onArchive();
              },
            ),
          ],
        ),
      ),
    );
  }
}

