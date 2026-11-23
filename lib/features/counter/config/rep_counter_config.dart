/// All AI rep counter thresholds and tuning parameters kept in a single clean config file.
class RepCounterConfig {
  RepCounterConfig._();

  // ---------------------------------------------------------------------------
  // Push-Up Biomechanics Thresholds
  // ---------------------------------------------------------------------------

  /// Elbow angle when user is in the extended "UP" (plank) position.
  /// Fully straight is ~180 degrees. We require at least 155 degrees to count lockout.
  static double pushupUpElbowAngle = 155.0;

  /// Elbow angle when user has lowered their chest to the floor.
  /// 90 degrees or less guarantees standard competition depth.
  static double pushupDownElbowAngle = 90.0;

  /// Elbow angle when descending transition begins.
  static double pushupDescendingAngle = 135.0;

  /// Anti-cheat: Minimum angle between (Shoulder -> Hip -> Ankle).
  /// Perfect plank is ~180 degrees. Sagging hips or piked butt drops below 140 degrees.
  static double minBodyAlignmentAngle = 140.0;

  /// Minimum landmark confidence score from ML Kit (0.0 to 1.0).
  /// Drops noisy/occluded frames in poor lighting.
  static double minLandmarkConfidence = 0.55;

  /// Minimum time (in milliseconds) required for one valid rep.
  /// Prevents camera flicker / jitter from triggering double counts.
  static int minRepDurationMs = 500;

  /// Maximum time (in milliseconds) before a stuck descent resets.
  static int maxRepDurationMs = 10000;

  // ---------------------------------------------------------------------------
  // Pull-Up Biomechanics Thresholds (Future-proofed)
  // ---------------------------------------------------------------------------

  /// Elbow angle in full dead hang (bottom).
  static double pullupHangElbowAngle = 160.0;

  /// Elbow angle with chin over bar (top).
  static double pullupTopElbowAngle = 70.0;

  // ---------------------------------------------------------------------------
  // Low-End Mobile Optimization
  // ---------------------------------------------------------------------------

  /// Max frame processing rate (FPS) to avoid CPU throttle on budget phones ($100 tier).
  /// 15-20 FPS is more than enough for human exercise velocity while keeping CPU low.
  static int targetProcessingFps = 18;

  /// Frame throttle interval in milliseconds: 1000 / targetProcessingFps
  static int get throttleIntervalMs => (1000 / targetProcessingFps).round();
}
