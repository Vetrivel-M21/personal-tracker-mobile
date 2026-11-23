import 'package:flutter_test/flutter_test.dart';
import 'package:personal_tracker_mobile/core/config/app_config.dart';
import 'package:personal_tracker_mobile/data/models/auth_tokens.dart';
import 'package:personal_tracker_mobile/data/models/user_model.dart';

void main() {
  group('AppConfig tests', () {
    test('Default base URL and client header are configured properly', () {
      expect(AppConfig.baseUrl, isNotEmpty);
      expect(AppConfig.clientHeaderValue, equals('mobile'));
    });
  });

  group('AuthTokens Model tests', () {
    test('Correctly serializes and deserializes tokens JSON', () {
      final json = {
        'access_token': 'jwt_access_abc_123',
        'refresh_token': 'jwt_refresh_xyz_789',
      };

      final tokens = AuthTokens.fromJson(json);
      expect(tokens.accessToken, equals('jwt_access_abc_123'));
      expect(tokens.refreshToken, equals('jwt_refresh_xyz_789'));

      final mapped = tokens.toJson();
      expect(mapped['access_token'], equals('jwt_access_abc_123'));
      expect(mapped['refresh_token'], equals('jwt_refresh_xyz_789'));
    });
  });

  group('UserModel tests', () {
    test('Correctly deserializes user JSON with location attributes', () {
      final json = {
        'id': 'usr_test_1',
        'display_name': 'Tamil Hero',
        'level': 14,
        'xp': 1450,
        'area': 'Adyar',
        'district': 'Chennai',
        'state': 'Tamil Nadu',
        'referral_code': 'TAMIL_CHAMP',
        'is_admin': false,
        'created_at': '2026-01-01T00:00:00Z',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, equals('usr_test_1'));
      expect(user.displayName, equals('Tamil Hero'));
      expect(user.level, equals(14));
      expect(user.xp, equals(1450));
      expect(user.area, equals('Adyar'));
      expect(user.district, equals('Chennai'));
      expect(user.state, equals('Tamil Nadu'));
      expect(user.referralCode, equals('TAMIL_CHAMP'));
      expect(user.isAdmin, isFalse);
    });

    test('Handles null location and optional fields gracefully', () {
      final json = {
        'id': 'usr_test_2',
        'display_name': 'New Recruit',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, equals('usr_test_2'));
      expect(user.displayName, equals('New Recruit'));
      expect(user.level, equals(1));
      expect(user.xp, equals(0));
      expect(user.area, isNull);
      expect(user.district, isNull);
      expect(user.state, isNull);
      expect(user.isAdmin, isFalse);
    });
  });
}
