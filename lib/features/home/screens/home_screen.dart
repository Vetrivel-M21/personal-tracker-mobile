import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../../../widgets/exp_bar.dart';
import '../../../widgets/level_badge.dart';
import '../../../widgets/rank_badge.dart';
import '../../../widgets/stat_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../competition/providers/competition_provider.dart';
import '../../competition/screens/submit_attempt_screen.dart';
import '../../onboarding/screens/location_setup_screen.dart';
import '../../sharing/screens/invite_stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final leaderboardState = ref.watch(leaderboardNotifierProvider);

    final displayName = user?.displayName ?? 'Athlete';
    final level = user?.level ?? 1;
    final xp = user?.xp ?? 0;
    final xpInto = user?.xpIntoLevel ?? 0;
    final xpNext = user?.xpForNextLevel ?? 100;
    final area = user?.area ?? 'Not Set';
    final district = user?.district ?? 'Tamil Nadu';
    final myRank = leaderboardState.data?.myRank;

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Row(
          children: [
            LevelBadge(level: level),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                displayName,
                style: AppTypography.headingMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(child: RankBadge.fromXP(xp)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // EXP Progress Header Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgCardSolid,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: ExpBar(xpIntoLevel: xpInto, xpForNextLevel: xpNext),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Location Rank Banner (Tap to change territory)
              InkWell(
                borderRadius: AppSpacing.roundedLg,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LocationSetupScreen(isModal: true),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.12),
                        AppColors.secondary.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: AppSpacing.roundedLg,
                    border: Border.all(color: AppColors.borderHover),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LOCAL TERRITORY', style: AppTypography.bodySmall),
                            Text(
                              '$area, $district',
                              style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMuted,
                          borderRadius: AppSpacing.roundedSm,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          myRank != null ? 'Rank #${myRank.rank}' : 'Set Ranks',
                          style: AppTypography.badge.copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Large "START CHALLENGE" Action Button
              Container(
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: AppSpacing.roundedXl,
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppSpacing.roundedXl,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SubmitAttemptScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on, size: 40, color: AppColors.bgMain),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'START CHALLENGE',
                                  style: AppTypography.headingLarge.copyWith(
                                    color: AppColors.bgMain,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Post Push-Ups & Pull-Ups to Climb TN Ranks',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.bgMain.withValues(alpha: 0.85),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: AppColors.bgMain, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Competition Quick Stats
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.fitness_center,
                      label: 'DISTRICT RANK',
                      value: myRank != null ? '#${myRank.rank}' : '--',
                      sublabel: district,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      icon: Icons.bolt,
                      label: 'BEST REPS',
                      value: myRank != null ? '${myRank.bestReps}' : '0',
                      iconColor: AppColors.secondary,
                      sublabel: 'Verified Score',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Invite Squad Banner
              InkWell(
                borderRadius: AppSpacing.roundedLg,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InviteStatsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardSolid,
                    borderRadius: AppSpacing.roundedLg,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.group_add_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INVITE FRIENDS & CHALLENGE',
                              style: AppTypography.headingSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Share your card, challenge 1-on-1, and track squad signups',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Logout Action
              SecondaryButton(
                text: 'LOG OUT',
                icon: Icons.logout,
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
