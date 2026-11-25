import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/daily_progress.dart';
import '../models/habit.dart';
import '../models/streak_stats.dart';
import '../services/habits_service.dart';

final habitsServiceProvider = Provider<HabitsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HabitsService(apiClient: apiClient);
});

class HabitsState {
  final bool isLoading;
  final List<Habit> habits;
  final DailyProgress todayProgress;
  final StreakStats streakStats;
  final String? errorMessage;
  final bool isSavingProgress;

  const HabitsState({
    required this.isLoading,
    required this.habits,
    required this.todayProgress,
    required this.streakStats,
    this.errorMessage,
    required this.isSavingProgress,
  });

  factory HabitsState.initial() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return HabitsState(
      isLoading: true,
      habits: const [],
      todayProgress: DailyProgress.empty(dateStr),
      streakStats: StreakStats.initial(),
      errorMessage: null,
      isSavingProgress: false,
    );
  }

  HabitsState copyWith({
    bool? isLoading,
    List<Habit>? habits,
    DailyProgress? todayProgress,
    StreakStats? streakStats,
    String? errorMessage,
    bool? isSavingProgress,
  }) {
    return HabitsState(
      isLoading: isLoading ?? this.isLoading,
      habits: habits ?? this.habits,
      todayProgress: todayProgress ?? this.todayProgress,
      streakStats: streakStats ?? this.streakStats,
      errorMessage: errorMessage,
      isSavingProgress: isSavingProgress ?? this.isSavingProgress,
    );
  }
}

class HabitsNotifier extends StateNotifier<HabitsState> {
  final HabitsService _service;

  HabitsNotifier(this._service) : super(HabitsState.initial()) {
    loadTodayData();
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadTodayData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final todayStr = _formatDate(DateTime.now());

    try {
      final habitsFuture = _service.listHabits();
      final progressFuture = _service.getProgress(todayStr);
      final statsFuture = _service.getStats();

      final results = await Future.wait([habitsFuture, progressFuture, statsFuture]);
      final habits = results[0] as List<Habit>;
      final progress = results[1] as DailyProgress? ?? DailyProgress.empty(todayStr);
      final stats = results[2] as StreakStats;

      state = state.copyWith(
        isLoading: false,
        habits: habits,
        todayProgress: progress,
        streakStats: stats,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleHabit(String habitId) async {
    final currentIds = List<String>.from(state.todayProgress.completedHabitIds);
    if (currentIds.contains(habitId)) {
      currentIds.remove(habitId);
    } else {
      currentIds.add(habitId);
    }

    final updated = state.todayProgress.copyWith(completedHabitIds: currentIds);
    state = state.copyWith(todayProgress: updated);
    await _saveProgress(updated);
  }

  Future<bool> saveDailyReflection({
    required double learningHours,
    required String mood,
    required String notes,
  }) async {
    final updated = state.todayProgress.copyWith(
      learningHours: learningHours,
      mood: mood,
      notes: notes,
    );
    state = state.copyWith(todayProgress: updated);
    await _saveProgress(updated);
    return state.errorMessage == null;
  }

  Future<void> updateLearningHours(double hours) async {
    final updated = state.todayProgress.copyWith(learningHours: hours);
    state = state.copyWith(todayProgress: updated);
    await _saveProgress(updated);
  }

  Future<void> updateMood(String mood) async {
    final updated = state.todayProgress.copyWith(mood: mood);
    state = state.copyWith(todayProgress: updated);
    await _saveProgress(updated);
  }

  Future<void> updateNotes(String notes) async {
    final updated = state.todayProgress.copyWith(notes: notes);
    state = state.copyWith(todayProgress: updated);
    await _saveProgress(updated);
  }

  Future<void> _saveProgress(DailyProgress progress) async {
    state = state.copyWith(isSavingProgress: true);
    try {
      final saved = await _service.upsertProgress(
        date: progress.date,
        completedHabitIds: progress.completedHabitIds,
        learningHours: progress.learningHours,
        mood: progress.mood,
        notes: progress.notes,
      );
      final stats = await _service.getStats();
      state = state.copyWith(
        isSavingProgress: false,
        todayProgress: saved,
        streakStats: stats,
      );
    } catch (e) {
      state = state.copyWith(isSavingProgress: false, errorMessage: e.toString());
    }
  }

  Future<bool> createHabit(String name, {String color = '#22D3EE', String icon = 'check'}) async {
    try {
      final newHabit = await _service.createHabit(name: name, color: color, icon: icon);
      state = state.copyWith(habits: [...state.habits, newHabit]);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> archiveHabit(String habitId) async {
    try {
      await _service.archiveHabit(habitId);
      final updated = state.habits.where((h) => h.id != habitId).toList();
      state = state.copyWith(habits: updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final habitsNotifierProvider =
    StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  final service = ref.watch(habitsServiceProvider);
  return HabitsNotifier(service);
});

