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
import '../../calisthenics/screens/calisthenics_screen.dart';
import '../../community/screens/community_screen.dart';
import '../../competition/providers/competition_provider.dart';
import '../../competition/screens/submit_attempt_screen.dart';
import '../../counter/screens/ai_counter_screen.dart';
import '../../habits/screens/habits_screen.dart';
import '../../onboarding/screens/location_setup_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../progress/widgets/daily_progress_card.dart';
import '../../sharing/screens/invite_stats_screen.dart';
import '../../system/widgets/hunter_quest_card.dart';
import '../../tools/screens/focus_tools_screen.dart';
import '../../workouts/screens/workout_splits_screen.dart';

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
        title: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: Row(
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
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            tooltip: 'Hunter Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.md),

              // Phase 7B: Daily Progress Hub
              const DailyProgressCard(),
              const SizedBox(height: AppSpacing.md),

              // Hunter System: Daily Quest
              const HunterQuestCard(),
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

              // Training & Habit Protocols Bento Grid
              Text('TRAINING & DISCIPLINE PROTOCOLS', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildProtocolCard(
                      context: context,
                      title: 'Habit Tracker',
                      subtitle: 'Streak & Shields',
                      icon: Icons.local_fire_department,
                      color: AppColors.orange,
                      destination: const HabitsScreen(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildProtocolCard(
                      context: context,
                      title: 'Skill Tree',
                      subtitle: 'Calisthenics',
                      icon: Icons.account_tree_outlined,
                      color: AppColors.primary,
                      destination: const CalisthenicsScreen(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildProtocolCard(
                context: context,
                title: 'Gym Workout Split & Logger',
                subtitle: 'Push/Pull/Legs, Upper/Lower & Set Logging',
                icon: Icons.fitness_center,
                color: AppColors.secondary,
                destination: const WorkoutSplitsScreen(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildProtocolCard(
                      context: context,
                      title: 'Focus & Quests',
                      subtitle: 'Pomodoro & Todos',
                      icon: Icons.timer_outlined,
                      color: AppColors.accentGold,
                      destination: const FocusToolsScreen(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildProtocolCard(
                      context: context,
                      title: 'AI Rep Camera',
                      subtitle: 'Push-up & Pull-up',
                      icon: Icons.camera_alt_outlined,
                      color: AppColors.primary,
                      destination: const AiCounterScreen(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildProtocolCard(
                context: context,
                title: 'Community Hunters Directory',
                subtitle: 'Explore local hunters, give kudos & view public habits',
                icon: Icons.group_outlined,
                color: AppColors.primary,
                destination: const CommunityScreen(),
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

  Widget _buildProtocolCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return InkWell(
      borderRadius: AppSpacing.roundedLg,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgCardSolid,
          borderRadius: AppSpacing.roundedLg,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: AppSpacing.roundedMd,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
