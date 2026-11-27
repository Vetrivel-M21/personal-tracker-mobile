import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_tracker_mobile/core/theme/app_theme.dart';
import 'package:personal_tracker_mobile/features/counter/config/rep_counter_config.dart';
import 'package:personal_tracker_mobile/features/counter/engine/rep_counter_engine.dart';
import 'package:personal_tracker_mobile/features/counter/screens/ai_counter_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  group('RepCounterConfig Unit Tests', () {
    test('Push-up biomechanical thresholds are tuned properly', () {
      expect(RepCounterConfig.pushupUpElbowAngle, greaterThanOrEqualTo(150.0));
      expect(RepCounterConfig.pushupDownElbowAngle, lessThanOrEqualTo(95.0));
      expect(RepCounterConfig.minBodyAlignmentAngle, greaterThanOrEqualTo(130.0));
      expect(RepCounterConfig.minRepDurationMs, greaterThanOrEqualTo(400));
      expect(RepCounterConfig.targetProcessingFps, inInclusiveRange(15, 30));
    });
  });

  group('PushupCounterEngine Biomechanics & FSM Tests', () {
    test('Calculates angle between vectors accurately', () {
      // Form a 90 degree right angle: A=(0,1), B=(0,0), C=(1,0)
      const pA = PoseKeypoint(x: 0, y: 1);
      const pB = PoseKeypoint(x: 0, y: 0);
      const pC = PoseKeypoint(x: 1, y: 0);

      final angle = PushupCounterEngine.calculateAngle(pA, pB, pC);
      expect(angle, closeTo(90.0, 0.1));

      // Straight line: A=(-1,0), B=(0,0), C=(1,0) -> 180 degrees
      const pLineA = PoseKeypoint(x: -1, y: 0);
      const pLineB = PoseKeypoint(x: 0, y: 0);
      const pLineC = PoseKeypoint(x: 1, y: 0);

      final straightAngle = PushupCounterEngine.calculateAngle(pLineA, pLineB, pLineC);
      expect(straightAngle, closeTo(180.0, 0.1));
    });

    test('Full clean rep lifecycle increments rep count', () {
      final originalMin = RepCounterConfig.minRepDurationMs;
      RepCounterConfig.minRepDurationMs = 0;
      addTearDown(() => RepCounterConfig.minRepDurationMs = originalMin);

      int callbackRepCount = 0;
      final engine = PushupCounterEngine(onRepCounted: () => callbackRepCount++);

      // 1. Initial State: Waiting for position
      expect(engine.state.repCount, equals(0));
      expect(engine.state.stage, equals(RepStage.waitingForPosition));

      // 2. User gets into plank: arms straight (170 degrees)
      Map<int, PoseKeypoint> plankFrame = {
        11: const PoseKeypoint(x: 100, y: 100, confidence: 0.9), // Shoulder
        13: const PoseKeypoint(x: 100, y: 180, confidence: 0.9), // Elbow
        15: const PoseKeypoint(x: 100, y: 260, confidence: 0.9), // Wrist (straight vertical line = 180 deg)
        23: const PoseKeypoint(x: 100, y: 350, confidence: 0.9), // Hip
        27: const PoseKeypoint(x: 100, y: 500, confidence: 0.9), // Ankle
      };
      engine.processLandmarks(plankFrame);
      expect(engine.state.stage, equals(RepStage.up));

      // 3. Descending: elbow flexes to ~110 degrees
      Map<int, PoseKeypoint> descendingFrame = {
        11: const PoseKeypoint(x: 100, y: 100, confidence: 0.9),
        13: const PoseKeypoint(x: 100, y: 180, confidence: 0.9),
        15: const PoseKeypoint(x: 150, y: 200, confidence: 0.9),
        23: const PoseKeypoint(x: 100, y: 350, confidence: 0.9),
        27: const PoseKeypoint(x: 100, y: 500, confidence: 0.9),
      };
      engine.processLandmarks(descendingFrame);
      expect(engine.state.stage, equals(RepStage.descending));

      // 4. Bottom position: chest to floor, elbow flexes to ~75 degrees (<= 90 deg)
      Map<int, PoseKeypoint> bottomFrame = {
        11: const PoseKeypoint(x: 100, y: 100, confidence: 0.9),
        13: const PoseKeypoint(x: 100, y: 180, confidence: 0.9),
        15: const PoseKeypoint(x: 180, y: 160, confidence: 0.9), // ~76 deg
        23: const PoseKeypoint(x: 100, y: 350, confidence: 0.9),
        27: const PoseKeypoint(x: 100, y: 500, confidence: 0.9),
      };
      engine.processLandmarks(bottomFrame);
      expect(engine.state.stage, equals(RepStage.bottomReached));

      // 5. Ascending: rising back up
      engine.processLandmarks(descendingFrame);
      expect(engine.state.stage, equals(RepStage.ascending));

      // 6. Lockout: back to plank (180 deg)
      engine.processLandmarks(plankFrame);
      expect(engine.state.repCount, equals(1));
      expect(callbackRepCount, equals(1));
      expect(engine.state.repDurations.length, equals(1));
    });

    test('Half-reps are strictly rejected without incrementing count', () {
      int halfRepsRejected = 0;
      final engine = PushupCounterEngine(onHalfRepRejected: () => halfRepsRejected++);

      // Setup in plank
      Map<int, PoseKeypoint> plankFrame = {
        11: const PoseKeypoint(x: 100, y: 100, confidence: 0.9),
        13: const PoseKeypoint(x: 100, y: 180, confidence: 0.9),
        15: const PoseKeypoint(x: 100, y: 260, confidence: 0.9),
      };
      engine.processLandmarks(plankFrame);
      expect(engine.state.stage, equals(RepStage.up));

      // Drop to ~115 degrees (not reaching 90 degrees bottom threshold)
      Map<int, PoseKeypoint> shallowFrame = {
        11: const PoseKeypoint(x: 100, y: 100, confidence: 0.9),
        13: const PoseKeypoint(x: 100, y: 180, confidence: 0.9),
        15: const PoseKeypoint(x: 150, y: 200, confidence: 0.9),
      };
      engine.processLandmarks(shallowFrame);
      expect(engine.state.stage, equals(RepStage.descending));

      // Push back up to lockout without having reached bottom
      engine.processLandmarks(plankFrame);

      // Rep count must stay 0, halfRepsRejected must increment
      expect(engine.state.repCount, equals(0));
      expect(engine.state.halfRepsRejected, equals(1));
      expect(halfRepsRejected, equals(1));
      expect(engine.state.formFeedback, contains('Half rep rejected'));
    });

    test('Sagging hips triggers anti-cheat warning', () {
      final engine = PushupCounterEngine();

      // Plank with sagging hips: Shoulder=(100,100), Hip=(160,250), Ankle=(100,400) -> angle < 140
      Map<int, PoseKeypoint> saggingFrame = {
        11: const PoseKeypoint(x: 100, y: 100, confidence: 0.9),
        13: const PoseKeypoint(x: 100, y: 180, confidence: 0.9),
        15: const PoseKeypoint(x: 100, y: 260, confidence: 0.9),
        23: const PoseKeypoint(x: 200, y: 250, confidence: 0.9), // Hip way off alignment
        27: const PoseKeypoint(x: 100, y: 400, confidence: 0.9),
      };

      engine.processLandmarks(saggingFrame);
      expect(engine.state.isFormValid, isFalse);
      expect(engine.state.formFeedback, contains('Keep hips straight'));
    });
  });

  group('AiCounterScreen Widget & Responsive Layout Tests (360px)', () {
    testWidgets('AiCounterScreen renders simulator and live metrics at 360px width without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const AiCounterScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(tester.takeException(), isNull);
      expect(find.text('AI REP COUNTER'), findsOneWidget);
      expect(find.text('REPS'), findsOneWidget);
      expect(find.text('FINISH WORKOUT'), findsOneWidget);
      expect(find.text('DEPTH ANGLE'), findsOneWidget);
      expect(find.text('HALF REPS'), findsOneWidget);
    });
  });
}
