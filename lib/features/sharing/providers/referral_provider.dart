import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/competition_models.dart';
import '../../competition/providers/competition_provider.dart';

/// Async notifier managing the user's referral code and invite metrics.
class ReferralStatsNotifier extends AutoDisposeAsyncNotifier<ReferralStatsModel> {
  @override
  Future<ReferralStatsModel> build() async {
    return _fetchStats();
  }

  Future<ReferralStatsModel> _fetchStats() async {
    final repo = ref.read(competitionRepositoryProvider);
    return repo.getReferralStats();
  }

  /// Refreshes stats after a new friend joins or share occurs.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

/// Provider exposing the athlete's referral stats.
final referralStatsProvider =
    AutoDisposeAsyncNotifierProvider<ReferralStatsNotifier, ReferralStatsModel>(
  ReferralStatsNotifier.new,
);

