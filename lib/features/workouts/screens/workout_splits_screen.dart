import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/workout_split.dart';
import '../models/workout_template.dart';
import '../providers/workouts_provider.dart';
import 'log_session_screen.dart';

class WorkoutSplitsScreen extends ConsumerStatefulWidget {
  const WorkoutSplitsScreen({super.key});

  @override
  ConsumerState<WorkoutSplitsScreen> createState() => _WorkoutSplitsScreenState();
}

class _WorkoutSplitsScreenState extends ConsumerState<WorkoutSplitsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _syncTabController(int dayCount) {
    if (_tabController?.length != dayCount) {
      _tabController?.dispose();
      _tabController = TabController(length: dayCount > 0 ? dayCount : 1, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutsNotifierProvider);
    final notifier = ref.read(workoutsNotifierProvider.notifier);

    final activeSplit = state.activeSplit;
    if (activeSplit != null && activeSplit.days.isNotEmpty) {
      _syncTabController(activeSplit.days.length);
    }

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('Gym Workout Splits', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play, color: AppColors.primary),
            tooltip: 'Choose Split Template',
            onPressed: () => _showTemplateSelector(context, state.templates, notifier),
          ),
        ],
        bottom: activeSplit != null && activeSplit.days.isNotEmpty && _tabController != null
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: activeSplit.days.map((d) => Tab(text: d.name.toUpperCase())).toList(),
              )
            : null,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : activeSplit == null || activeSplit.days.isEmpty
              ? _buildNoSplitView(context, state.templates, notifier)
              : TabBarView(
                  controller: _tabController,
                  children: activeSplit.days.map((day) {
                    return _buildDayView(activeSplit, day);
                  }).toList(),
                ),
    );
  }

  Widget _buildNoSplitView(
    BuildContext context,
    List<WorkoutTemplateSummary> templates,
    WorkoutsNotifier notifier,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, color: AppColors.textMuted, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text('No Active Split Configured', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Select a battle-tested routine or split template to start logging gym sessions.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.bgMain,
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
              ),
              onPressed: () => _showTemplateSelector(context, templates, notifier),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Choose a Split Template', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayView(WorkoutSplitDetail split, WorkoutSplitDay day) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.bgCardSolid,
              borderRadius: AppSpacing.roundedLg,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day.name, style: AppTypography.titleMedium),
                    Text('${day.exercises.length} exercises programmed', style: AppTypography.labelSmall),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.bgMain,
                    shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
                  ),
                  onPressed: () => _startSessionForDay(split, day),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('LOG SESSION', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('EXERCISE PROGRAM', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          ...day.exercises.map((ex) => _buildExerciseCard(ex)),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutSplitExercise ex) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${ex.order + 1}',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                if (ex.notes.isNotEmpty)
                  Text(ex.notes, style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgMain,
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${ex.targetSets} × ${ex.targetReps}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startSessionForDay(WorkoutSplitDetail split, WorkoutSplitDay day) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LogSessionScreen(split: split, day: day),
      ),
    );
  }

  void _showTemplateSelector(
    BuildContext context,
    List<WorkoutTemplateSummary> templates,
    WorkoutsNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCardSolid,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Split Template', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose a structured split to program your training blocks.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: templates.length,
                  itemBuilder: (c, i) {
                    final t = templates[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.bgMain,
                        borderRadius: AppSpacing.roundedMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(t.name, style: AppTypography.titleMedium),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryMuted,
                                  borderRadius: AppSpacing.roundedSm,
                                ),
                                child: Text(
                                  '${t.daysPerWeek} Days / wk',
                                  style: AppTypography.labelSmall.copyWith(color: AppColors.secondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(t.description, style: AppTypography.bodySmall),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.bgMain,
                              ),
                              onPressed: () async {
                                Navigator.of(ctx).pop();
                                await notifier.createSplitFromTemplate(t.name, t.id);
                              },
                              child: const Text('Adopt Routine', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

