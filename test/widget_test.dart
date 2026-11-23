import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_tracker_mobile/core/theme/app_theme.dart';
import 'package:personal_tracker_mobile/features/demo/screens/design_system_demo_screen.dart';
import 'package:personal_tracker_mobile/widgets/app_buttons.dart';
import 'package:personal_tracker_mobile/widgets/empty_state.dart';
import 'package:personal_tracker_mobile/widgets/exp_bar.dart';
import 'package:personal_tracker_mobile/widgets/level_badge.dart';
import 'package:personal_tracker_mobile/widgets/quest_card.dart';
import 'package:personal_tracker_mobile/widgets/rank_badge.dart';
import 'package:personal_tracker_mobile/widgets/skeleton_loader.dart';
import 'package:personal_tracker_mobile/widgets/stat_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: child,
    );
  }

  group('Design System Demo Screen tests', () {
    testWidgets('Demo screen renders all widgets at 360px without overflow',
        (WidgetTester tester) async {
      // 360px width is standard low-end Android phone width
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const DesignSystemDemoScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify no rendering overflow exceptions occurred
      expect(tester.takeException(), isNull);

      // Verify essential sections are found
      expect(find.text('SYSTEM DESIGN DEMO'), findsOneWidget);
      expect(find.textContaining('Max-Rep'), findsOneWidget);

      // Verify badges exist
      expect(find.byType(LevelBadge), findsWidgets);
      expect(find.byType(RankBadge), findsWidgets);

      // Verify EXP bar
      expect(find.byType(ExpBar), findsOneWidget);

      // Verify stat cards
      expect(find.byType(StatCard), findsWidgets);

      // Verify quest cards
      expect(find.byType(QuestCard), findsWidgets);

      // Verify buttons
      expect(find.byType(PrimaryButton), findsWidgets);
      expect(find.byType(SecondaryButton), findsWidgets);

      // Verify skeletons
      expect(find.byType(SkeletonLoader), findsWidgets);

      // Verify empty state
      expect(find.byType(EmptyState), findsWidgets);
    });
  });

  group('Reusable Widget Unit Tests', () {
    testWidgets('PrimaryButton enforces 48px minimum height and handles tap',
        (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: Center(
              child: PrimaryButton(
                text: 'ACTION',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(PrimaryButton);
      expect(buttonFinder, findsOneWidget);

      final Size buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));

      await tester.tap(buttonFinder);
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('PrimaryButton shows CircularProgressIndicator when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(
            body: Center(
              child: PrimaryButton(
                text: 'ACTION',
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('StatCard displays label, value, and sublabel correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(
            body: StatCard(
              icon: Icons.flash_on,
              label: 'SCORE',
              value: '100',
              sublabel: 'TOP 5%',
            ),
          ),
        ),
      );

      expect(find.text('SCORE'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('TOP 5%'), findsOneWidget);
    });

    testWidgets('RankBadge renders correct rank styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(
            body: RankBadge(rank: 'S'),
          ),
        ),
      );

      expect(find.text('S-RANK'), findsOneWidget);
    });
  });
}
