import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_tracker_mobile/core/constants/tamil_nadu_locations.dart';
import 'package:personal_tracker_mobile/core/theme/app_theme.dart';
import 'package:personal_tracker_mobile/data/models/competition_models.dart';
import 'package:personal_tracker_mobile/features/competition/screens/leaderboard_screen.dart';
import 'package:personal_tracker_mobile/features/competition/screens/submit_attempt_screen.dart';
import 'package:personal_tracker_mobile/features/onboarding/screens/location_setup_screen.dart';

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

  group('TamilNaduLocations Constants', () {
    test('Contains all 38 administrative districts and default state', () {
      expect(TamilNaduLocations.defaultState, equals('Tamil Nadu'));
      expect(TamilNaduLocations.districts.length, equals(38));
      expect(TamilNaduLocations.districts, contains('Chennai'));
      expect(TamilNaduLocations.districts, contains('Coimbatore'));
      expect(TamilNaduLocations.districts, contains('Madurai'));
    });

    test('Provides popular areas for high-density districts', () {
      final chennaiAreas = TamilNaduLocations.getAreasForDistrict('Chennai');
      expect(chennaiAreas, contains('Adyar'));
      expect(chennaiAreas, contains('Anna Nagar'));
      expect(chennaiAreas, contains('Velachery'));

      final fallbackAreas = TamilNaduLocations.getAreasForDistrict('UnknownDistrict');
      expect(fallbackAreas, isNotEmpty);
    });
  });

  group('Competition Models Serialization', () {
    test('AttemptModel correctly parses JSON and status getters work', () {
      final json = {
        'id': 'att_123',
        'user_id': 'usr_456',
        'exercise': 'pushup',
        'reps': 50,
        'proof_type': 'video',
        'video_url': 'https://youtube.com/shorts/sample',
        'status': 'pending',
        'created_at': '2026-02-01T10:00:00Z',
      };

      final attempt = AttemptModel.fromJson(json);
      expect(attempt.id, equals('att_123'));
      expect(attempt.exercise, equals('pushup'));
      expect(attempt.reps, equals(50));
      expect(attempt.isPending, isTrue);
      expect(attempt.isVerified, isFalse);
      expect(attempt.isRejected, isFalse);
      expect(attempt.videoUrl, equals('https://youtube.com/shorts/sample'));
    });

    test('LeaderboardEntryModel parses JSON and formats location label', () {
      final json = {
        'rank': 1,
        'user_id': 'usr_hero',
        'display_name': 'Iron Pushup Champ',
        'username': 'iron_champ',
        'area': 'Adyar',
        'district': 'Chennai',
        'state': 'Tamil Nadu',
        'best_reps': 85,
      };

      final entry = LeaderboardEntryModel.fromJson(json);
      expect(entry.rank, equals(1));
      expect(entry.displayName, equals('Iron Pushup Champ'));
      expect(entry.bestReps, equals(85));
      expect(entry.locationLabel, equals('Adyar, Chennai, Tamil Nadu'));
    });

    test('LeaderboardResponseModel parses entries and caller myRank', () {
      final json = {
        'exercise': 'pushup',
        'scope': 'district',
        'period': 'all_time',
        'total': 1,
        'limit': 20,
        'offset': 0,
        'entries': [
          {
            'rank': 1,
            'user_id': 'usr_1',
            'display_name': 'Athlete A',
            'username': 'ath_a',
            'district': 'Chennai',
            'best_reps': 70,
          }
        ],
        'my_rank': {
          'rank': 1,
          'user_id': 'usr_1',
          'display_name': 'Athlete A',
          'username': 'ath_a',
          'district': 'Chennai',
          'best_reps': 70,
        }
      };

      final resp = LeaderboardResponseModel.fromJson(json);
      expect(resp.exercise, equals('pushup'));
      expect(resp.total, equals(1));
      expect(resp.entries.length, equals(1));
      expect(resp.myRank, isNotNull);
      expect(resp.myRank!.rank, equals(1));
    });
  });

  group('Phase 4 Screen Layout and Responsive Tests (360px)', () {
    testWidgets('LocationSetupScreen renders without overflow at 360px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const LocationSetupScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('SET YOUR TERRITORY'), findsOneWidget);
      expect(find.text('STATE'), findsOneWidget);
      expect(find.text('DISTRICT'), findsOneWidget);
      expect(find.text('ENTER ARENA'), findsOneWidget);
    });

    testWidgets('LeaderboardScreen renders tabs and filters without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const LeaderboardScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('ARENA LEADERBOARD'), findsOneWidget);
      expect(find.text('PUSH-UPS'), findsOneWidget);
      expect(find.text('PULL-UPS'), findsOneWidget);
    });

    testWidgets('SubmitAttemptScreen rep counter and stepper work properly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const SubmitAttemptScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('POST MAX-REP ATTEMPT'), findsOneWidget);

      // Verify default reps = 25
      expect(find.text('25'), findsOneWidget);

      // Tap +5 stepper
      final plus5Finder = find.text('+5');
      expect(plus5Finder, findsOneWidget);
      await tester.tap(plus5Finder);
      await tester.pump();

      // Expect reps to become 30
      expect(find.text('30'), findsOneWidget);
    });
  });
}
