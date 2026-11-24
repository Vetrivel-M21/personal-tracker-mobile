import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_tracker_mobile/core/theme/app_theme.dart';
import 'package:personal_tracker_mobile/features/calisthenics/models/calisthenics_skill.dart';
import 'package:personal_tracker_mobile/features/calisthenics/widgets/skill_node_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CalisthenicsSkill Model', () {
    test('Correctly deserializes from API JSON', () {
      final json = {
        'id': 'push-1',
        'branch': 'Push',
        'order': 0,
        'tier': 1,
        'name': 'Wall Push-up',
        'description': 'Perform 15 clean push-ups against a wall.',
        'unlocked': true,
        'available': true,
      };

      final skill = CalisthenicsSkill.fromJson(json);

      expect(skill.id, equals('push-1'));
      expect(skill.branch, equals('Push'));
      expect(skill.order, equals(0));
      expect(skill.tier, equals(1));
      expect(skill.name, equals('Wall Push-up'));
      expect(skill.unlocked, isTrue);
      expect(skill.available, isTrue);
    });

    test('copyWith updates fields as expected', () {
      const skill = CalisthenicsSkill(
        id: 'pull-1',
        branch: 'Pull',
        order: 0,
        tier: 1,
        name: 'Dead Hang',
        description: 'Hold 30s',
        unlocked: false,
        available: true,
      );

      final unlocked = skill.copyWith(unlocked: true);
      expect(unlocked.unlocked, isTrue);
      expect(unlocked.id, equals('pull-1'));
      expect(unlocked.name, equals('Dead Hang'));
    });
  });

  group('SkillNodeCard Widget', () {
    testWidgets('Renders unlocked skill with checkmark', (tester) async {
      const skill = CalisthenicsSkill(
        id: 'push-1',
        branch: 'Push',
        order: 0,
        tier: 1,
        name: 'Wall Push-up',
        description: 'Perform 15 clean push-ups against a wall.',
        unlocked: true,
        available: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SkillNodeCard(
              skill: skill,
              isUnlocking: false,
              onUnlock: () {},
            ),
          ),
        ),
      );

      expect(find.text('Wall Push-up'), findsOneWidget);
      expect(find.text('T1'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Renders available locked skill with unlock CTA', (tester) async {
      const skill = CalisthenicsSkill(
        id: 'push-2',
        branch: 'Push',
        order: 1,
        tier: 1,
        name: 'Incline Push-up',
        description: 'Perform 12 push-ups.',
        unlocked: false,
        available: true,
      );

      bool unlockedPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SkillNodeCard(
              skill: skill,
              isUnlocking: false,
              onUnlock: () {
                unlockedPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('UNLOCK SKILL'), findsOneWidget);
      await tester.tap(find.text('UNLOCK SKILL'));
      expect(unlockedPressed, isTrue);
    });
  });
}

