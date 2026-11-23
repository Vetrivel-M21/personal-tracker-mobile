import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../competition/screens/leaderboard_screen.dart';
import '../../competition/screens/submit_attempt_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../sharing/screens/invite_stats_screen.dart';

class MainNavShell extends StatefulWidget {
  final int initialTab;

  const MainNavShell({super.key, this.initialTab = 0});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  late int _currentIndex;

  final _screens = const [
    HomeScreen(),
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events, color: AppColors.primary),
            label: 'Arena',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle, color: AppColors.primary),
            label: 'Challenge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group, color: AppColors.primary),
            label: 'Squad',
          ),
        ],
      ),
    );
  }
}
