import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../calisthenics/screens/calisthenics_screen.dart';
import '../../habits/screens/habits_screen.dart';
import '../../tools/screens/focus_tools_screen.dart';
import '../../workouts/screens/workout_splits_screen.dart';

class TrainingHubScreen extends StatefulWidget {
  final int initialTab;

  const TrainingHubScreen({super.key, this.initialTab = 0});

  @override
  State<TrainingHubScreen> createState() => _TrainingHubScreenState();
}

class _TrainingHubScreenState extends State<TrainingHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    {'title': 'Habits', 'icon': AppIcons.listChecks},
    {'title': 'Workouts', 'icon': AppIcons.training},
    {'title': 'Skills', 'icon': AppIcons.target},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Calm Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Training', style: AppTypography.headingLarge),
                      const SizedBox(height: 2),
                      Text(
                        'Habits, workouts & skill progression',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  InkWell(
                    borderRadius: AppSpacing.roundedMd,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FocusToolsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: AppSpacing.minTouchTarget,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: AppSpacing.roundedMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            AppIcons.timer,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Focus',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Segmented Tab Bar
            Container(
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
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.borderStrong, width: 1),
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTypography.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: _tabs.map((tab) {
                  return Tab(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tab['icon'] as IconData, size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            tab['title'] as String,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Tab Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  HabitsScreen(isEmbedded: true),
                  WorkoutSplitsScreen(isEmbedded: true),
                  CalisthenicsScreen(isEmbedded: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
