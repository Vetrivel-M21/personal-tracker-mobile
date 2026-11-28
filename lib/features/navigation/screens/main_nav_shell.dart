import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../competition/screens/leaderboard_screen.dart';
import '../../competition/screens/submit_attempt_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../sharing/screens/invite_stats_screen.dart';
import '../../training/screens/training_hub_screen.dart';

class _NavBarItem {
  final IconData icon;
  final String label;

  const _NavBarItem({
    required this.icon,
    required this.label,
  });
}

class MainNavShell extends StatefulWidget {
  final int initialTab;

  const MainNavShell({super.key, this.initialTab = 0});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  late int _currentIndex;

  // 4 primary tabs + 1 center Challenge action button (5 items max)
  static const _tabs = [
    _NavBarItem(icon: AppIcons.home, label: 'Home'),
    _NavBarItem(icon: AppIcons.training, label: 'Training'),
    _NavBarItem(icon: AppIcons.arena, label: 'Arena'),
    _NavBarItem(icon: AppIcons.squad, label: 'Squad'),
  ];

  final _screens = const [
    HomeScreen(),
    TrainingHubScreen(),
    LeaderboardScreen(),
    InviteStatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, _screens.length - 1);
  }

  void _selectTab(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() => _currentIndex = index);
    }
  }

  void _openChallenge() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubmitAttemptScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildDock(),
    );
  }

  Widget _buildDock() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: AppSpacing.roundedXl,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            children: [
              _buildTabItem(0, _tabs[0]),
              _buildTabItem(1, _tabs[1]),
              _buildCenterChallengeButton(),
              _buildTabItem(2, _tabs[2]),
              _buildTabItem(3, _tabs[3]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int tabIndex, _NavBarItem item) {
    final isSelected = _currentIndex == tabIndex;
    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(tabIndex),
        borderRadius: AppSpacing.roundedMd,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterChallengeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: AppPressable(
        onTap: _openChallenge,
        enableHaptics: false,
        child: Tooltip(
          message: 'Start Challenge',
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.challenge,
              color: AppColors.onPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
