import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
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

/// Interactive Design System Review Page.
/// Demonstrates surfaces, typography (Latin + Tamil at 1.0x and 1.3x),
/// badges, buttons, cards, skeletons, and empty states without overflow at 360px.
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
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 3-Step Surface Elevation
              Text('SURFACE ELEVATION (3 STEPS)', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _surfaceChip('Surface 1', AppColors.surface1),
                  const SizedBox(width: AppSpacing.sm),
                  _surfaceChip('Surface 2', AppColors.surface2),
                  const SizedBox(width: AppSpacing.sm),
                  _surfaceChip('Surface 3', AppColors.surface3),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Tamil & Latin Typography Showcase + 1.3x Font Scale Test
              Text('TYPOGRAPHY & TAMIL (1.0x & 1.3x SCALE)', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('தமிழ் Max-Rep சவால் (Tamil Nadu)', style: AppTypography.headingLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Inter + Noto Sans Tamil with tabular figures and >= 4.5:1 contrast.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: const TextScaler.linear(1.3),
                      ),
                      child: Text(
                        '1.3x அளவு: தினசரி உடற்பயிற்சி இலக்கு (Daily Goal)',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Badges Section (Violet restricted to rank/level only)
              Text('RANK & LEVEL BADGES', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              const Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  LevelBadge(level: 1),
                  LevelBadge(level: 25),
                  LevelBadge(level: 99, isEarned: true),
                  RankBadge(rank: 'E'),
                  RankBadge(rank: 'D'),
                  RankBadge(rank: 'C'),
                  RankBadge(rank: 'B'),
                  RankBadge(rank: 'A'),
                  RankBadge(rank: 'S', isEarned: true),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // EXP Progress Bar
              Text('EXP BAR', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    ExpBar(xpIntoLevel: _sliderXp, xpForNextLevel: 100),
                    Slider(
                      value: _sliderXp.toDouble(),
                      min: 0,
                      max: 100,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.surface3,
                      onChanged: (v) => setState(() => _sliderXp = v.round()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Stat Cards
              Text('STAT CARDS (TABULAR FIGURES)', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: AppIcons.training,
                      label: 'PUSH-UPS',
                      value: '72',
                      sublabel: 'Chennai Rank #4',
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      icon: AppIcons.flame,
                      iconColor: AppColors.gold,
                      label: 'STREAK',
                      value: '14 DAYS',
                      sublabel: '1 Shield Left',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quest Cards
              Text('DAILY QUESTS', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              QuestCard(
                icon: AppIcons.activity,
                title: '50 Clean Form Push-Ups',
                xpReward: 10,
                isCompleted: _quest1Done,
                onToggle: () => setState(() => _quest1Done = !_quest1Done),
              ),
              const SizedBox(height: AppSpacing.sm),
              QuestCard(
                icon: AppIcons.target,
                iconColor: AppColors.primary,
                title: 'Daily Calisthenics Routine',
                xpReward: 15,
                isCompleted: _quest2Done,
                onToggle: () => setState(() => _quest2Done = !_quest2Done),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Buttons
              Text('BUTTONS (48DP MIN TAP TARGET)', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                text: 'Primary Action',
                icon: AppIcons.play,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                text: 'Secondary Action',
                icon: AppIcons.tune,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.xl),

              // Skeleton Loader
              Text('SKELETON LOADERS', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              const SkeletonLoader(height: 24, width: 180),
              const SizedBox(height: AppSpacing.sm),
              const SkeletonLoader(height: 16),
              const SizedBox(height: AppSpacing.sm),
              const SkeletonLoader(height: 16, width: 240),
              const SizedBox(height: AppSpacing.xl),

              // Empty State
              Text('EMPTY STATE COMPONENT', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: EmptyState(
                  icon: AppIcons.award,
                  title: 'No Attempts Yet',
                  description: 'Record your first push-up set to enter the district leaderboard.',
                  buttonText: 'Record Reps',
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

  Widget _surfaceChip(String label, Color color) {
    return Expanded(
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary)),
      ),
    );
  }
}
