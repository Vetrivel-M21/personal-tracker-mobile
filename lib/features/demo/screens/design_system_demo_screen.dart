import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/exp_bar.dart';
import '../../../widgets/level_badge.dart';
import '../../../widgets/quest_card.dart';
import '../../../widgets/rank_badge.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../../widgets/stat_card.dart';

/// Interactive Demo Screen displaying every reusable widget from the design system.
/// Guaranteed to display without overflow on screens down to 360px width.
class DesignSystemDemoScreen extends StatefulWidget {
  const DesignSystemDemoScreen({super.key});

  @override
  State<DesignSystemDemoScreen> createState() => _DesignSystemDemoScreenState();
}

class _DesignSystemDemoScreenState extends State<DesignSystemDemoScreen> {
  bool _quest1Done = false;
  bool _quest2Done = true;
  int _sliderXp = 45;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SYSTEM DESIGN DEMO', style: AppTypography.headingMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tamil & Latin Typography Showcase
              Text('TYPOGRAPHY & SCRIPTS', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              Text('தமிழ் Max-Rep சவால் (Tamil Nadu)', style: AppTypography.headingLarge),
              Text(
                'Full support for Tamil and Latin scripts with zero overflow at 360px.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Badges Section
              Text('RANK & LEVEL BADGES', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: const [
                  LevelBadge(level: 1),
                  LevelBadge(level: 25),
                  LevelBadge(level: 99),
                  RankBadge(rank: 'E'),
                  RankBadge(rank: 'D'),
                  RankBadge(rank: 'C'),
                  RankBadge(rank: 'B'),
                  RankBadge(rank: 'A'),
                  RankBadge(rank: 'S'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // EXP Progress Bar
              Text('EXP BAR (SYSTEM PROGRESSION)', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              ExpBar(xpIntoLevel: _sliderXp, xpForNextLevel: 100),
              Slider(
                value: _sliderXp.toDouble(),
                min: 0,
                max: 100,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged: (v) => setState(() => _sliderXp = v.round()),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Stat Cards
              Text('STAT CARDS', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: const [
                  Expanded(
                    child: StatCard(
                      icon: Icons.fitness_center,
                      label: 'PUSH-UPS',
                      value: '72',
                      sublabel: 'Chennai Rank #4',
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_fire_department,
                      iconColor: AppColors.orange,
                      label: 'STREAK',
                      value: '14 DAYS',
                      sublabel: '1 Shield Left',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quest Cards
              Text('DAILY QUESTS', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              QuestCard(
                icon: Icons.sports_gymnastics,
                title: '50 Clean Form Push-Ups',
                xpReward: 10,
                isCompleted: _quest1Done,
                onToggle: () => setState(() => _quest1Done = !_quest1Done),
              ),
              const SizedBox(height: AppSpacing.sm),
              QuestCard(
                icon: Icons.directions_run,
                iconColor: AppColors.secondary,
                title: 'Daily Calisthenics Routine',
                xpReward: 15,
                isCompleted: _quest2Done,
                onToggle: () => setState(() => _quest2Done = !_quest2Done),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Buttons
              Text('BUTTONS (48PX MIN TAP TARGET)', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                text: 'PRIMARY ACTION',
                icon: Icons.play_arrow,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                text: 'SECONDARY ACTION',
                icon: Icons.tune,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.xl),

              // Skeleton Loader
              Text('SKELETON LOADERS (SHIMMER)', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              const SkeletonLoader(height: 24, width: 180),
              const SizedBox(height: AppSpacing.xs),
              const SkeletonLoader(height: 16),
              const SizedBox(height: AppSpacing.xs),
              const SkeletonLoader(height: 16, width: 260),
              const SizedBox(height: AppSpacing.xl),

              // Empty State
              Text('EMPTY STATE COMPONENT', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCardSolid,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: EmptyState(
                  icon: Icons.military_tech_outlined,
                  title: 'No Attempts Yet',
                  description: 'Record your first push-up set to enter the district leaderboard.',
                  buttonText: 'RECORD REPS',
                  onButtonPressed: () {},
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
