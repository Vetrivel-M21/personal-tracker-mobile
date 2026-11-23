import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../providers/competition_provider.dart';

class SubmitAttemptScreen extends ConsumerStatefulWidget {
  const SubmitAttemptScreen({super.key});

  @override
  ConsumerState<SubmitAttemptScreen> createState() => _SubmitAttemptScreenState();
}

class _SubmitAttemptScreenState extends ConsumerState<SubmitAttemptScreen> {
  String _exercise = 'pushup';
  int _reps = 25;
  String _proofType = 'manual';
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _repsController = TextEditingController(text: '25');
  String? _feedbackMessage;
  bool _isSuccessFeedback = false;

  @override
  void dispose() {
    _videoUrlController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _updateReps(int delta) {
    setState(() {
      _reps = (_reps + delta).clamp(1, 1000);
      _repsController.text = _reps.toString();
    });
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _feedbackMessage = null;
    });

    final notifier = ref.read(attemptsNotifierProvider.notifier);
    final video = _proofType == 'video' ? _videoUrlController.text.trim() : null;

    final success = await notifier.submitAttempt(
      exercise: _exercise,
      reps: _reps,
      proofType: _proofType,
      videoUrl: video,
    );

    if (mounted) {
      if (success) {
        setState(() {
          _isSuccessFeedback = true;
          _feedbackMessage = 'Attempt submitted! Status is PENDING admin verification.';
          if (_proofType == 'video') _videoUrlController.clear();
        });
        // Also refresh leaderboard in background
        ref.read(leaderboardNotifierProvider.notifier).fetchLeaderboard();
      } else {
        setState(() {
          _isSuccessFeedback = false;
          _feedbackMessage = ref.read(attemptsNotifierProvider).errorMessage ?? 'Submission failed';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attemptsState = ref.watch(attemptsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('POST MAX-REP ATTEMPT', style: AppTypography.headingMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Exercise Selection
              Text('EXERCISE', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceCard(
                      label: 'Push-Ups',
                      icon: Icons.fitness_center,
                      isSelected: _exercise == 'pushup',
                      onTap: () => setState(() => _exercise = 'pushup'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildChoiceCard(
                      label: 'Pull-Ups',
                      icon: Icons.sports_gymnastics,
                      isSelected: _exercise == 'pullup',
                      onTap: () => setState(() => _exercise = 'pullup'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Rep Counter Section
              Text('CONSECUTIVE REPS', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgCardSolid,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.borderHover),
                ),
                child: Column(
                  children: [
                    // Giant Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$_reps',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 54,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('reps', style: AppTypography.headingMedium.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Quick Stepper Buttons
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildStepButton('-10', () => _updateReps(-10)),
                        _buildStepButton('-1', () => _updateReps(-1)),
                        _buildStepButton('+1', () => _updateReps(1)),
                        _buildStepButton('+5', () => _updateReps(5)),
                        _buildStepButton('+10', () => _updateReps(10)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Proof Type Picker
              Text('PROOF METHOD', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceCard(
                      label: 'Honor / Manual',
                      icon: Icons.edit_note,
                      isSelected: _proofType == 'manual',
                      onTap: () => setState(() => _proofType = 'manual'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildChoiceCard(
                      label: 'Video Link',
                      icon: Icons.videocam_outlined,
                      isSelected: _proofType == 'video',
                      onTap: () => setState(() => _proofType = 'video'),
                    ),
                  ),
                ],
              ),

              if (_proofType == 'video') ...[
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _videoUrlController,
                  style: AppTypography.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Video Proof URL',
                    hintText: 'https://youtube.com/shorts/... or Drive link',
                    prefixIcon: Icon(Icons.link, color: AppColors.primary),
                  ),
                ),
              ],

              if (_feedbackMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _isSuccessFeedback
                        ? AppColors.accentGreen.withValues(alpha: 0.15)
                        : AppColors.accentRed.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(
                      color: _isSuccessFeedback ? AppColors.accentGreen : AppColors.accentRed,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccessFeedback ? Icons.check_circle : Icons.error,
                        color: _isSuccessFeedback ? AppColors.accentGreen : AppColors.accentRed,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _feedbackMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: _isSuccessFeedback ? AppColors.accentGreen : AppColors.accentRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Submit Button
              PrimaryButton(
                text: 'SUBMIT ATTEMPT',
                icon: Icons.send,
                isLoading: attemptsState.isSubmitting,
                onPressed: _handleSubmit,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Past Attempts History
              Text('MY RECENT ATTEMPTS', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              _buildAttemptsHistory(attemptsState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.roundedMd,
      child: Container(
        height: AppSpacing.minTouchTarget,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMuted : AppColors.bgCardSolid,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: AppTypography.button.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepButton(String text, VoidCallback onTap) {
    return SizedBox(
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderHover),
          backgroundColor: AppColors.bgCard,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedSm),
        ),
        child: Text(
          text,
          style: AppTypography.button.copyWith(color: AppColors.textPrimary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildAttemptsHistory(AttemptsState state) {
    if (state.isLoading && state.attempts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.attempts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgCardSolid,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'No attempts submitted yet. Submit above to enter the leaderboard!',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: state.attempts.take(10).map((attempt) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgCardSolid,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                attempt.exercise == 'pushup' ? Icons.fitness_center : Icons.sports_gymnastics,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${attempt.reps} ${attempt.exercise.toUpperCase()} REPS',
                      style: AppTypography.headingSmall.copyWith(fontSize: 14),
                    ),
                    Text(
                      'Proof: ${attempt.proofType} • ${_formatDate(attempt.createdAt)}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              _buildStatusPill(attempt.status),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusPill(String status) {
    Color pillColor;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'verified':
        pillColor = AppColors.accentGreen;
        label = 'VERIFIED';
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        pillColor = AppColors.accentRed;
        label = 'REJECTED';
        icon = Icons.cancel_outlined;
        break;
      case 'pending':
      default:
        pillColor = AppColors.accentGold;
        label = 'PENDING';
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.15),
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(color: pillColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: pillColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.badge.copyWith(color: pillColor, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return 'Today';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Recent';
    }
  }
}
