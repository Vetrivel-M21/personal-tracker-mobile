import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/competition_models.dart';
import '../../../widgets/app_buttons.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/competition_provider.dart';
import 'submit_attempt_screen.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardNotifierProvider);
    final notifier = ref.read(leaderboardNotifierProvider.notifier);
    final currentUser = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('ARENA LEADERBOARD', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.fetchLeaderboard();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildExerciseToggle(state.filter.exercise, notifier),
            _buildFilterRow(state.filter, notifier),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface2,
                onRefresh: () => notifier.fetchLeaderboard(),
                child: _buildLeaderboardBody(
                  context,
                  state,
                  notifier,
                  currentUser?.id,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseToggle(String selected, LeaderboardNotifier notifier) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'PUSH-UPS',
              icon: AppIcons.training,
              isSelected: selected == 'pushup',
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.setExercise('pushup');
              },
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'PULL-UPS',
              icon: AppIcons.activity,
              isSelected: selected == 'pullup',
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.setExercise('pullup');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.roundedMd,
      child: Container(
        height: AppSpacing.minTouchTarget,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppSpacing.roundedMd,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.button.copyWith(
                color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(
    LeaderboardFilter filter,
    LeaderboardNotifier notifier,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _buildFilterChip('Area', 'area', filter.scope, (v) => notifier.setScope(v)),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('District', 'district', filter.scope, (v) => notifier.setScope(v)),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('State', 'state', filter.scope, (v) => notifier.setScope(v)),
          Container(
            height: 20,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: AppColors.border,
          ),
          _buildFilterChip('This Week', 'weekly', filter.period, (v) => notifier.setPeriod(v)),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('All-Time', 'all_time', filter.period, (v) => notifier.setPeriod(v)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String current,
    ValueChanged<String> onSelect,
  ) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryMuted,
      backgroundColor: AppColors.surface2,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      labelStyle: AppTypography.rawChipLabel(
        isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      onSelected: (_) {
        HapticFeedback.selectionClick();
        onSelect(value);
      },
    );
  }

  Widget _buildLeaderboardBody(
    BuildContext context,
    LeaderboardState state,
    LeaderboardNotifier notifier,
    String? currentUserId,
  ) {
    if (state.isLoading && state.data == null) {
      return _buildSkeletonList();
    }

    if (state.errorMessage != null && state.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 44, color: AppColors.danger),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: 'Retry',
                icon: AppIcons.refresh,
                onPressed: () => notifier.fetchLeaderboard(),
              ),
            ],
          ),
        ),
      );
    }

    final entries = state.data?.entries ?? [];
    if (entries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: AppSpacing.xxl),
          EmptyState(
            icon: AppIcons.arena,
            title: 'No Verified Records Yet',
            description:
                'Be the first athlete to record push-ups or pull-ups in this territory.',
            buttonText: 'Post Reps Now',
            onButtonPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubmitAttemptScreen()),
              );
            },
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        104,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isMe = currentUserId != null && entry.userId == currentUserId;
        return AppStaggeredEntrance(
          index: index,
          child: _buildCompetitorRow(entry, isMe),
        );
      },
    );
  }

  Widget _buildCompetitorRow(LeaderboardEntryModel entry, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryMuted : AppColors.surface1,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: isMe ? AppColors.primary : AppColors.border,
          width: isMe ? 1.2 : 1.0,
        ),
      ),
      child: Row(
        children: [
          _buildRankNumber(entry.rank),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.displayName,
                        style: AppTypography.headingSmall.copyWith(
                          color: isMe ? AppColors.primary : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppSpacing.roundedSm,
                        ),
                        child: Text(
                          'YOU',
                          style: AppTypography.badge.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.locationLabel,
                  style: AppTypography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.challenge, size: 15, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  '${entry.bestReps}',
                  style: AppTypography.statNumber.copyWith(fontSize: 17),
                ),
                const SizedBox(width: 3),
                Text('reps', style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankNumber(int rank) {
    Color rankColor;
    if (rank == 1) {
      rankColor = AppColors.gold;
    } else if (rank == 2) {
      rankColor = AppColors.rankSilver;
    } else if (rank == 3) {
      rankColor = AppColors.rankBronze;
    } else {
      rankColor = AppColors.textMuted;
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: rankColor.withValues(alpha: 0.14),
        border: Border.all(color: rankColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$rank',
        style: AppTypography.badge.copyWith(
          color: rankColor,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              SkeletonLoader(width: 36, height: 36),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 140, height: 16),
                    SizedBox(height: 6),
                    SkeletonLoader(width: 90, height: 12),
                  ],
                ),
              ),
              SkeletonLoader(width: 60, height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
