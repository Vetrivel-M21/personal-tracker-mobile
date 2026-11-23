import 'dart:math' as math;
import '../config/rep_counter_config.dart';

/// Normalized 3D joint landmark keypoint representation
class PoseKeypoint {
  final double x;
  final double y;
  final double z;
  final double confidence;

  const PoseKeypoint({
    required this.x,
    required this.y,
    this.z = 0.0,
    this.confidence = 1.0,
  });
}

/// The discrete stages of a push-up repetition
enum RepStage {
  waitingForPosition,
  up,
  descending,
  bottomReached,
  ascending,
}

/// Real-time evaluation output from the counter engine
class RepCounterState {
  final int repCount;
  final int halfRepsRejected;
  final RepStage stage;
  final double elbowAngle;
  final double spineAngle;
  final bool isInPosition;
  final bool isFormValid;
  final String formFeedback;
  final List<double> repDurations; // In seconds
  final bool justCountedRep;

  const RepCounterState({
    required this.repCount,
    required this.halfRepsRejected,
    required this.stage,
    required this.elbowAngle,
    required this.spineAngle,
    required this.isInPosition,
    required this.isFormValid,
    required this.formFeedback,
    required this.repDurations,
    this.justCountedRep = false,
  });

  factory RepCounterState.initial() {
    return const RepCounterState(
      repCount: 0,
      halfRepsRejected: 0,
      stage: RepStage.waitingForPosition,
      elbowAngle: 180.0,
      spineAngle: 180.0,
      isInPosition: false,
      isFormValid: true,
      formFeedback: 'Get into plank position',
      repDurations: [],
      justCountedRep: false,
    );
  }

  RepCounterState copyWith({
    int? repCount,
    int? halfRepsRejected,
    RepStage? stage,
    double? elbowAngle,
    double? spineAngle,
    bool? isInPosition,
    bool? isFormValid,
    String? formFeedback,
    List<double>? repDurations,
    bool? justCountedRep,
  }) {
    return RepCounterState(
      repCount: repCount ?? this.repCount,
      halfRepsRejected: halfRepsRejected ?? this.halfRepsRejected,
      stage: stage ?? this.stage,
      elbowAngle: elbowAngle ?? this.elbowAngle,
      spineAngle: spineAngle ?? this.spineAngle,
      isInPosition: isInPosition ?? this.isInPosition,
      isFormValid: isFormValid ?? this.isFormValid,
      formFeedback: formFeedback ?? this.formFeedback,
      repDurations: repDurations ?? this.repDurations,
      justCountedRep: justCountedRep ?? this.justCountedRep,
    );
  }
}

/// Pure Dart biomechanics engine that processes keypoints and detects push-ups
class PushupCounterEngine {
  RepCounterState _state = RepCounterState.initial();
  DateTime? _repStartTime;
  final void Function()? onRepCounted;
  final void Function()? onHalfRepRejected;

  PushupCounterEngine({this.onRepCounted, this.onHalfRepRejected});

  RepCounterState get state => _state;

  void reset() {
    _state = RepCounterState.initial();
    _repStartTime = null;
  }

  /// Calculates the 2D interior angle at point B in degrees between vector BA and vector BC.
  static double calculateAngle(PoseKeypoint a, PoseKeypoint b, PoseKeypoint c) {
    final double radians = math.atan2(c.y - b.y, c.x - b.x) - math.atan2(a.y - b.y, a.x - b.x);
    double angle = (radians * 180.0 / math.pi).abs();
    if (angle > 180.0) {
      angle = 360.0 - angle;
    }
    return angle;
  }

