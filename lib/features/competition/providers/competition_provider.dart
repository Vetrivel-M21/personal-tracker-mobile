import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../data/models/competition_models.dart';
import '../../../data/repositories/competition_repository.dart';

final competitionRepositoryProvider = Provider<CompetitionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CompetitionRepository(apiClient: apiClient);
});

class LeaderboardFilter {
  final String exercise; // 'pushup' | 'pullup'
  final String scope; // 'district' | 'area' | 'state' | 'all'
  final String period; // 'all_time' | 'week'

  const LeaderboardFilter({
    this.exercise = 'pushup',
    this.scope = 'district',
    this.period = 'all_time',
  });

  LeaderboardFilter copyWith({
    String? exercise,
    String? scope,
    String? period,
  }) {
    return LeaderboardFilter(
      exercise: exercise ?? this.exercise,
      scope: scope ?? this.scope,
      period: period ?? this.period,
    );
  }
}

class LeaderboardState {
  final bool isLoading;
  final LeaderboardFilter filter;
  final LeaderboardResponseModel? data;
  final String? errorMessage;

  const LeaderboardState({
    required this.isLoading,
    required this.filter,
    this.data,
    this.errorMessage,
  });

  LeaderboardState.initial()
      : isLoading = true,
        filter = const LeaderboardFilter(),
        data = null,
        errorMessage = null;

  LeaderboardState copyWith({
    bool? isLoading,
    LeaderboardFilter? filter,
    LeaderboardResponseModel? data,
    String? errorMessage,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final CompetitionRepository _repository;

  LeaderboardNotifier(this._repository) : super(LeaderboardState.initial()) {
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _repository.getLeaderboard(
        exercise: state.filter.exercise,
        scope: state.filter.scope,
        period: state.filter.period,
        limit: 50,
        offset: 0,
      );
      state = state.copyWith(isLoading: false, data: res, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load leaderboard. Pull down to retry.',
      );
    }
  }

  void setExercise(String exercise) {
    if (state.filter.exercise != exercise) {
      state = state.copyWith(filter: state.filter.copyWith(exercise: exercise));
      fetchLeaderboard();
    }
  }

  void setScope(String scope) {
    if (state.filter.scope != scope) {
      state = state.copyWith(filter: state.filter.copyWith(scope: scope));
      fetchLeaderboard();
    }
  }

  void setPeriod(String period) {
    if (state.filter.period != period) {
      state = state.copyWith(filter: state.filter.copyWith(period: period));
      fetchLeaderboard();
    }
  }
}

final leaderboardNotifierProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  final repository = ref.watch(competitionRepositoryProvider);
  return LeaderboardNotifier(repository);
});

class AttemptsState {
  final bool isLoading;
  final bool isSubmitting;
  final List<AttemptModel> attempts;
  final String? errorMessage;
  final AttemptModel? lastSubmitted;

  const AttemptsState({
    required this.isLoading,
    required this.isSubmitting,
    required this.attempts,
    this.errorMessage,
    this.lastSubmitted,
  });

  AttemptsState.initial()
      : isLoading = false,
        isSubmitting = false,
        attempts = const [],
        errorMessage = null,
        lastSubmitted = null;

  AttemptsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<AttemptModel>? attempts,
    String? errorMessage,
    AttemptModel? lastSubmitted,
  }) {
    return AttemptsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      attempts: attempts ?? this.attempts,
      errorMessage: errorMessage,
      lastSubmitted: lastSubmitted ?? this.lastSubmitted,
    );
  }
}

class AttemptsNotifier extends StateNotifier<AttemptsState> {
  final CompetitionRepository _repository;

  AttemptsNotifier(this._repository) : super(AttemptsState.initial()) {
    loadMyAttempts();
  }

  Future<void> loadMyAttempts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getMyAttempts();
      state = state.copyWith(isLoading: false, attempts: list, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load past attempts.',
      );
    }
  }

  Future<bool> submitAttempt({
    required String exercise,
    required int reps,
    required String proofType,
    String? videoUrl,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final attempt = await _repository.submitAttempt(
        exercise: exercise,
        reps: reps,
        proofType: proofType,
        videoUrl: videoUrl,
      );

      final updatedAttempts = [attempt, ...state.attempts];
      state = state.copyWith(
        isSubmitting: false,
        attempts: updatedAttempts,
        lastSubmitted: attempt,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Submission failed. Please check your connection and try again.',
      );
      return false;
    }
  }
}

final attemptsNotifierProvider =
    StateNotifierProvider<AttemptsNotifier, AttemptsState>((ref) {
  final repository = ref.watch(competitionRepositoryProvider);
  return AttemptsNotifier(repository);
});
