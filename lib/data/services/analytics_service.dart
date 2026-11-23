import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Service responsible for recording first-party growth, viral loop, and usage telemetry.
class AnalyticsService {
  final ApiClient apiClient;

  AnalyticsService({required this.apiClient});

  /// Records an event to the backend growth_events database asynchronously.
  /// Fails silently without crashing or interrupting the user flow.
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? metadata]) async {
    try {
      await apiClient.dio.post(
        '/api/events',
        data: {
          'event_name': eventName,
          'metadata': metadata ?? <String, dynamic>{},
        },
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Telemetry failed for "$eventName": $e');
    }
  }

  /// Helper to record when a share action is triggered by the athlete.
  Future<void> trackShareTapped({
    required String platform,
    required String exercise,
    required int reps,
    String? rank,
  }) async {
    await trackEvent('share_tapped', {
      'platform': platform,
      'exercise': exercise,
      'reps': reps,
      'rank': rank,
    });
  }

  /// Helper to record when an invite link is clicked or opened.
  Future<void> trackInviteOpened(String referralCode) async {
    await trackEvent('invite_link_opened', {
      'referral_code': referralCode,
    });
  }

  /// Helper to record when a challenge is viewed.
  Future<void> trackChallengeViewed({
    required String referralCode,
    required String exercise,
    required int targetReps,
  }) async {
    await trackEvent('challenge_viewed', {
      'referral_code': referralCode,
      'exercise': exercise,
      'target_reps': targetReps,
    });
  }
}

/// Riverpod provider exposing AnalyticsService instance.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AnalyticsService(apiClient: apiClient);
});
