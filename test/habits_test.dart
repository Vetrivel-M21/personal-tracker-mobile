import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_tracker_mobile/core/theme/app_theme.dart';
import 'package:personal_tracker_mobile/features/habits/models/daily_progress.dart';
import 'package:personal_tracker_mobile/features/habits/models/habit.dart';
import 'package:personal_tracker_mobile/features/habits/models/streak_stats.dart';
import 'package:personal_tracker_mobile/features/habits/widgets/streak_shield_badge.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Habit Models', () {
    test('Habit correctly parses JSON', () {
      final json = {
        'id': 'hab-123',
        'name': 'Cold Shower',
        'color': '#22D3EE',
        'icon': 'fa-solid fa-droplet',
        'schedule': 127,
        'created_at': '2026-11-24T10:00:00Z',
      };

      final habit = Habit.fromJson(json);
      expect(habit.id, equals('hab-123'));
      expect(habit.name, equals('Cold Shower'));
      expect(habit.schedule, equals(127));
      expect(habit.archivedAt, isNull);
    });

    test('DailyProgress parses completed habits and learning hours', () {
      final json = {
        'id': 'prog-456',
        'date': '2026-11-24',
        'completed_habit_ids': ['hab-1', 'hab-2'],
        'learning_hours': 2.5,
        'mood': 'Great',
        'notes': 'Crushed morning workout',
      };

      final prog = DailyProgress.fromJson(json);
      expect(prog.id, equals('prog-456'));
      expect(prog.date, equals('2026-11-24'));
      expect(prog.completedHabitIds.length, equals(2));
      expect(prog.learningHours, equals(2.5));
      expect(prog.mood, equals('Great'));
      expect(prog.notes, equals('Crushed morning workout'));
    });

    test('DailyProgress.empty initializes cleanly', () {
      final empty = DailyProgress.empty('2026-11-24');
      expect(empty.completedHabitIds, isEmpty);
      expect(empty.learningHours, equals(0.0));
      expect(empty.mood, equals('Good'));
    });

    test('StreakStats parses shields remaining and streak count', () {
      final json = {
        'current_streak': 14,
        'shields_remaining': 2,
      };

      final stats = StreakStats.fromJson(json);
      expect(stats.currentStreak, equals(14));
      expect(stats.shieldsRemaining, equals(2));
    });
  });

  group('StreakShieldBadge Widget', () {
    testWidgets('Renders streak count and banked shields', (tester) async {
      const stats = StreakStats(currentStreak: 7, shieldsRemaining: 2);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: StreakShieldBadge(stats: stats),
          ),
        ),
      );

      expect(find.text('7 DAYS'), findsOneWidget);
      expect(find.text('2 / 3 SHIELDS'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.byIcon(Icons.shield), findsNWidgets(2));
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });
  });
}

