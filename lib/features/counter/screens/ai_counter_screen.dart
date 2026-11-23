import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../../competition/providers/competition_provider.dart';
import '../engine/rep_counter_engine.dart';
import '../services/pose_detector_service.dart';
import '../widgets/pose_painter.dart';

class AiCounterScreen extends ConsumerStatefulWidget {
  const AiCounterScreen({super.key});

  @override
  ConsumerState<AiCounterScreen> createState() => _AiCounterScreenState();
}

class _AiCounterScreenState extends ConsumerState<AiCounterScreen> {
  CameraController? _cameraController;
  PoseDetectorService? _poseService;
  late final PushupCounterEngine _engine;
  RepCounterState _counterState = RepCounterState.initial();

  Map<int, PoseKeypoint> _latestLandmarks = {};
  Size _imageSize = const Size(480, 640);

  bool _isSimulatorMode = false;
  bool _isSubmitting = false;

  final Stopwatch _sessionStopwatch = Stopwatch();
  Timer? _uiRefreshTimer;

  // Simulator controls for web/testing
  double _simulatedElbowAngle = 175.0;

  @override
  void initState() {
    super.initState();
    _engine = PushupCounterEngine(
      onRepCounted: () {
        HapticFeedback.heavyImpact();
      },
      onHalfRepRejected: () {
        HapticFeedback.vibrate();
      },
    );

    _sessionStopwatch.start();
    _uiRefreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });

    if (kIsWeb) {
      _initSimulator();
    } else {
      _initCamera();
    }
  }

  @override
  void dispose() {
    _uiRefreshTimer?.cancel();
    _sessionStopwatch.stop();
    _cameraController?.dispose();
    _poseService?.dispose();
    super.dispose();
  }

  void _initSimulator() {
    setState(() {
      _isSimulatorMode = true;
    });
    _updateSimulatedFrame();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _initSimulator();
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _initSimulator();
        return;
      }

      // Pick front camera so athlete sees screen while doing pushups
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium, // 480p to keep CPU cool on $100 tier devices
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _poseService = PoseDetectorService();

      _cameraController!.startImageStream((image) async {
        if (_poseService == null) return;
        final landmarks = await _poseService!.processCameraImage(image, frontCamera);
        if (landmarks != null && mounted) {
          final newState = _engine.processLandmarks(landmarks);
          setState(() {
            _latestLandmarks = landmarks;
            _counterState = newState;
            _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          });
        }
      });

      // Camera stream started
    } catch (_) {
      _initSimulator();
    }
  }

  void _updateSimulatedFrame() {
    // Generate simulated landmarks based on sliders
    final rad = _simulatedElbowAngle * 3.14159 / 180.0;
    final wristX = 140.0 + 80.0 * (1.0 - (rad / 3.14159));
    final wristY = 280.0 + 30.0 * (rad / 3.14159);

    final mockLandmarks = <int, PoseKeypoint>{
      11: const PoseKeypoint(x: 100, y: 150), // Shoulder
      13: const PoseKeypoint(x: 140, y: 220), // Elbow
      15: PoseKeypoint(x: wristX, y: wristY),  // Wrist
      23: const PoseKeypoint(x: 80, y: 320),  // Hip
      27: const PoseKeypoint(x: 60, y: 480),  // Ankle
    };

    final newState = _engine.processLandmarks(mockLandmarks);
    setState(() {
      _latestLandmarks = mockLandmarks;
      _counterState = newState;
      _imageSize = const Size(360, 540);
    });
  }

  Future<void> _handleFinishWorkout() async {
    setState(() => _isSubmitting = true);

    final totalReps = _counterState.repCount;
    final totalDurationSec = _sessionStopwatch.elapsed.inSeconds;

    if (totalReps > 0) {
      final notifier = ref.read(attemptsNotifierProvider.notifier);
      await notifier.submitAttempt(
        exercise: 'pushup',
        reps: totalReps,
        proofType: 'ai_count',
      );
      // Refresh leaderboard
      ref.read(leaderboardNotifierProvider.notifier).fetchLeaderboard();
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSessionSummaryDialog(totalReps, totalDurationSec);
    }
  }

  void _showSessionSummaryDialog(int reps, int durationSec) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCardSolid,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
        title: Text('SESSION COMPLETE', style: AppTypography.headingLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI VERIFIED PUSH-UPS', style: AppTypography.headingSmall),
            const SizedBox(height: AppSpacing.md),
            _buildSummaryRow('Valid Reps', '$reps', AppColors.primary),
            _buildSummaryRow('Half-Reps Rejected', '${_counterState.halfRepsRejected}', AppColors.danger),
            _buildSummaryRow('Workout Time', '${durationSec}s', AppColors.textPrimary),
            _buildSummaryRow('Pace', reps > 0 ? '${(durationSec / reps).toStringAsFixed(1)}s / rep' : '--', AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Result submitted as AI Verified count to your district leaderboard.',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        actions: [
          PrimaryButton(
            text: 'VIEW LEADERBOARD',
            onPressed: () {
              Navigator.of(context).pop(); // dialog
              Navigator.of(context).pop(); // screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(value, style: AppTypography.headingSmall.copyWith(color: valueColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('AI PUSH-UP COUNTER', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: Icon(
              _isSimulatorMode ? Icons.camera_alt_outlined : Icons.tune,
              color: AppColors.primary,
            ),
            tooltip: _isSimulatorMode ? 'Camera Mode' : 'Simulator Mode',
            onPressed: () {
              setState(() {
                _isSimulatorMode = !_isSimulatorMode;
                if (_isSimulatorMode) {
                  _initSimulator();
                } else {
                  _initCamera();
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Camera Feed or Simulator Viewport
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera / Viewport Background
                  if (_cameraController != null && _cameraController!.value.isInitialized && !_isSimulatorMode)
                    CameraPreview(_cameraController!)
                  else
                    Container(
                      color: AppColors.bgSidebar,
                      child: const Center(
                        child: Icon(Icons.fitness_center, size: 80, color: AppColors.borderHover),
                      ),
                    ),

                  // Skeletal Landmarks Custom Painter
                  if (_latestLandmarks.isNotEmpty)
                    CustomPaint(
                      painter: PosePainter(
                        landmarks: _latestLandmarks,
                        imageSize: _imageSize,
                        isFrontCamera: true,
                        isFormValid: _counterState.isFormValid,
                        currentElbowAngle: _counterState.elbowAngle,
                      ),
                    ),

                  // Status Indicator Top Banner
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.bgMain.withValues(alpha: 0.85),
                        borderRadius: AppSpacing.roundedMd,
                        border: Border.all(
                          color: _counterState.isFormValid ? AppColors.primary : AppColors.danger,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _counterState.isInPosition ? Icons.check_circle : Icons.warning_amber,
                            size: 16,
                            color: _counterState.isFormValid ? AppColors.primary : AppColors.danger,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              _counterState.formFeedback,
                              style: AppTypography.button.copyWith(
                                color: _counterState.isFormValid ? AppColors.primary : AppColors.danger,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Giant Live Rep Counter
                  Positioned(
                    bottom: AppSpacing.md,
                    left: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.bgMain.withValues(alpha: 0.9),
                        borderRadius: AppSpacing.roundedLg,
                        border: Border.all(color: AppColors.primary, width: 2),
                        boxShadow: [AppColors.glowShadow(AppColors.primary)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_counterState.repCount}',
                            style: AppTypography.displayLarge.copyWith(
                              fontSize: 52,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('REPS', style: AppTypography.headingSmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Controls & Metrics Section
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.bgMain,
                  border: Border(top: BorderSide(color: AppColors.borderHover)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Simulator Sliders (if in Web / Simulator mode)
                    if (_isSimulatorMode) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Simulate Elbow: ${_simulatedElbowAngle.round()}°', style: AppTypography.bodySmall),
                          Text(
                            _simulatedElbowAngle <= 90 ? 'DEPTH REACHED' : 'DESCENDING',
                            style: AppTypography.badge.copyWith(
                              color: _simulatedElbowAngle <= 90 ? AppColors.accentGreen : AppColors.accentGold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _simulatedElbowAngle,
                        min: 65,
                        max: 180,
                        activeColor: AppColors.primary,
                        onChanged: (v) {
                          _simulatedElbowAngle = v;
                          _updateSimulatedFrame();
                        },
                      ),
                    ],

                    // Metrics Strip
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            'DEPTH ANGLE',
                            '${_counterState.elbowAngle.round()}°',
                            _counterState.elbowAngle <= 90 ? AppColors.accentGreen : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildMetricTile(
                            'HALF REPS',
                            '${_counterState.halfRepsRejected}',
                            _counterState.halfRepsRejected > 0 ? AppColors.danger : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildMetricTile(
                            'TIME',
                            '${_sessionStopwatch.elapsed.inSeconds}s',
                            AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Finish Workout CTA
                    PrimaryButton(
                      text: 'FINISH WORKOUT',
                      icon: Icons.flag,
                      isLoading: _isSubmitting,
                      onPressed: _handleFinishWorkout,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.headingSmall.copyWith(color: color, fontSize: 16)),
        ],
      ),
    );
  }
}
