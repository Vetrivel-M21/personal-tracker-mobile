import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../demo/screens/design_system_demo_screen.dart';
import '../../home/screens/home_screen.dart';

class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    DesignSystemDemoScreen(),
  ];

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
            icon: Icon(Icons.palette_outlined),
            activeIcon: Icon(Icons.palette, color: AppColors.primary),
            label: 'Design System',
          ),
        ],
      ),
    );
  }
}
