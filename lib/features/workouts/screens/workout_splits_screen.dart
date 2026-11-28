import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/workout_split.dart';
import '../providers/workouts_provider.dart';
import 'create_custom_split_dialog.dart';
import 'log_session_screen.dart';
import 'workout_history_view.dart';

class WorkoutSplitsScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;

  const WorkoutSplitsScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<WorkoutSplitsScreen> createState() => _WorkoutSplitsScreenState();
}

class _WorkoutSplitsScreenState extends ConsumerState<WorkoutSplitsScreen>
    with TickerProviderStateMixin {
  int _selectedSection = 0; // 0: Active Split, 1: Templates & Custom, 2: History Summary
  TabController? _dayTabController;

  @override
  void dispose() {
    _dayTabController?.dispose();
    super.dispose();
  }

  void _syncDayTabController(int dayCount) {
    if (_dayTabController?.length != dayCount) {
      _dayTabController?.dispose();
      _dayTabController = TabController(length: dayCount > 0 ? dayCount : 1, vsync: this);
    }
  }

  void _openCreateCustomDialog(WorkoutsNotifier notifier) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateCustomSplitDialog(notifier: notifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutsNotifierProvider);
    final notifier = ref.read(workoutsNotifierProvider.notifier);

    final activeSplit = state.activeSplit;
    if (activeSplit != null && activeSplit.days.isNotEmpty) {
      _syncDayTabController(activeSplit.days.length);
    }

    final content = state.isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Column(
            children: [
              // 1. Top Section Sub-Tabs (Active / Templates / History)
              _buildSectionSelector(),

              // 2. Section Body
              Expanded(
                child: _selectedSection == 0
                    ? _buildActiveSplitSection(context, state, notifier)
                    : _selectedSection == 1
                        ? _buildTemplatesAndCustomSection(context, state, notifier)
                        : WorkoutHistoryView(
                            sessions: state.recentSessions,
                            onRefresh: () => notifier.loadWorkoutsData(),
                          ),
              ),
            ],
          );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('Gym Workout Splits', style: AppTypography.headingMedium),
      ),
      body: content,
    );
  }

  Widget _buildSectionSelector() {
    final sections = ['ACTIVE ROUTINE', 'TEMPLATES & CUSTOM', 'HISTORY SUMMARY'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(sections.length, (idx) {
          final isSelected = _selectedSection == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedSection != idx) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedSection = idx);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryMuted : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 1.2)
                      : null,
                ),
                child: Text(
                  sections[idx],
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // SECTION 0: ACTIVE SPLIT
  // ==========================================
  Widget _buildActiveSplitSection(
    BuildContext context,
    WorkoutsState state,
    WorkoutsNotifier notifier,
  ) {
    final activeSplit = state.activeSplit;
    if (activeSplit == null || activeSplit.days.isEmpty) {
      return _buildNoActiveSplitView(context, notifier);
    }

    return Column(
      children: [
        // Days Tab Bar
        if (_dayTabController != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgMain,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _dayTabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.secondaryMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondary, width: 1.2),
              ),
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: activeSplit.days.map((d) => Tab(text: d.name.toUpperCase())).toList(),
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _dayTabController,
            children: activeSplit.days.map((day) {
              return _buildDayView(activeSplit, day);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNoActiveSplitView(BuildContext context, WorkoutsNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, color: AppColors.textMuted, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text('No Active Routine Selected', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Select a battle-tested routine or build a custom split to start logging programmed gym sessions.',
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
              onPressed: () => setState(() => _selectedSection = 1),
              icon: const Icon(Icons.playlist_play),
              label: const Text('BROWSE PRESETS & ROUTINES', style: AppTypography.rawBold),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
              ),
              onPressed: () => _openCreateCustomDialog(notifier),
              icon: const Icon(Icons.add),
              label: const Text('CREATE CUSTOM ROUTINE', style: AppTypography.rawBold),
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
                  label: const Text('LOG SESSION', style: AppTypography.rawBold),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('PROGRAMMED EXERCISES', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          ...day.exercises.map((ex) => _buildExerciseCard(ex)),
          const SizedBox(height: 70), // Floating nav bar padding
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
            decoration: const BoxDecoration(
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

  // ==========================================
  // SECTION 1: TEMPLATES & CUSTOM ROUTINES
  // ==========================================
  Widget _buildTemplatesAndCustomSection(
    BuildContext context,
    WorkoutsState state,
    WorkoutsNotifier notifier,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Create custom button banner
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgCardSolid,
            borderRadius: AppSpacing.roundedLg,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CUSTOM ROUTINE BUILDER', style: AppTypography.titleMedium),
                  Text('Design your own split and exercise sets', style: AppTypography.labelSmall),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.bgMain,
                  shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
                ),
                onPressed: () => _openCreateCustomDialog(notifier),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('BUILD', style: AppTypography.rawBold),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // User's Saved Splits / Custom Routines
        if (state.splits.isNotEmpty) ...[
          Text('MY SAVED ROUTINES', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          ...state.splits.map((s) {
            final isActive = state.activeSplit?.id == s.id;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgCardSolid,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(
                  color: isActive ? AppColors.success : AppColors.border,
                  width: isActive ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(s.name, style: AppTypography.titleMedium),
                            if (isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.successMuted,
                                  borderRadius: AppSpacing.roundedSm,
                                ),
                                child: Text('ACTIVE', style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        Text('${s.dayCount} programmed days', style: AppTypography.labelSmall),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (!isActive)
                        TextButton(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            await notifier.activateSplit(s.id);
                            setState(() => _selectedSection = 0);
                          },
                          child: const Text('ACTIVATE', style: AppTypography.rawPrimaryBold),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.bgCardSolid,
                              title: const Text('Delete Routine?'),
                              content: Text('Delete "${s.name}"? This cannot be undone.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE', style: AppTypography.rawDangerText)),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await notifier.deleteSplit(s.id);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Preset Templates catalog
        Text('PRESET BATTLE-TESTED TEMPLATES', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        ...state.templates.map((t) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.bgCardSolid,
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
                      HapticFeedback.mediumImpact();
                      await notifier.createSplitFromTemplate(t.name, t.id);
                      setState(() => _selectedSection = 0);
                    },
                    child: const Text('ADOPT & ACTIVATE ROUTINE', style: AppTypography.rawBold),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 70), // Floating nav bar padding
      ],
    );
  }
}
