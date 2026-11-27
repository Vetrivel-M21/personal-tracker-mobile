import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/exp_bar.dart';
import '../../../widgets/level_badge.dart';
import '../../../widgets/rank_badge.dart';
import '../models/hunter_models.dart';
import '../providers/hunter_provider.dart';

class HunterProfileScreen extends ConsumerWidget {
  const HunterProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hunterNotifierProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('HUNTER STATUS', style: AppTypography.headingMedium),
      ),
      body: state.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : profile == null
              ? _buildError(ref)
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.read(hunterNotifierProvider.notifier).load(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hunter Identification Card
                        _buildHunterIDCard(profile),
                        const SizedBox(height: AppSpacing.lg),

                        // System Stats Parameters
                        _buildStatsParametersCard(profile.stats),
                        const SizedBox(height: AppSpacing.lg),

                        // Streak Shields & Protection
                        _buildShieldsCard(profile.stats.streakShields),
                        const SizedBox(height: AppSpacing.lg),

                        // Unlocked Titles
                        _buildTitlesCard(profile.titles, profile.activeTitle),
                        const SizedBox(height: AppSpacing.lg),

                        // Recent XP Ledger Timeline
                        _buildXPEventsLedger(profile.recentXpEvents),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHunterIDCard(HunterProfile profile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 18,
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
              Row(
                children: [
                  LevelBadge(level: profile.level),
                  const SizedBox(width: AppSpacing.sm),
                  Text(profile.name, style: AppTypography.headingMedium),
                ],
              ),
              RankBadge(rank: profile.rank),
            ],
          ),
          if (profile.activeTitle != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondaryMuted,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
              ),
              child: Text(
                'TITLE: ${profile.activeTitle!.toUpperCase()}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ExpBar(
            xpIntoLevel: profile.xpIntoLevel,
            xpForNextLevel: profile.xpForNextLevel,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsParametersCard(HunterStats stats) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('HUNTER PARAMETERS', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatMeterRow('STRENGTH (STR)', stats.str, AppColors.danger, Icons.fitness_center),
          const SizedBox(height: AppSpacing.sm),
          _buildStatMeterRow('AGILITY (AGI)', stats.agi, AppColors.primary, Icons.directions_run),
          const SizedBox(height: AppSpacing.sm),
          _buildStatMeterRow('VITALITY (VIT)', stats.vit, AppColors.success, Icons.favorite),
          const SizedBox(height: AppSpacing.sm),
          _buildStatMeterRow('ENDURANCE (END)', stats.end, AppColors.warning, Icons.battery_charging_full),
        ],
      ),
    );
  }

  Widget _buildStatMeterRow(String label, int value, Color color, IconData icon) {
    final progress = (value / 100.0).clamp(0.1, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
              ],
            ),
            Text(
              '$value',
              style: AppTypography.labelMedium.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: AppSpacing.roundedSm,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.bgMain,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildShieldsCard(int shields) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: AppSpacing.roundedSm,
            ),
            child: const Icon(Icons.shield, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STREAK SHIELDS', style: AppTypography.labelSmall),
                Text(
                  '$shields Shield${shields == 1 ? "" : "s"} Banked',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  'Automatically absorbs 1 missed daily quest to prevent streak reset.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitlesCard(List<UserTitle> titles, String? activeTitle) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text('UNLOCKED TITLES', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (titles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Complete daily trials or rank up to unlock hunter titles.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: titles.map((t) {
                final isActive = t.titleName == activeTitle;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.secondaryMuted : AppColors.bgMain,
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(
                      color: isActive ? AppColors.secondary : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive) ...[
                        const Icon(Icons.check, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        t.titleName,
                        style: AppTypography.labelSmall.copyWith(
                          color: isActive ? AppColors.secondary : AppColors.textSecondary,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildXPEventsLedger(List<XPEvent> events) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 8),
              Text('SYSTEM EXP LEDGER', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('No recorded EXP transactions yet.', style: AppTypography.bodySmall),
            )
          else
            ...events.map((ev) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ev.source.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          ev.createdAt,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                    Text(
                      '+${ev.amount} EXP',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
          const SizedBox(height: 12),
          Text('Failed to load Hunter Profile', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => ref.read(hunterNotifierProvider.notifier).load(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
