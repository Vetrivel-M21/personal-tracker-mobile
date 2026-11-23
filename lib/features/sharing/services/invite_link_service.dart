import '../../../core/config/app_config.dart';

/// Service for generating referral links, viral challenge invitations, and share messages.
class InviteLinkService {
  /// Base domain for public invite and challenge landings.
  /// Falls back to configured API hostname if not an overridden production web domain.
  static String get webLandingBaseUrl {
    final base = AppConfig.baseUrl;
    if (base.contains('localhost') || base.contains('127.0.0.1')) {
      return 'http://localhost:5173'; // Vite UI dev server fallback
    }
    return 'https://aura.fit';
  }

  /// Builds a standard invite link containing the athlete's referral code.
  /// Supports Android App Links and iOS Universal Links when installed,
  /// falling back to the web landing page when not installed.
  static String buildInviteUrl(String referralCode) {
    final cleanCode = referralCode.trim().toUpperCase();
    return '$webLandingBaseUrl/invite?ref=$cleanCode';
  }

  /// Builds a direct "Challenge a Friend" link to beat a specific rep count.
  static String buildChallengeUrl({
    required String referralCode,
    required String exercise,
    required int targetReps,
    required String challengerName,
    String? area,
  }) {
    final uri = Uri.parse('$webLandingBaseUrl/challenge').replace(
      queryParameters: {
        'ref': referralCode.trim().toUpperCase(),
        'exercise': exercise.trim().toLowerCase(),
        'target': targetReps.toString(),
        'challenger': challengerName.trim(),
        if (area != null && area.trim().isNotEmpty) 'area': area.trim(),
      },
    );
    return uri.toString();
  }

  /// Formats an engaging invite message for WhatsApp, Telegram, or SMS.
  static String buildInviteMessage({
    required String referralCode,
    required String displayName,
    String? area,
  }) {
    final cleanCode = referralCode.trim().toUpperCase();
    final inviteUrl = buildInviteUrl(cleanCode);
    final territory = (area != null && area.isNotEmpty) ? '$area, Tamil Nadu' : 'Tamil Nadu';

    return '⚔️ Join the Tamil Nadu Max-Rep Challenge!\n\n'
        'I am competing from $territory. Use my referral code "$cleanCode" '
        'to unlock the hunter rank system, calisthenics skill tree, and represent your district.\n\n'
        '👉 Tap to compete: $inviteUrl';
  }

  /// Formats a 1-on-1 direct challenge message to beat a specific score.
  static String buildChallengeMessage({
    required String referralCode,
    required String challengerName,
    required String exercise,
    required int reps,
    String? area,
  }) {
    final challengeUrl = buildChallengeUrl(
      referralCode: referralCode,
      exercise: exercise,
      targetReps: reps,
      challengerName: challengerName,
      area: area,
    );
    final exerciseLabel = exercise.toLowerCase() == 'pushup' ? 'Push-ups' : 'Pull-ups';
    final territory = (area != null && area.isNotEmpty) ? ' in $area' : '';

    return '🔥 1-ON-1 FITNESS CHALLENGE!\n\n'
        '$challengerName just crushed $reps $exerciseLabel$territory with AI camera verification!\n'
        'Think you can beat that score?\n\n'
        '👉 Accept Challenge: $challengeUrl';
  }

  /// Builds a WhatsApp direct-share deep link.
  static String buildWhatsAppUrl(String text) {
    return 'https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}';
  }
}

