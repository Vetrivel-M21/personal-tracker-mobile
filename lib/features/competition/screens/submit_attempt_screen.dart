import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../../counter/screens/ai_counter_screen.dart';
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
    HapticFeedback.lightImpact();
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
        ref.read(leaderboardNotifierProvider.notifier).fetchLeaderboard();
      } else {
        setState(() {
          _isSuccessFeedback = false;
          _feedbackMessage =
              ref.read(attemptsNotifierProvider).errorMessage ?? 'Submission failed';
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
              // AI Camera Counter Card (surface1 + hairline, no gradient)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        AppIcons.camera,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Camera Counter',
                            style: AppTypography.headingSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Automatic on-device push-up counting with pose detection.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      height: AppSpacing.minTouchTarget,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(76, AppSpacing.minTouchTarget),
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppSpacing.roundedMd,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AiCounterScreen()),
                          );
                        },
                        child: Text(
                          'Try AI',
                          style: AppTypography.button.copyWith(
                            color: AppColors.onPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Exercise Selection
              Text('EXERCISE', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceCard(
                      label: 'Push-Ups',
                      icon: AppIcons.training,
                      isSelected: _exercise == 'pushup',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _exercise = 'pushup');
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildChoiceCard(
                      label: 'Pull-Ups',
                      icon: AppIcons.activity,
                      isSelected: _exercise == 'pullup',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _exercise = 'pullup');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Rep Counter Section
              Text('CONSECUTIVE REPS', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xl,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$_reps',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 52,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'reps',
                          style: AppTypography.headingMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
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
              Text('PROOF METHOD', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceCard(
                      label: 'Honor / Manual',
                      icon: AppIcons.edit,
                      isSelected: _proofType == 'manual',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _proofType = 'manual');
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildChoiceCard(
                      label: 'Video Link',
                      icon: AppIcons.camera,
                      isSelected: _proofType == 'video',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _proofType = 'video');
                      },
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
                    prefixIcon: Icon(Icons.link_rounded, color: AppColors.primary),
                  ),
                ),
              ],

              if (_feedbackMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _isSuccessFeedback
                        ? AppColors.successMuted
                        : AppColors.dangerMuted,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(
                      color: _isSuccessFeedback ? AppColors.success : AppColors.danger,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccessFeedback ? AppIcons.check : Icons.error_outline_rounded,
                        color: _isSuccessFeedback ? AppColors.success : AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _feedbackMessage!,
                          style: AppTypography.bodySmall.copyWith(
                            color: _isSuccessFeedback
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Submit Button (Thumb Zone)
              PrimaryButton(
                text: 'Submit Attempt',
                icon: AppIcons.check,
                isLoading: attemptsState.isSubmitting,
                onPressed: _handleSubmit,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Past Attempts History
              Text('MY RECENT ATTEMPTS', style: AppTypography.labelSmall),
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
    return AppPressable(
      onTap: onTap,
      enableHaptics: false,
      child: Container(
        height: AppSpacing.minTouchTarget,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMuted : AppColors.surface1,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: AppTypography.button.copyWith(
                  fontSize: 14,
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
      height: AppSpacing.minTouchTarget,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(52, AppSpacing.minTouchTarget),
          side: const BorderSide(color: AppColors.borderStrong),
          backgroundColor: AppColors.surface2,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
        ),
        child: Text(
          text,
          style: AppTypography.button.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
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
          color: AppColors.surface1,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'No attempts submitted yet. Submit above to enter the leaderboard.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: state.attempts.take(10).map((attempt) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                attempt.exercise == 'pushup' ? AppIcons.training : AppIcons.activity,
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
                      style: AppTypography.headingSmall.copyWith(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
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
        pillColor = AppColors.success;
        label = 'VERIFIED';
        icon = AppIcons.check;
        break;
      case 'rejected':
        pillColor = AppColors.danger;
        label = 'REJECTED';
        icon = AppIcons.close;
        break;
      case 'pending':
      default:
        pillColor = AppColors.gold;
        label = 'PENDING';
        icon = AppIcons.timer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.14),
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(color: pillColor.withValues(alpha: 0.5)),
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
