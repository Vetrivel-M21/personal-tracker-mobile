import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/workouts_provider.dart';

class CreateCustomSplitDialog extends StatefulWidget {
  final WorkoutsNotifier notifier;

  const CreateCustomSplitDialog({super.key, required this.notifier});

  @override
  State<CreateCustomSplitDialog> createState() => _CreateCustomSplitDialogState();
}

class _EditableExercise {
  final TextEditingController nameController;
  final TextEditingController setsController;
  final TextEditingController repsController;
  final TextEditingController notesController;

  _EditableExercise({
    String name = '',
    int sets = 3,
    String reps = '10',
    String notes = '',
  })  : nameController = TextEditingController(text: name),
        setsController = TextEditingController(text: sets.toString()),
        repsController = TextEditingController(text: reps),
        notesController = TextEditingController(text: notes);

  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    notesController.dispose();
  }
}

class _EditableDay {
  final TextEditingController nameController;
  final List<_EditableExercise> exercises;

  _EditableDay({required String name, List<_EditableExercise>? exercises})
      : nameController = TextEditingController(text: name),
        exercises = exercises ?? [];

  void dispose() {
    nameController.dispose();
    for (final ex in exercises) {
      ex.dispose();
    }
  }
}

class _CreateCustomSplitDialogState extends State<CreateCustomSplitDialog> {
  final _splitNameController = TextEditingController(text: 'My Custom Routine');
  final List<_EditableDay> _days = [];
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default starter day
    _days.add(_EditableDay(
      name: 'Day 1: Full Body / Push',
      exercises: [
        _EditableExercise(name: 'Barbell Bench Press', sets: 4, reps: '8-10'),
        _EditableExercise(name: 'Overhead Press', sets: 3, reps: '10-12'),
      ],
    ));
  }

  @override
  void dispose() {
    _splitNameController.dispose();
    for (final d in _days) {
      d.dispose();
    }
    super.dispose();
  }

  void _addDay() {
    HapticFeedback.lightImpact();
    setState(() {
      _days.add(_EditableDay(
        name: 'Day ${_days.length + 1}',
        exercises: [
          _EditableExercise(name: 'Exercise 1', sets: 3, reps: '10'),
        ],
      ));
    });
  }

  void _removeDay(int index) {
    if (_days.length <= 1) return;
    HapticFeedback.selectionClick();
    setState(() {
      final removed = _days.removeAt(index);
      removed.dispose();
    });
  }

  void _addExercise(int dayIndex) {
    HapticFeedback.lightImpact();
    setState(() {
      _days[dayIndex].exercises.add(
        _EditableExercise(name: 'New Exercise', sets: 3, reps: '10'),
      );
    });
  }

  void _removeExercise(int dayIndex, int exIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      final removed = _days[dayIndex].exercises.removeAt(exIndex);
      removed.dispose();
    });
  }

  Future<void> _handleSave() async {
    final splitName = _splitNameController.text.trim();
    if (splitName.isEmpty) {
      setState(() => _errorMessage = 'Please enter a routine name.');
      return;
    }

    if (_days.isEmpty) {
      setState(() => _errorMessage = 'Please add at least one training day.');
      return;
    }

    // Validate days
    final dayDrafts = <CustomDayDraft>[];
    for (final d in _days) {
      final dayName = d.nameController.text.trim();
      if (dayName.isEmpty) {
        setState(() => _errorMessage = 'All training days must have a title.');
        return;
      }

      final exerciseDrafts = <CustomExerciseDraft>[];
      for (final ex in d.exercises) {
        final exName = ex.nameController.text.trim();
        if (exName.isNotEmpty) {
          final sets = int.tryParse(ex.setsController.text.trim()) ?? 3;
          final reps = ex.repsController.text.trim().isEmpty ? '10' : ex.repsController.text.trim();
          exerciseDrafts.add(CustomExerciseDraft(
            name: exName,
            targetSets: sets,
            targetReps: reps,
            notes: ex.notesController.text.trim(),
          ));
        }
      }

      if (exerciseDrafts.isEmpty) {
        setState(() => _errorMessage = 'Day "$dayName" must have at least one exercise.');
        return;
      }

      dayDrafts.add(CustomDayDraft(name: dayName, exercises: exerciseDrafts));
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final success = await widget.notifier.createFullCustomRoutine(
      name: splitName,
      days: dayDrafts,
      activate: true,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              'Custom Routine "$splitName" created and activated!',
              style: const TextStyle(color: AppColors.bgMain, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        setState(() => _errorMessage = 'Failed to create routine. Please check connection.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgCardSolid,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text('CREATE CUSTOM ROUTINE', style: AppTypography.titleMedium),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _splitNameController,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'ROUTINE NAME',
                labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                hintText: 'e.g. 5-Day Powerbuilding, Upper/Lower',
                filled: true,
                fillColor: AppColors.bgMain,
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.roundedMd,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.roundedMd,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppSpacing.roundedMd,
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TRAINING DAYS & EXERCISES', style: AppTypography.labelSmall),
                TextButton.icon(
                  onPressed: _addDay,
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: Text('ADD DAY', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: ListView.builder(
                itemCount: _days.length,
                itemBuilder: (ctx, dayIdx) {
                  final day = _days[dayIdx];
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
                          children: [
                            Expanded(
                              child: TextField(
                                controller: day.nameController,
                                style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Day Title (e.g. Push Day)',
                                ),
                              ),
                            ),
                            if (_days.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                onPressed: () => _removeDay(dayIdx),
                              ),
                          ],
                        ),
                        const Divider(color: AppColors.border, height: 16),
                        ...day.exercises.asMap().entries.map((entry) {
                          final exIdx = entry.key;
                          final ex = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: ex.nameController,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      hintText: 'Exercise name',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: ex.setsController,
                                    keyboardType: TextInputType.number,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      hintText: 'Sets',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: ex.repsController,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      hintText: 'Reps (8-12)',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                if (day.exercises.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _removeExercise(dayIdx, exIdx),
                                  ),
                              ],
                            ),
                          );
                        }),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => _addExercise(dayIdx),
                            icon: const Icon(Icons.add, size: 14, color: AppColors.secondary),
                            label: Text(
                              'Add Exercise',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.secondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.bgMain,
                  shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
                ),
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bgMain),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isSaving ? 'CREATING ROUTINE...' : 'SAVE & ACTIVATE ROUTINE',
                  style: AppTypography.button.copyWith(color: AppColors.bgMain, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

