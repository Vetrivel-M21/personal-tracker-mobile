import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../competition/screens/leaderboard_screen.dart';
import '../../competition/screens/submit_attempt_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../sharing/screens/invite_stats_screen.dart';
import '../../training/screens/training_hub_screen.dart';

class _NavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
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

  static const _items = [
    _NavBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavBarItem(
      icon: Icons.track_changes_outlined,
      activeIcon: Icons.track_changes,
      label: 'Training',
    ),
    _NavBarItem(
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
      label: 'Arena',
    ),
    _NavBarItem(
      icon: Icons.bolt_outlined,
      activeIcon: Icons.bolt_rounded,
      label: 'Challenge',
    ),
    _NavBarItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group_rounded,
      label: 'Squad',
    ),
  ];

  final _screens = const [
    HomeScreen(),
    TrainingHubScreen(),
    LeaderboardScreen(),
    SubmitAttemptScreen(),
    InviteStatsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
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
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: AppColors.navBarBg,
            borderRadius: BorderRadius.circular(33),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.14),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final isSelected = _currentIndex == index;
              final item = _items[index];

              return GestureDetector(
                onTap: () {
                  if (_currentIndex != index) {
                    HapticFeedback.lightImpact();
                    setState(() => _currentIndex = index);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 12 : 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    border: isSelected
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            width: 1.0,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.22),
                              blurRadius: 10,
                              spreadRadius: 0.5,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                        size: isSelected ? 22 : 20,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.label.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
