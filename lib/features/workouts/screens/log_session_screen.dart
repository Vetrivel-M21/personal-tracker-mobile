import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String? exerciseId;
  final String exerciseName;
  final int setNumber;
  final TextEditingController repsController;
  final TextEditingController weightController;
  final TextEditingController durationController;
  final bool isTimed;
  double rpe;
  String setType;
  bool isCompleted;

  _SetEntry({
    this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    required String defaultReps,
    required String defaultWeight,
    this.isTimed = false,
    this.rpe = 8.0,
    this.setType = 'normal',
  })  : repsController = TextEditingController(text: defaultReps),
        weightController = TextEditingController(text: defaultWeight),
        durationController = TextEditingController(text: isTimed ? '30' : ''),
        isCompleted = false;

  void dispose() {
    repsController.dispose();
    weightController.dispose();
    durationController.dispose();
  }
}

class _LogSessionScreenState extends ConsumerState<LogSessionScreen> {
  final Map<String, List<_SetEntry>> _exerciseSets = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _totalRestSeconds = 60;
  bool _showRestBanner = false;

  @override
  void initState() {
    super.initState();
    _initExerciseSets();
  }

  void _initExerciseSets() {
    for (final ex in widget.day.exercises) {
      final sets = <_SetEntry>[];
      final isTimed = ex.targetReps.toLowerCase().contains('s') || ex.name.toLowerCase().contains('plank') || ex.name.toLowerCase().contains('hold');
      for (int i = 1; i <= ex.targetSets; i++) {
        final parsedReps = _extractReps(ex.targetReps);
        sets.add(_SetEntry(
          exerciseId: ex.exerciseId,
          exerciseName: ex.name,
          setNumber: i,
          defaultReps: parsedReps.toString(),
          defaultWeight: '', // Nullable, never default to 0
          isTimed: isTimed,
          rpe: 8.0,
          setType: 'normal',
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

  void _triggerRestTimer(String exerciseName) {
    HapticFeedback.mediumImpact();
    _restTimer?.cancel();
    final lower = exerciseName.toLowerCase();
    final isCompound = lower.contains('bench') ||
        lower.contains('squat') ||
        lower.contains('deadlift') ||
        lower.contains('overhead') ||
        lower.contains('press');
    _totalRestSeconds = isCompound ? 90 : 60;
    _restSecondsRemaining = _totalRestSeconds;
    _showRestBanner = true;

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_restSecondsRemaining > 1) {
          _restSecondsRemaining--;
        } else {
          _restSecondsRemaining = 0;
          _showRestBanner = false;
          HapticFeedback.heavyImpact();
          timer.cancel();
        }
      });
    });
  }

  void _skipRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = 0;
      _showRestBanner = false;
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: _showRestBanner ? 70 : AppSpacing.lg,
              bottom: AppSpacing.xl,
            ),
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
          if (_showRestBanner) _buildRestCountdownBanner(),
        ],
      ),
    );
  }

  Widget _buildRestCountdownBanner() {
    final progress = _totalRestSeconds > 0
        ? _restSecondsRemaining / _totalRestSeconds
        : 0.0;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCardSolid,
          border: const Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    color: AppColors.primary,
                    backgroundColor: AppColors.border,
                  ),
                  Center(
                    child: Text(
                      '$_restSecondsRemaining',
                      style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'REST TIMER ACTIVE',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Catch your breath for the next set',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _skipRestTimer,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('SKIP'),
            ),
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
    final isTimed = sets.isNotEmpty && sets.first.isTimed;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ex.name, style: AppTypography.titleMedium),
              if (isTimed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: Text('TIMED', style: AppTypography.labelSmall.copyWith(color: AppColors.secondary)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(flex: 1, child: Text('SET', style: AppTypography.labelSmall)),
              Expanded(flex: 2, child: Text(isTimed ? 'SEC' : 'KG', style: AppTypography.labelSmall)),
              Expanded(flex: 2, child: Text(isTimed ? 'KG' : 'REPS', style: AppTypography.labelSmall)),
              Expanded(flex: 2, child: Text('TYPE', style: AppTypography.labelSmall)),
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
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.bgMain,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: s.isTimed ? s.durationController : s.weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTypography.bodySmall,
                decoration: InputDecoration(
                  hintText: s.isTimed ? '30s' : 'BW',
                  hintStyle: AppTypography.rawHintMicro,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.bgMain,
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: s.isTimed ? s.weightController : s.repsController,
                keyboardType: TextInputType.number,
                style: AppTypography.bodySmall,
                decoration: InputDecoration(
                  hintText: s.isTimed ? 'kg' : 'reps',
                  hintStyle: AppTypography.rawHintMicro,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          // Set Type Selector Dropdown / Pill
          Expanded(
            flex: 2,
            child: PopupMenuButton<String>(
              initialValue: s.setType,
              onSelected: (val) => setState(() => s.setType = val),
              child: Container(
                height: 36,
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgMain,
                  borderRadius: AppSpacing.roundedSm,
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  s.setType.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 9,
                    color: s.setType == 'normal' ? AppColors.textSecondary : AppColors.primary,
                  ),
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'normal', child: Text('Normal')),
                const PopupMenuItem(value: 'warmup', child: Text('Warmup')),
                const PopupMenuItem(value: 'drop', child: Text('Drop Set')),
                const PopupMenuItem(value: 'failure', child: Text('To Failure')),
              ],
            ),
          ),
          // Completion Checkbox
          SizedBox(
            width: 44,
            height: 36,
            child: InkWell(
              borderRadius: AppSpacing.roundedSm,
              onTap: () {
                final willComplete = !s.isCompleted;
                setState(() => s.isCompleted = willComplete);
                if (willComplete) {
                  _triggerRestTimer(s.exerciseName);
                }
              },
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
            decoration: InputDecoration(
              hintText: 'e.g., Felt strong on bench press, bumped up 2.5kg...',
              hintStyle: AppTypography.rawTextMuted,
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
    final setsList = <WorkoutSessionSet>[];
    for (final sets in _exerciseSets.values) {
      for (final s in sets) {
        if (!s.isCompleted) continue; // Only completed sets are sent!
        final reps = int.tryParse(s.repsController.text.trim()) ?? 0;
        final weightText = s.weightController.text.trim();
        final weight = weightText.isEmpty ? null : double.tryParse(weightText);
        final durText = s.durationController.text.trim();
        final duration = durText.isEmpty ? null : int.tryParse(durText);
        setsList.add(WorkoutSessionSet(
          id: '',
          exerciseId: s.exerciseId,
          exerciseName: s.exerciseName,
          setNumber: s.setNumber,
          reps: reps,
          weightKg: weight,
          durationSeconds: duration,
          rpe: s.rpe,
          setType: s.setType,
        ));
      }
    }

    if (setsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark at least one completed set before saving.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              'Session logged! +50 XP granted for gym consistency.',
              style: AppTypography.rawOnPrimaryBold,
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }
}

