import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/habits_provider.dart';
import '../widgets/daily_logger_card.dart';
import '../widgets/habit_item_card.dart';
import '../widgets/streak_shield_badge.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitsNotifierProvider);
    final notifier = ref.read(habitsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('Habit Tracker', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showAddHabitDialog(context, notifier),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => notifier.loadTodayData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreakShieldBadge(stats: state.streakStats),
                    const SizedBox(height: AppSpacing.lg),
                    DailyLoggerCard(
                      progress: state.todayProgress,
                      onHoursChanged: (hrs) => notifier.updateLearningHours(hrs),
                      onMoodChanged: (mood) => notifier.updateMood(mood),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TODAY\'S HABITS', style: AppTypography.labelMedium),
                        Text(
                          '${state.todayProgress.completedHabitIds.length} / ${state.habits.length} Done',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (state.habits.isEmpty)
                      _buildEmptyHabits(context, notifier)
                    else
                      ...state.habits.map((habit) {
                        final isCompleted =
                            state.todayProgress.completedHabitIds.contains(habit.id);
                        return HabitItemCard(
                          habit: habit,
                          isCompleted: isCompleted,
                          onToggle: () => notifier.toggleHabit(habit.id),
                          onArchive: () => notifier.archiveHabit(habit.id),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyHabits(BuildContext context, HabitsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.playlist_add_check, color: AppColors.textMuted, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text('No habits created yet', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Form daily rituals to level up your discipline.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => _showAddHabitDialog(context, notifier),
            icon: const Icon(Icons.add, color: AppColors.bgMain),
            label: const Text('Create First Habit', style: TextStyle(color: AppColors.bgMain)),
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, HabitsNotifier notifier) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCardSolid,
        title: Text('New Daily Habit', style: AppTypography.titleMedium),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Read 20 mins, Drink 3L water',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop();
                await notifier.createHabit(name);
              }
            },
            child: const Text('Create', style: TextStyle(color: AppColors.bgMain)),
          ),
        ],
      ),
    );
  }
}

