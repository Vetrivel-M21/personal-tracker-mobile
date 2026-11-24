import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../calisthenics/screens/calisthenics_screen.dart';
import '../../habits/screens/habits_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
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
      appBar: AppBar(
        title: Text('Training Hub', style: AppTypography.headingMedium),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.check_circle_outline, size: 20), text: 'HABITS'),
            Tab(icon: Icon(Icons.fitness_center, size: 20), text: 'WORKOUTS'),
            Tab(icon: Icon(Icons.account_tree_outlined, size: 20), text: 'SKILLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HabitsScreen(),
          WorkoutSplitsScreen(),
          CalisthenicsScreen(),
        ],
      ),
    );
  }
}

