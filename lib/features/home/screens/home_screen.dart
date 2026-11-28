import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_motion.dart';
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
import '../../habits/providers/habits_provider.dart';
import '../../habits/screens/habits_screen.dart';
import '../../onboarding/screens/location_setup_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../sharing/screens/invite_stats_screen.dart';
import '../../system/providers/hunter_provider.dart';
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
    final habitsState = ref.watch(habitsNotifierProvider);
    final hunterState = ref.watch(hunterNotifierProvider);

    final displayName = user?.displayName ?? 'Athlete';
    final level = user?.level ?? 1;
    final xp = user?.xp ?? 0;
    final xpInto = user?.xpIntoLevel ?? 0;
    final xpNext = user?.xpForNextLevel ?? 100;
    final locationDisplay = user?.locationDisplay ?? 'Location Not Set';
    final scopeLabel = user?.city ?? user?.district ?? user?.countryCode ?? 'Global';
    final myRank = leaderboardState.data?.myRank;

    final totalHabits = habitsState.habits.length;
    final doneHabits = habitsState.todayProgress.completedHabitIds.length;
    final quest = hunterState.todayQuest;
    final questTotal = quest?.items.length ?? 0;
    final questDone = quest == null
        ? 0
        : quest.items.where((i) => i.currentCount >= i.targetCount).length;

    final totalTasks = totalHabits + questTotal;
    final completedTasks = doneHabits + questDone;
    final progressRatio =
        totalTasks > 0 ? (completedTasks / totalTasks).clamp(0.0, 1.0) : 0.0;
    final streak = habitsState.streakStats.currentStreak;

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: InkWell(
          borderRadius: AppSpacing.roundedMd,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  AppIcons.chevronDown,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.profile, color: AppColors.textSecondary),
            tooltip: 'Hunter Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(child: RankBadge.fromXP(xp)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            104,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ONE HERO: Today's Progress Ring + Primary CTA
              AppStaggeredEntrance(
                index: 0,
                child: _HomeHeroCard(
                  progressRatio: progressRatio,
                  completedTasks: completedTasks,
                  totalTasks: totalTasks,
                  streak: streak,
                  xpIntoLevel: xpInto,
                  xpForNextLevel: xpNext,
                  onStartChallenge: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SubmitAttemptScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Daily Quest Summary
              const AppStaggeredEntrance(
                index: 1,
                child: HunterQuestCard(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quick Stats Row
              AppStaggeredEntrance(
                index: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: AppIcons.arena,
                        label: 'TERRITORY RANK',
                        value: myRank != null ? '#${myRank.rank}' : '--',
                        sublabel: scopeLabel,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        icon: AppIcons.challenge,
                        label: 'BEST REPS',
                        value: myRank != null ? '${myRank.bestReps}' : '0',
                        iconColor: AppColors.primary,
                        sublabel: 'Verified Score',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Territory Row (hairline, no gradient)
              AppStaggeredEntrance(
                index: 3,
                child: _buildTerritoryTile(
                  context: context,
                  locationDisplay: locationDisplay,
                  rankText: myRank != null ? 'Rank #${myRank.rank}' : 'Set Ranks',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Calm Secondary List
              Text('PROTOCOLS & TOOLS', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildSecondaryRow(
                      context: context,
                      icon: AppIcons.flame,
                      iconColor: AppColors.gold,
                      title: 'Habit Tracker',
                      subtitle: '$doneHabits / $totalHabits completed today',
                      destination: const HabitsScreen(),
                    ),
                    const Divider(),
                    _buildSecondaryRow(
                      context: context,
                      icon: AppIcons.training,
                      iconColor: AppColors.primary,
                      title: 'Workout Splits & Logger',
                      subtitle: 'Push/Pull/Legs, Upper/Lower & set tracking',
                      destination: const WorkoutSplitsScreen(),
                    ),
                    const Divider(),
                    _buildSecondaryRow(
                      context: context,
                      icon: AppIcons.target,
                      iconColor: AppColors.primary,
                      title: 'Calisthenics Skill Tree',
                      subtitle: 'Unlock progressive bodyweight movements',
                      destination: const CalisthenicsScreen(),
                    ),
                    const Divider(),
                    _buildSecondaryRow(
                      context: context,
                      icon: AppIcons.camera,
                      iconColor: AppColors.primary,
                      title: 'AI Rep Camera',
                      subtitle: 'Automatic push-up & pull-up pose counter',
                      destination: const AiCounterScreen(),
                    ),
                    const Divider(),
                    _buildSecondaryRow(
                      context: context,
                      icon: AppIcons.timer,
                      iconColor: AppColors.textSecondary,
                      title: 'Focus & Quests',
                      subtitle: 'Pomodoro timer and daily tasks',
                      destination: const FocusToolsScreen(),
                    ),
                    const Divider(),
                    _buildSecondaryRow(
                      context: context,
                      icon: AppIcons.squad,
                      iconColor: AppColors.textSecondary,
                      title: 'Community Hunters',
                      subtitle: 'Explore local athletes and give kudos',
                      destination: const CommunityScreen(),
                    ),
                    const Divider(),
                    _buildSecondaryRow(
                      context: context,
                      icon: AppIcons.share,
                      iconColor: AppColors.textSecondary,
                      title: 'Invite Squad & 1-on-1',
                      subtitle: 'Share your card and track referrals',
                      destination: const InviteStatsScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerritoryTile({
    required BuildContext context,
    required String locationDisplay,
    required String rankText,
  }) {
    return Material(
      color: AppColors.surface1,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedMd,
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: AppSpacing.roundedMd,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const LocationSetupScreen(isModal: true),
            ),
          );
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    AppIcons.location,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOCAL TERRITORY', style: AppTypography.labelSmall),
                      const SizedBox(height: 2),
                      Text(
                        locationDisplay,
                        style: AppTypography.headingSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: AppSpacing.roundedPill,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    rankText,
                    style: AppTypography.badge.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  AppIcons.chevronRight,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget destination,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                AppIcons.chevronRight,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  final double progressRatio;
  final int completedTasks;
  final int totalTasks;
  final int streak;
  final int xpIntoLevel;
  final int xpForNextLevel;
  final VoidCallback onStartChallenge;

  const _HomeHeroCard({
    required this.progressRatio,
    required this.completedTasks,
    required this.totalTasks,
    required this.streak,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.onStartChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reduceMotion(context);
    final percentInt = (progressRatio * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Animated Progress Ring
              SizedBox(
                width: 96,
                height: 96,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: progressRatio),
                  duration: reduce ? Duration.zero : AppMotion.ring,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CustomPaint(
                      painter: _ProgressRingPainter(
                        progress: value,
                        trackColor: AppColors.surface2,
                        progressColor: progressRatio >= 1.0 && totalTasks > 0
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppCountUpText(
                              target: percentInt,
                              suffix: '%',
                              style: AppTypography.statNumber.copyWith(fontSize: 20),
                            ),
                            Text('TODAY', style: AppTypography.labelSmall),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Readiness', style: AppTypography.headingMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      totalTasks > 0
                          ? '$completedTasks of $totalTasks daily targets complete'
                          : 'Ready for your first session today',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: AppSpacing.roundedPill,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.flame,
                            size: 14,
                            color: streak >= 7 ? AppColors.gold : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$streak day streak',
                            style: AppTypography.badge.copyWith(
                              color: streak >= 7 ? AppColors.gold : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ExpBar(xpIntoLevel: xpIntoLevel, xpForNextLevel: xpForNextLevel),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            text: 'Start Challenge',
            icon: AppIcons.challenge,
            onPressed: onStartChallenge,
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - stroke) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
