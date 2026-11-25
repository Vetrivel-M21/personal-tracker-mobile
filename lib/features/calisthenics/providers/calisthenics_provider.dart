import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/calisthenics_skill.dart';
import '../services/calisthenics_service.dart';

final calisthenicsServiceProvider = Provider<CalisthenicsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CalisthenicsService(apiClient: apiClient);
});

class CalisthenicsState {
  final bool isLoading;
  final Map<String, List<CalisthenicsSkill>> branches;
  final String? errorMessage;
  final String? unlockingSkillId;

  const CalisthenicsState({
    required this.isLoading,
    required this.branches,
    this.errorMessage,
    this.unlockingSkillId,
  });

  const CalisthenicsState.initial()
      : isLoading = true,
        branches = const {},
        errorMessage = null,
        unlockingSkillId = null;

  CalisthenicsState copyWith({
    bool? isLoading,
    Map<String, List<CalisthenicsSkill>>? branches,
    String? errorMessage,
    String? unlockingSkillId,
  }) {
    return CalisthenicsState(
      isLoading: isLoading ?? this.isLoading,
      branches: branches ?? this.branches,
      errorMessage: errorMessage,
      unlockingSkillId: unlockingSkillId,
    );
  }
}

class CalisthenicsNotifier extends StateNotifier<CalisthenicsState> {
  final CalisthenicsService _service;

  CalisthenicsNotifier(this._service) : super(const CalisthenicsState.initial()) {
    loadSkills();
  }

  Future<void> loadSkills() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final branches = await _service.getSkills();
      state = state.copyWith(isLoading: false, branches: branches);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> unlockSkill(String skillId) async {
    state = state.copyWith(unlockingSkillId: skillId, errorMessage: null);
    try {
      final updatedBranches = await _service.unlockSkill(skillId);
      state = state.copyWith(branches: updatedBranches, unlockingSkillId: null);
      return true;
    } catch (e) {
      state = state.copyWith(unlockingSkillId: null, errorMessage: e.toString());
      return false;
    }
  }
}

final calisthenicsNotifierProvider =
    StateNotifierProvider<CalisthenicsNotifier, CalisthenicsState>((ref) {
  final service = ref.watch(calisthenicsServiceProvider);
  return CalisthenicsNotifier(service);
});

