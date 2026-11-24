import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_tracker_mobile/features/workouts/models/workout_session.dart';
import 'package:personal_tracker_mobile/features/workouts/models/workout_split.dart';
import 'package:personal_tracker_mobile/features/workouts/models/workout_template.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Workout Models', () {
    test('WorkoutTemplateSummary deserializes from JSON', () {
      final json = {
        'id': 'ppl-6day',
        'name': 'Push/Pull/Legs',
        'description': '6-day rotation',
        'days_per_week': 6,
        'level': 'Intermediate',
      };

      final t = WorkoutTemplateSummary.fromJson(json);
      expect(t.id, equals('ppl-6day'));
      expect(t.name, equals('Push/Pull/Legs'));
      expect(t.daysPerWeek, equals(6));
    });

    test('WorkoutSplitDetail parses nested days and exercises', () {
      final json = {
        'id': 'split-1',
        'name': 'My Upper Lower',
        'source': 'template',
        'is_active': true,
        'days': [
          {
            'id': 'day-1',
            'name': 'Upper A',
            'order': 0,
            'exercises': [
              {
                'id': 'ex-1',
                'name': 'Bench Press',
                'target_sets': 4,
                'target_reps': '6-8',
                'notes': 'Heavy compound',
                'order': 0,
              }
            ],
          }
        ],
      };

      final split = WorkoutSplitDetail.fromJson(json);
      expect(split.id, equals('split-1'));
      expect(split.isActive, isTrue);
      expect(split.days.length, equals(1));
      expect(split.days[0].name, equals('Upper A'));
      expect(split.days[0].exercises.length, equals(1));
      expect(split.days[0].exercises[0].name, equals('Bench Press'));
      expect(split.days[0].exercises[0].targetSets, equals(4));
    });

    test('WorkoutSessionSet request JSON formatting is correct', () {
      const set = WorkoutSessionSet(
        id: 'set-1',
        exerciseName: 'Deadlift',
        setNumber: 1,
        reps: 5,
        weightKg: 140.0,
      );

      final req = set.toRequestJson();
      expect(req['exerciseName'], equals('Deadlift'));
      expect(req['setNumber'], equals(1));
      expect(req['reps'], equals(5));
      expect(req['weightKg'], equals(140.0));
    });
  });
}

