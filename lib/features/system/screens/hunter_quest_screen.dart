import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../../../widgets/rank_badge.dart';
import '../models/hunter_models.dart';
import '../providers/hunter_provider.dart';
import 'hunter_profile_screen.dart';

class HunterQuestScreen extends ConsumerStatefulWidget {
  const HunterQuestScreen({super.key});

  @override
  ConsumerState<HunterQuestScreen> createState() => _HunterQuestScreenState();
}

class _HunterQuestScreenState extends ConsumerState<HunterQuestScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  Timer? _countdownTimer;
  Duration _timeUntilMidnight = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    setState(() {
      _timeUntilMidnight = tomorrow.difference(now);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hunterNotifierProvider);
    final quest = state.todayQuest;

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('QUEST LOG', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppColors.primary),
            tooltip: 'Hunter Status',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HunterProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: state.isLoading && quest == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : quest == null
              ? _buildNoQuestState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.read(hunterNotifierProvider.notifier).load(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sci-Fi Quest Header Banner
                        _buildQuestHeaderBanner(quest),
                        const SizedBox(height: AppSpacing.lg),

                        // Time Remaining & Penalty Warning
                        _buildWarningBanner(quest),
                        const SizedBox(height: AppSpacing.lg),

                        // Section Header
                        Text('MANDATORY TRIALS', style: AppTypography.labelMedium),
                        const SizedBox(height: AppSpacing.sm),

                        // Quest Items List
                        ...quest.items.map((item) => _buildQuestItemCard(quest, item)),
                        const SizedBox(height: AppSpacing.xl),

                        // Action Button (Start or Claim Reward)
                        _buildActionButton(quest),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildQuestHeaderBanner(Quest quest) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(
          color: quest.isCompleted
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: quest.isCompleted
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RankBadge(rank: quest.rank),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: quest.isCompleted
                      ? AppColors.successMuted
                      : AppColors.primaryMuted,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(
                    color: quest.isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
                child: Text(
                  quest.status.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: quest.isCompleted ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(quest.title, style: AppTypography.headingMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            quest.description,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('REWARD EXP', style: AppTypography.labelSmall),
              Text(
                '+${quest.rewardXp} EXP',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(Quest quest) {
    if (quest.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.successMuted,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Trial Completed! Status parameters upgraded.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.warning, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIME REMAINING: ${_formatDuration(_timeUntilMidnight)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Incomplete trials consume 1 streak shield or incur a streak reset.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestItemCard(Quest quest, QuestItem item) {
    final isDone = item.currentCount >= item.targetCount;
    final progress = item.targetCount > 0 ? (item.currentCount / item.targetCount).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: isDone
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      child: Text(
                        item.statType,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.description,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.currentCount} / ${item.targetCount} ${item.unit}',
                style: AppTypography.labelSmall.copyWith(
                  color: isDone ? AppColors.success : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppSpacing.roundedSm,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.bgMain,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          if (!quest.isCompleted) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (item.unit == 'reps') ...[
                  _buildIncrementButton(item, 5),
                  const SizedBox(width: 8),
                  _buildIncrementButton(item, 10),
                  const SizedBox(width: 8),
                ],
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDone ? AppColors.bgMain : AppColors.primary,
                    foregroundColor: isDone ? AppColors.textMuted : AppColors.bgMain,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(60, 32),
                    shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedSm),
                  ),
                  onPressed: isDone
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          ref.read(hunterNotifierProvider.notifier).updateProgress(
                                item.id,
                                count: item.targetCount,
                              );
                        },
                  child: Text(isDone ? 'COMPLETE' : 'FINISH'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIncrementButton(QuestItem item, int delta) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(40, 32),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedSm),
      ),
      onPressed: () {
        HapticFeedback.selectionClick();
        ref.read(hunterNotifierProvider.notifier).updateProgress(item.id, delta: delta);
      },
      child: Text('+$delta'),
    );
  }

  Widget _buildActionButton(Quest quest) {
    if (quest.isCompleted) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.successMuted,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.success),
        ),
        alignment: Alignment.center,
        child: Text(
          'QUEST COMPLETED - ALL REWARDS CLAIMED',
          style: AppTypography.labelLarge.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (quest.isPending) {
      return SizedBox(
        height: 48,
        child: PrimaryButton(
          text: 'BEGIN QUEST TRIAL',
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(hunterNotifierProvider.notifier).startQuest();
          },
        ),
      );
    }

    final canClaim = quest.allItemsFinished;

    return ScaleTransition(
      scale: canClaim ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: canClaim ? AppColors.secondary : AppColors.bgCardSolid,
            foregroundColor: canClaim ? AppColors.white : AppColors.textMuted,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.roundedMd,
              side: BorderSide(color: canClaim ? AppColors.secondary : AppColors.border),
            ),
          ),
          onPressed: canClaim
              ? () async {
                  HapticFeedback.heavyImpact();
                  final success = await ref.read(hunterNotifierProvider.notifier).completeQuest();
                  if (success && mounted) {
                    _showQuestCelebrationDialog();
                  }
                }
              : null,
          child: Text(
            canClaim ? 'CLAIM QUEST REWARDS (+${quest.rewardXp} EXP)' : 'TRIALS IN PROGRESS',
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: canClaim ? AppColors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  void _showQuestCelebrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.bgCardSolid,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedLg,
            side: const BorderSide(color: AppColors.secondary, width: 2),
          ),
          title: Center(
            child: Column(
              children: [
                const Icon(Icons.military_tech, color: AppColors.secondary, size: 56),
                const SizedBox(height: AppSpacing.sm),
                Text('QUEST CLEARED!', style: AppTypography.headingLarge.copyWith(color: AppColors.secondary)),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'All mandatory trials fulfilled. System awards and parameter upgrades have been bestowed upon your body.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgMain,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatReward('STR', '+1'),
                    _buildStatReward('AGI', '+1'),
                    _buildStatReward('VIT', '+1'),
                    _buildStatReward('END', '+1'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 140,
                child: PrimaryButton(
                  text: 'ACCEPT',
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatReward(String stat, String gain) {
    return Column(
      children: [
        Text(stat, style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(gain, style: AppTypography.labelMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNoQuestState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.assignment_turned_in, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No Quest Available', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => ref.read(hunterNotifierProvider.notifier).load(),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
