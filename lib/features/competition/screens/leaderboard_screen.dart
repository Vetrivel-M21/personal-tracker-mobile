import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
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
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => notifier.fetchLeaderboard(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Exercise Tab Toggle (Push-up / Pull-up)
            _buildExerciseToggle(state.filter.exercise, notifier),

            // Scope & Period Filter Controls
            _buildFilterRow(state.filter, notifier),

            // Leaderboard Content List
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.bgCardSolid,
                onRefresh: () => notifier.fetchLeaderboard(),
                child: _buildLeaderboardBody(context, state, notifier, currentUser?.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseToggle(String selected, LeaderboardNotifier notifier) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'PUSH-UPS',
              icon: Icons.fitness_center,
              isSelected: selected == 'pushup',
              onTap: () => notifier.setExercise('pushup'),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'PULL-UPS',
              icon: Icons.sports_gymnastics,
              isSelected: selected == 'pullup',
              onTap: () => notifier.setExercise('pullup'),
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
      borderRadius: AppSpacing.roundedSm,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppSpacing.roundedSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.bgMain : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.button.copyWith(
                color: isSelected ? AppColors.bgMain : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(LeaderboardFilter filter, LeaderboardNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: Column(
        children: [
          // Scope filters: Area, District, State, All
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildScopeChip('District', 'district', filter.scope, notifier),
                const SizedBox(width: AppSpacing.xs),
                _buildScopeChip('Area', 'area', filter.scope, notifier),
                const SizedBox(width: AppSpacing.xs),
                _buildScopeChip('State', 'state', filter.scope, notifier),
                const SizedBox(width: AppSpacing.xs),
                _buildScopeChip('Global', 'all', filter.scope, notifier),
                const SizedBox(width: AppSpacing.md),
                Container(width: 1, height: 24, color: AppColors.border),
                const SizedBox(width: AppSpacing.md),
                // Period filters: All-time, Week
                _buildPeriodChip('All-Time', 'all_time', filter.period, notifier),
                const SizedBox(width: AppSpacing.xs),
                _buildPeriodChip('Weekly', 'week', filter.period, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeChip(
    String label,
    String scopeValue,
    String currentScope,
    LeaderboardNotifier notifier,
  ) {
    final isSelected = currentScope == scopeValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryMuted,
      backgroundColor: AppColors.bgCardSolid,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      onSelected: (_) => notifier.setScope(scopeValue),
    );
  }

  Widget _buildPeriodChip(
    String label,
    String periodValue,
    String currentPeriod,
    LeaderboardNotifier notifier,
  ) {
    final isSelected = currentPeriod == periodValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondary.withValues(alpha: 0.2),
      backgroundColor: AppColors.bgCardSolid,
      side: BorderSide(
        color: isSelected ? AppColors.secondary : AppColors.border,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.secondary : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      onSelected: (_) => notifier.setPeriod(periodValue),
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
              const Icon(Icons.cloud_off, size: 48, color: AppColors.accentRed),
              const SizedBox(height: AppSpacing.md),
              Text(state.errorMessage!, textAlign: TextAlign.center, style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: 'RETRY',
                icon: Icons.refresh,
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
            icon: Icons.emoji_events_outlined,
            title: 'No Verified Records Yet',
            description:
                'Be the first athlete to record push-ups or pull-ups in this territory and seize Rank #1!',
            buttonText: 'POST REPS NOW',
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isMe = currentUserId != null && entry.userId == currentUserId;
        return _buildCompetitorRow(entry, isMe);
      },
    );
  }

  Widget _buildCompetitorRow(LeaderboardEntryModel entry, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryMuted : AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: isMe ? AppColors.primary : AppColors.border,
          width: isMe ? 1.5 : 1.0,
        ),
        boxShadow: isMe ? [AppColors.glowShadow(AppColors.primary)] : null,
      ),
      child: Row(
        children: [
          // Rank Badge
          _buildRankNumber(entry.rank),
          const SizedBox(width: AppSpacing.md),

          // Athlete Name & Location
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppSpacing.roundedSm,
                        ),
                        child: Text(
                          'YOU',
                          style: AppTypography.badge.copyWith(color: AppColors.bgMain, fontSize: 9),
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

          // Reps Count Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 16, color: AppColors.accentGold),
                const SizedBox(width: 4),
                Text(
                  '${entry.bestReps}',
                  style: AppTypography.displayMedium.copyWith(fontSize: 18),
                ),
                const SizedBox(width: 2),
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
      rankColor = AppColors.accentGold;
    } else if (rank == 2) {
      rankColor = const Color(0xFFE2E8F0); // Silver
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = AppColors.textMuted;
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: rankColor.withValues(alpha: 0.15),
        border: Border.all(color: rankColor.withValues(alpha: 0.6)),
      ),
      child: Text(
        '$rank',
        style: AppTypography.headingSmall.copyWith(
          color: rankColor,
          fontWeight: FontWeight.w700,
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
            color: AppColors.bgCardSolid,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: const [
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
