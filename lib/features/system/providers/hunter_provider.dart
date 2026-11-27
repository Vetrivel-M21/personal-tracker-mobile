import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/hunter_models.dart';
import '../services/hunter_service.dart';

final hunterServiceProvider = Provider<HunterService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HunterService(apiClient: apiClient);
});

class HunterState {
  final bool isLoading;
  final Quest? todayQuest;
  final HunterProfile? profile;
  final String? errorMessage;
  final String? lastRewardMessage;

  const HunterState({
    required this.isLoading,
    this.todayQuest,
    this.profile,
    this.errorMessage,
    this.lastRewardMessage,
  });

  const HunterState.initial()
      : isLoading = true,
        todayQuest = null,
        profile = null,
        errorMessage = null,
        lastRewardMessage = null;

  HunterState copyWith({
    bool? isLoading,
    Quest? todayQuest,
    HunterProfile? profile,
    String? errorMessage,
    String? lastRewardMessage,
  }) {
    return HunterState(
      isLoading: isLoading ?? this.isLoading,
      todayQuest: todayQuest ?? this.todayQuest,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      lastRewardMessage: lastRewardMessage,
    );
  }
}

class HunterNotifier extends StateNotifier<HunterState> {
  final HunterService _service;
  final Ref _ref;

  HunterNotifier(this._service, this._ref) : super(const HunterState.initial()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final quest = await _service.getTodayQuest();
      final profile = await _service.getHunterProfile();
      state = state.copyWith(
        isLoading: false,
        todayQuest: quest,
        profile: profile,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> startQuest() async {
    final current = state.todayQuest;
    if (current == null) return;
    try {
      final updated = await _service.startQuest(current.id);
      state = state.copyWith(todayQuest: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateProgress(String itemId, {int? count, int? delta}) async {
    final current = state.todayQuest;
    if (current == null) return;
    try {
      final updated = await _service.updateQuestProgress(current.id, itemId: itemId, count: count, delta: delta);
      state = state.copyWith(todayQuest: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<bool> completeQuest() async {
    final current = state.todayQuest;
    if (current == null) return false;
    try {
      final res = await _service.completeQuest(current.id);
      final questData = res['quest'] as Map<String, dynamic>;
      final updatedQuest = Quest.fromJson(questData);
      final xpEarned = res['xp_earned'] as int? ?? 0;
      final unlockedTitles = (res['unlocked_titles'] as List<dynamic>?)?.cast<String>() ?? [];

      String rewardMsg = 'Quest Cleared! +$xpEarned XP, Stats Upgraded!';
      if (unlockedTitles.isNotEmpty) {
        rewardMsg += ' Unlocked Title: ${unlockedTitles.join(", ")}';
      }

      final updatedProfile = await _service.getHunterProfile();
      state = state.copyWith(
        todayQuest: updatedQuest,
        profile: updatedProfile,
        lastRewardMessage: rewardMsg,
      );
      // Refresh auth profile user
      _ref.read(authNotifierProvider.notifier).checkAuthStatus();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final hunterNotifierProvider = StateNotifierProvider<HunterNotifier, HunterState>((ref) {
  final service = ref.watch(hunterServiceProvider);
  return HunterNotifier(service, ref);
});
