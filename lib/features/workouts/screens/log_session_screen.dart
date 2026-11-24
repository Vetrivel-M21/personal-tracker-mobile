import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/workout_session.dart';
import '../models/workout_split.dart';
import '../providers/workouts_provider.dart';

class LogSessionScreen extends ConsumerStatefulWidget {
  final WorkoutSplitDetail split;
  final WorkoutSplitDay day;

  const LogSessionScreen({
    super.key,
    required this.split,
    required this.day,
  });

  @override
  ConsumerState<LogSessionScreen> createState() => _LogSessionScreenState();
}

class _SetEntry {
  final String exerciseName;
  final int setNumber;
  final TextEditingController repsController;
  final TextEditingController weightController;
  bool isCompleted;

  _SetEntry({
    required this.exerciseName,
    required this.setNumber,
    required String defaultReps,
    required String defaultWeight,
  })  : repsController = TextEditingController(text: defaultReps),
        weightController = TextEditingController(text: defaultWeight),
        isCompleted = false;

  void dispose() {
    repsController.dispose();
    weightController.dispose();
  }
}

class _LogSessionScreenState extends ConsumerState<LogSessionScreen> {
  final Map<String, List<_SetEntry>> _exerciseSets = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initExerciseSets();
  }

  void _initExerciseSets() {
    for (final ex in widget.day.exercises) {
      final sets = <_SetEntry>[];
      for (int i = 1; i <= ex.targetSets; i++) {
        final parsedReps = _extractReps(ex.targetReps);
        sets.add(_SetEntry(
          exerciseName: ex.name,
          setNumber: i,
          defaultReps: parsedReps.toString(),
          defaultWeight: '0',
        ));
      }
      _exerciseSets[ex.name] = sets;
    }
  }

  int _extractReps(String targetReps) {
    final firstNum = RegExp(r'\d+').firstMatch(targetReps);
    if (firstNum != null) {
      return int.tryParse(firstNum.group(0)!) ?? 10;
    }
    return 10;
  }

  @override
  void dispose() {
    for (final sets in _exerciseSets.values) {
      for (final s in sets) {
        s.dispose();
      }
    }
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text(widget.day.name, style: AppTypography.headingMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSessionMetaCard(),
            const SizedBox(height: AppSpacing.lg),
            ...widget.day.exercises.map((ex) => _buildExerciseSetTable(ex)),
            const SizedBox(height: AppSpacing.lg),
            _buildNotesInput(),
            const SizedBox(height: AppSpacing.xl),
            _buildFinishButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionMetaCard() {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return Container(
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
              Text('ACTIVE WORKOUT SESSION', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
              const SizedBox(height: 2),
              Text('${widget.split.name} • ${widget.day.name}', style: AppTypography.titleMedium),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgMain,
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(dateStr, style: AppTypography.labelSmall),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSetTable(WorkoutSplitExercise ex) {
    final sets = _exerciseSets[ex.name] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ex.name, style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(flex: 1, child: Text('SET', style: AppTypography.labelSmall)),
              Expanded(flex: 2, child: Text('KG', style: AppTypography.labelSmall)),
              Expanded(flex: 2, child: Text('REPS', style: AppTypography.labelSmall)),
              const SizedBox(width: 44, child: Center(child: Icon(Icons.check, size: 16, color: AppColors.textMuted))),
            ],
          ),
          const Divider(color: AppColors.border),
          ...sets.map((s) => _buildSetRow(s)),
        ],
      ),
    );
  }

  Widget _buildSetRow(_SetEntry s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '${s.setNumber}',
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.bgMain,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: s.weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTypography.bodySmall,
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.bgMain,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: s.repsController,
                keyboardType: TextInputType.number,
                style: AppTypography.bodySmall,
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ),
            ),
          ),
          SizedBox(
            width: 44,
            height: 36,
            child: InkWell(
              borderRadius: AppSpacing.roundedSm,
              onTap: () => setState(() => s.isCompleted = !s.isCompleted),
              child: Container(
                decoration: BoxDecoration(
                  color: s.isCompleted ? AppColors.primary : AppColors.bgMain,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(
                    color: s.isCompleted ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: s.isCompleted ? AppColors.bgMain : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SESSION REFLECTIONS & NOTES', style: AppTypography.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _notesController,
            maxLines: 2,
            style: AppTypography.bodySmall,
            decoration: const InputDecoration(
              hintText: 'e.g., Felt strong on bench press, bumped up 2.5kg...',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.bgMain,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
        ),
        onPressed: _isSaving ? null : _saveSession,
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bgMain),
              )
            : Text(
                'COMPLETE & SAVE SESSION',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.bgMain,
                ),
              ),
      ),
    );
  }

  Future<void> _saveSession() async {
    setState(() => _isSaving = true);
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final setsList = <WorkoutSessionSet>[];
    for (final sets in _exerciseSets.values) {
      for (final s in sets) {
        final reps = int.tryParse(s.repsController.text.trim()) ?? 0;
        final weight = double.tryParse(s.weightController.text.trim());
        setsList.add(WorkoutSessionSet(
          id: '',
          exerciseName: s.exerciseName,
          setNumber: s.setNumber,
          reps: reps,
          weightKg: weight,
        ));
      }
    }

    final notifier = ref.read(workoutsNotifierProvider.notifier);
    final session = await notifier.logSession(
      splitId: widget.split.id,
      splitDayId: widget.day.id,
      label: widget.day.name,
      sessionDate: dateStr,
      notes: _notesController.text.trim(),
      sets: setsList,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              'Session logged! +50 XP granted for gym consistency.',
              style: TextStyle(color: AppColors.bgMain, fontWeight: FontWeight.bold),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}