  /// Processes a single frame of pose landmarks.
  /// Landmark indices follow Google ML Kit / BlazePose standard topology:
  /// 11: left shoulder, 12: right shoulder
  /// 13: left elbow,    14: right elbow
  /// 15: left wrist,    16: right wrist
  /// 23: left hip,      24: right hip
  /// 27: left ankle,    28: right ankle
  RepCounterState processLandmarks(Map<int, PoseKeypoint> landmarks) {
    final leftShoulder = landmarks[11];
    final rightShoulder = landmarks[12];
    final leftElbow = landmarks[13];
    final rightElbow = landmarks[14];
    final leftWrist = landmarks[15];
    final rightWrist = landmarks[16];
    final leftHip = landmarks[23];
    final rightHip = landmarks[24];
    final leftAnkle = landmarks[27];
    final rightAnkle = landmarks[28];

    // Determine the most visible side to track
    final leftArmVisible = leftShoulder != null &&
        leftElbow != null &&
        leftWrist != null &&
        leftShoulder.confidence >= RepCounterConfig.minLandmarkConfidence &&
        leftElbow.confidence >= RepCounterConfig.minLandmarkConfidence &&
        leftWrist.confidence >= RepCounterConfig.minLandmarkConfidence;

    final rightArmVisible = rightShoulder != null &&
        rightElbow != null &&
        rightWrist != null &&
        rightShoulder.confidence >= RepCounterConfig.minLandmarkConfidence &&
        rightElbow.confidence >= RepCounterConfig.minLandmarkConfidence &&
        rightWrist.confidence >= RepCounterConfig.minLandmarkConfidence;

    if (!leftArmVisible && !rightArmVisible) {
      _state = _state.copyWith(
        isInPosition: false,
        justCountedRep: false,
        formFeedback: 'Get in frame & check lighting',
      );
      return _state;
    }

    // Pick side with highest confidence
    final bool useLeft = leftArmVisible &&
        (!rightArmVisible ||
            ((leftShoulder.confidence + leftElbow.confidence + leftWrist.confidence) >=
                (rightShoulder.confidence + rightElbow.confidence + rightWrist.confidence)));

    final shoulder = useLeft ? leftShoulder : rightShoulder!;
    final elbow = useLeft ? leftElbow : rightElbow!;
    final wrist = useLeft ? leftWrist : rightWrist!;
    final hip = useLeft ? (leftHip ?? rightHip) : (rightHip ?? leftHip);
    final ankle = useLeft ? (leftAnkle ?? rightAnkle) : (rightAnkle ?? leftAnkle);

    // Compute active elbow angle
    final double elbowAngle = calculateAngle(shoulder, elbow, wrist);

    // Compute spine/hip alignment angle if available
    double spineAngle = 180.0;
    bool isSpineAligned = true;
    if (hip != null && ankle != null) {
      spineAngle = calculateAngle(shoulder, hip, ankle);
      if (spineAngle < RepCounterConfig.minBodyAlignmentAngle) {
        isSpineAligned = false;
      }
    }

    // Evaluate Finite State Machine
    return _transitionFSM(
      elbowAngle: elbowAngle,
      spineAngle: spineAngle,
      isSpineAligned: isSpineAligned,
    );
  }

  RepCounterState _transitionFSM({
    required double elbowAngle,
    required double spineAngle,
    required bool isSpineAligned,
  }) {
    bool justCounted = false;
    RepStage nextStage = _state.stage;
    String feedback = _state.formFeedback;
    int reps = _state.repCount;
    int halfReps = _state.halfRepsRejected;
    List<double> durations = List.from(_state.repDurations);

    if (!isSpineAligned) {
      feedback = 'Keep hips straight!';
    }

    switch (_state.stage) {
      case RepStage.waitingForPosition:
        if (!isSpineAligned) {
          feedback = 'Keep hips straight!';
        } else if (elbowAngle >= RepCounterConfig.pushupUpElbowAngle) {
          nextStage = RepStage.up;
          feedback = 'Ready! Lower down';
        } else {
          feedback = 'Straighten arms into plank';
        }
        break;

      case RepStage.up:
        if (!isSpineAligned) {
          feedback = 'Keep hips straight!';
        } else if (elbowAngle <= RepCounterConfig.pushupDescendingAngle) {
          nextStage = RepStage.descending;
          _repStartTime = DateTime.now();
          feedback = 'Going down...';
        } else {
          feedback = 'Ready! Lower down';
        }
        break;

      case RepStage.descending:
        if (elbowAngle <= RepCounterConfig.pushupDownElbowAngle) {
          nextStage = RepStage.bottomReached;
          feedback = 'Depth reached! Push up!';
        } else if (elbowAngle >= RepCounterConfig.pushupUpElbowAngle - 10) {
          // Half-rep detected: rose back up before hitting downElbowAngle
          halfReps += 1;
          nextStage = RepStage.up;
          feedback = 'Half rep rejected! Go lower.';
          onHalfRepRejected?.call();
        } else {
          feedback = 'Lower chest...';
        }
        break;

      case RepStage.bottomReached:
        if (elbowAngle > RepCounterConfig.pushupDownElbowAngle + 15) {
          nextStage = RepStage.ascending;
          feedback = 'Pushing up...';
        }
        break;

      case RepStage.ascending:
        if (elbowAngle >= RepCounterConfig.pushupUpElbowAngle) {
          // Rep successfully completed!
          final durationMs = _repStartTime != null
              ? DateTime.now().difference(_repStartTime!).inMilliseconds
              : 1000;

          if (durationMs >= RepCounterConfig.minRepDurationMs) {
            reps += 1;
            justCounted = true;
            durations.add(durationMs / 1000.0);
            feedback = 'Rep $reps counted!';
            onRepCounted?.call();
          }
          nextStage = RepStage.up;
        } else {
          feedback = 'Lock out arms...';
        }
        break;
    }

    _state = _state.copyWith(
      repCount: reps,
      halfRepsRejected: halfReps,
      stage: nextStage,
      elbowAngle: elbowAngle,
      spineAngle: spineAngle,
      isInPosition: true,
      isFormValid: isSpineAligned,
      formFeedback: feedback,
      repDurations: durations,
      justCountedRep: justCounted,
    );

    return _state;
  }
}
