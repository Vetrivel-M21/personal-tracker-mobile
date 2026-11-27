import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/rank_badge.dart';
import '../providers/hunter_provider.dart';
import '../screens/hunter_quest_screen.dart';

class HunterQuestCard extends ConsumerWidget {
  const HunterQuestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hunterNotifierProvider);
    final quest = state.todayQuest;

    if (state.isLoading && quest == null) {
      return Container(
        height: 110,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgCardSolid,
          borderRadius: AppSpacing.roundedLg,
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      );
    }

    if (quest == null) {
      return const SizedBox.shrink();
    }

    int completedCount = 0;
    for (final itm in quest.items) {
      if (itm.currentCount >= itm.targetCount) completedCount++;
    }
    final progress = quest.items.isNotEmpty ? completedCount / quest.items.length : 0.0;

    return InkWell(
      borderRadius: AppSpacing.roundedLg,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HunterQuestScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgCardSolid,
          borderRadius: AppSpacing.roundedLg,
          border: Border.all(
            color: quest.isCompleted
                ? AppColors.success.withValues(alpha: 0.6)
                : AppColors.primary.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: quest.isCompleted
                  ? AppColors.success.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: quest.isCompleted
                            ? AppColors.successMuted
                            : AppColors.primaryMuted,
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(
                          color: quest.isCompleted
                              ? AppColors.success.withValues(alpha: 0.4)
                              : AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'DAILY QUEST',
                        style: AppTypography.labelSmall.copyWith(
                          color: quest.isCompleted ? AppColors.success : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    RankBadge(rank: quest.rank),
                  ],
                ),
                Text(
                  '+${quest.rewardXp} XP',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              quest.title,
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              quest.isCompleted
                  ? 'Quest Cleared! Daily trials satisfied.'
                  : '$completedCount/${quest.items.length} tasks completed',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppSpacing.roundedSm,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.bgMain,
                valueColor: AlwaysStoppedAnimation<Color>(
                  quest.isCompleted ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
