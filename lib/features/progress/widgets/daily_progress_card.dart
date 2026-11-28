import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../habits/providers/habits_provider.dart';
import '../providers/progress_provider.dart';

class DailyProgressCard extends ConsumerWidget {
  const DailyProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsState = ref.watch(habitsNotifierProvider);
    final progressState = ref.watch(dailyProgressNotifierProvider);
    final progress = progressState.progress;

    final totalHabits = habitsState.habits.length;
    final completedHabitIds = habitsState.todayProgress.completedHabitIds;
    final completedCount = completedHabitIds.length;
    final habitRatio = totalHabits > 0 ? (completedCount / totalHabits).clamp(0.0, 1.0) : 0.0;

    final currentMood = progress?.mood ?? 'Good';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'DAILY PROGRESS HUB',
                    style: AppTypography.badge.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showJournalModal(context, ref, progress?.notes ?? '', progress?.learningHours ?? 0.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Journal', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Completion Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Habit Protocol Completion',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                '$completedCount / $totalHabits Done',
                style: AppTypography.badge.copyWith(
                  color: completedCount == totalHabits && totalHabits > 0
                      ? AppColors.accentGreen
                      : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: habitRatio,
              backgroundColor: AppColors.bgSidebar,
              valueColor: AlwaysStoppedAnimation<Color>(
                completedCount == totalHabits && totalHabits > 0
                    ? AppColors.accentGreen
                    : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Mood & Condition Tracker Row
          Row(
            children: [
              Text(
                'Status: ',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoodChip(ref, 'Great', '⚡ Great', currentMood == 'Great'),
                    _buildMoodChip(ref, 'Good', '🔥 Good', currentMood == 'Good'),
                    _buildMoodChip(ref, 'Average', '🛡️ Avg', currentMood == 'Average'),
                    _buildMoodChip(ref, 'Bad', '💤 Low', currentMood == 'Bad'),
                  ],
                ),
              ),
            ],
          ),

          if (progress?.notes.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.bgSidebar,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '📝 "${progress!.notes}"',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodChip(WidgetRef ref, String moodValue, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(dailyProgressNotifierProvider.notifier).updateMood(moodValue);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  void _showJournalModal(
    BuildContext context,
    WidgetRef ref,
    String initialNotes,
    double initialHours,
  ) {
    final notesController = TextEditingController(text: initialNotes);
    final hoursController = TextEditingController(
      text: initialHours > 0 ? initialHours.toString() : '1.0',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCardSolid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('DAILY JOURNAL & FOCUS', style: AppTypography.headingMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Record training hours, study sessions, and daily notes.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: hoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Focused Training / Learning Hours',
                  labelStyle: AppTypography.labelSmall,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: notesController,
                maxLines: 3,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Daily Reflection / Notes',
                  labelStyle: AppTypography.labelSmall,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final hours = double.tryParse(hoursController.text) ?? 0.0;
                  final currentMood = ref.read(dailyProgressNotifierProvider).progress?.mood ?? 'Good';
                  ref.read(dailyProgressNotifierProvider.notifier).logJournal(
                        learningHours: hours,
                        notes: notesController.text.trim(),
                        mood: currentMood,
                      );
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'SAVE PROGRESS',
                  style: AppTypography.button.copyWith(color: AppColors.bgMain),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
