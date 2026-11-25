import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/daily_progress.dart';

class DailyLoggerCard extends StatefulWidget {
  final DailyProgress progress;
  final Future<bool> Function({
    required double hours,
    required String mood,
    required String notes,
  }) onSaveReflection;

  const DailyLoggerCard({
    super.key,
    required this.progress,
    required this.onSaveReflection,
  });

  @override
  State<DailyLoggerCard> createState() => _DailyLoggerCardState();
}

class _DailyLoggerCardState extends State<DailyLoggerCard> {
  late double _hours;
  late String _mood;
  late TextEditingController _notesController;
  bool _isSaving = false;
  bool _savedRecently = false;

  @override
  void initState() {
    super.initState();
    _hours = widget.progress.learningHours;
    _mood = widget.progress.mood.isEmpty ? 'Great' : widget.progress.mood;
    _notesController = TextEditingController(text: widget.progress.notes);
  }

  @override
  void didUpdateWidget(covariant DailyLoggerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress.notes != widget.progress.notes && !_isSaving) {
      _notesController.text = widget.progress.notes;
    }
    if (oldWidget.progress.learningHours != widget.progress.learningHours) {
      _hours = widget.progress.learningHours;
    }
    if (oldWidget.progress.mood != widget.progress.mood) {
      _mood = widget.progress.mood.isEmpty ? 'Great' : widget.progress.mood;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSaving = true;
      _savedRecently = false;
    });

    final success = await widget.onSaveReflection(
      hours: _hours,
      mood: _mood,
      notes: _notesController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
        _savedRecently = success;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error_outline,
                color: success ? AppColors.success : AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                success
                    ? 'Daily reflection and progress saved!'
                    : 'Failed to save reflection. Please retry.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          backgroundColor: AppColors.bgCardSolid,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(
          color: _savedRecently
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: _savedRecently
                ? AppColors.success.withValues(alpha: 0.08)
                : Colors.transparent,
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('DAILY REFLECTION & FOCUS', style: AppTypography.titleMedium),
                ],
              ),
              _buildHoursCounter(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('ENERGY & DISCIPLINE LEVEL', style: AppTypography.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          _buildMoodChips(),
          const SizedBox(height: AppSpacing.md),
          Text('TODAY\'S REFLECTION & TRAINING LOG', style: AppTypography.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'What was your biggest breakthrough today? Log discipline wins or mindset notes...',
              hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.bgMain,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
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
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _savedRecently ? AppColors.success : AppColors.primary,
                foregroundColor: AppColors.bgMain,
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
                elevation: 0,
              ),
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.bgMain,
                      ),
                    )
                  : Icon(
                      _savedRecently ? Icons.check_circle : Icons.save_alt_rounded,
                      size: 18,
                    ),
              label: Text(
                _isSaving
                    ? 'SYNCING PROTOCOL...'
                    : _savedRecently
                        ? 'SAVED & SYNCED'
                        : 'SAVE DAILY REFLECTION',
                style: AppTypography.button.copyWith(
                  color: AppColors.bgMain,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryMuted,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (_hours >= 0.5) {
                HapticFeedback.selectionClick();
                setState(() => _hours -= 0.5);
              }
            },
            child: const Icon(Icons.remove, size: 16, color: AppColors.secondary),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${_hours.toStringAsFixed(1)} hrs',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _hours += 0.5);
            },
            child: const Icon(Icons.add, size: 16, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChips() {
    final moods = ['Great', 'Good', 'Average', 'Bad'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((m) {
        final isSelected = _mood == m;
        return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _mood = m);
          },
          borderRadius: AppSpacing.roundedSm,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryMuted : AppColors.bgMain,
              borderRadius: AppSpacing.roundedSm,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.4 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              m,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
