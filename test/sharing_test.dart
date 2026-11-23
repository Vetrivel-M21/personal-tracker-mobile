import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_tracker_mobile/data/models/competition_models.dart';
import 'package:personal_tracker_mobile/features/sharing/providers/referral_provider.dart';
import 'package:personal_tracker_mobile/features/sharing/screens/invite_stats_screen.dart';
import 'package:personal_tracker_mobile/features/sharing/services/invite_link_service.dart';
import 'package:personal_tracker_mobile/features/sharing/widgets/share_card.dart';

void main() {
  group('InviteLinkService Tests', () {
    test('buildInviteUrl generates valid referral URL', () {
      final url = InviteLinkService.buildInviteUrl('TN_CHAMP');
      expect(url, contains('invite?ref=TN_CHAMP'));
    });

    test('buildChallengeUrl generates valid 1-on-1 challenge URL with query parameters', () {
      final url = InviteLinkService.buildChallengeUrl(
        referralCode: 'TAMIL99',
        exercise: 'pushup',
        targetReps: 55,
        challengerName: 'Vikram',
        area: 'Anna Nagar',
      );

      final uri = Uri.parse(url);
      expect(uri.path, contains('/challenge'));
      expect(uri.queryParameters['ref'], 'TAMIL99');
      expect(uri.queryParameters['exercise'], 'pushup');
      expect(uri.queryParameters['target'], '55');
      expect(uri.queryParameters['challenger'], 'Vikram');
      expect(uri.queryParameters['area'], 'Anna Nagar');
    });

    test('buildInviteMessage contains referral code and call to action', () {
      final msg = InviteLinkService.buildInviteMessage(
        referralCode: 'SQUAD12',
        displayName: 'Surya',
        area: 'Coimbatore',
      );

      expect(msg, contains('SQUAD12'));
      expect(msg, contains('Coimbatore, Tamil Nadu'));
      expect(msg, contains('invite?ref=SQUAD12'));
    });

    test('buildChallengeMessage contains target reps and exercise name', () {
      final msg = InviteLinkService.buildChallengeMessage(
        referralCode: 'BEAST1',
        challengerName: 'Karthi',
        exercise: 'pullup',
        reps: 20,
        area: 'Madurai',
      );

      expect(msg, contains('Karthi'));
      expect(msg, contains('20 Pull-ups in Madurai'));
      expect(msg, contains('challenge?'));
    });

    test('buildWhatsAppUrl properly percent-encodes text', () {
      final waUrl = InviteLinkService.buildWhatsAppUrl('Hello Tamil Nadu!');
      expect(waUrl, startsWith('https://api.whatsapp.com/send?text='));
      expect(waUrl, contains('Hello%20Tamil%20Nadu!'));
    });
  });

  group('ReferralStatsModel Serialization', () {
    test('fromJson and toJson maintain data fidelity', () {
      final json = {
        'referral_code': 'KINGS10',
        'invite_count': 14,
        'verified_invites_count': 10,
        'active_competitors_count': 6,
      };

      final model = ReferralStatsModel.fromJson(json);
      expect(model.referralCode, 'KINGS10');
      expect(model.inviteCount, 14);
      expect(model.verifiedInvitesCount, 10);
      expect(model.activeCompetitorsCount, 6);

      final output = model.toJson();
      expect(output['referral_code'], 'KINGS10');
      expect(output['invite_count'], 14);
      expect(output['verified_invites_count'], 10);
      expect(output['active_competitors_count'], 6);
    });
  });

  group('ShareCard Widget Tests', () {
    testWidgets('renders cleanly on 360px width without layout overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ShareCard(
                displayName: 'Santhosh Kumar',
                exercise: 'pushup',
                reps: 45,
                rank: 'S',
                area: 'Velachery',
                district: 'Chennai',
                state: 'Tamil Nadu',
                referralCode: 'VELACHERY01',
                isAiVerified: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('SANTHOSH KUMAR'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('MAX PUSH-UPS'), findsOneWidget);
      expect(find.text('VELACHERY • CHENNAI • TAMIL NADU'), findsOneWidget);
      expect(find.text('AI POSE VERIFIED'), findsOneWidget);
      expect(find.text('CODE: VELACHERY01'), findsOneWidget);
    });
  });

  group('InviteStatsScreen Widget Tests', () {
    testWidgets('renders referral stats and share preview', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockStats = const ReferralStatsModel(
        referralCode: 'TITAN77',
        inviteCount: 18,
        verifiedInvitesCount: 12,
        activeCompetitorsCount: 7,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralStatsProvider.overrideWith(() => _MockReferralNotifier(mockStats)),
          ],
          child: const MaterialApp(
            home: InviteStatsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('TERRITORY SQUAD & INVITES'), findsOneWidget);
      expect(find.text('TITAN77'), findsOneWidget);
      expect(find.text('FRIENDS JOINED'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('VERIFIED'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('ACTIVE DISTRICT COMPETITORS'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('SOCIAL SHARE CARD'), findsOneWidget);
    });
  });
}

class _MockReferralNotifier extends ReferralStatsNotifier {
  final ReferralStatsModel initial;
  _MockReferralNotifier(this.initial);

  @override
  Future<ReferralStatsModel> build() async {
    return initial;
  }
}

