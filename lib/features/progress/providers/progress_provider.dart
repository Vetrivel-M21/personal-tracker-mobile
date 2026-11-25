import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/daily_progress.dart';
import '../services/progress_service.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProgressService(apiClient: apiClient);
});

class DailyProgressState {
  final bool isLoading;
  final DailyProgress? progress;
  final String? error;

  const DailyProgressState({
    this.isLoading = false,
    this.progress,
    this.error,
  });

  DailyProgressState copyWith({
    bool? isLoading,
    DailyProgress? progress,
    String? error,
  }) {
    return DailyProgressState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}

class DailyProgressNotifier extends StateNotifier<DailyProgressState> {
  final ProgressService _service;

  DailyProgressNotifier(this._service) : super(const DailyProgressState()) {
    fetchTodayProgress();
  }

  static String get todayString {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> fetchTodayProgress() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entry = await _service.getProgress(todayString);
      state = state.copyWith(
        isLoading: false,
        progress: entry ??
            DailyProgress(
              id: '',
              date: todayString,
              completedHabitIds: [],
              learningHours: 0.0,
              mood: 'Good',
              notes: '',
            ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateMood(String mood) async {
    final current = state.progress;
    if (current == null) return;
    try {
      final updated = await _service.upsertProgress(
        date: todayString,
        completedHabitIds: current.completedHabitIds,
        learningHours: current.learningHours,
        mood: mood,
        notes: current.notes,
      );
      state = state.copyWith(progress: updated);
    } catch (_) {}
  }

  Future<void> logJournal({
    required double learningHours,
    required String notes,
    required String mood,
  }) async {
    final current = state.progress;
    final habitIds = current?.completedHabitIds ?? [];
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _service.upsertProgress(
        date: todayString,
        completedHabitIds: habitIds,
        learningHours: learningHours,
        mood: mood,
        notes: notes,
      );
      state = state.copyWith(isLoading: false, progress: updated);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dailyProgressNotifierProvider =
    StateNotifierProvider<DailyProgressNotifier, DailyProgressState>((ref) {
  final service = ref.watch(progressServiceProvider);
  return DailyProgressNotifier(service);
});
