import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/daily_progress.dart';
import '../models/habit.dart';
import '../models/streak_stats.dart';

class HabitsService {
  final ApiClient apiClient;

  HabitsService({required this.apiClient});

  Future<List<Habit>> listHabits({bool archived = false}) async {
    try {
      final response = await apiClient.dio.get(
        '/api/habits',
        queryParameters: archived ? {'archived': 'true'} : null,
      );
      final list = response.data as List<dynamic>;
      return list.map((item) => Habit.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load habits';
      throw Exception(message);
    }
  }

  Future<Habit> createHabit({
    required String name,
    String color = '#22D3EE',
    String icon = 'fa-solid fa-star',
    int schedule = 127,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/habits',
        data: {
          'name': name,
          'color': color,
          'icon': icon,
          'schedule': schedule,
        },
      );
      return Habit.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to create habit';
      throw Exception(message);
    }
  }

  Future<void> archiveHabit(String habitId) async {
    try {
      await apiClient.dio.delete('/api/habits/$habitId');
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to archive habit';
      throw Exception(message);
    }
  }

  Future<DailyProgress?> getProgress(String date) async {
    try {
      final response = await apiClient.dio.get('/api/progress/$date');
      return DailyProgress.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      final message = e.response?.data?['error'] ?? 'Failed to load daily progress';
      throw Exception(message);
    }
  }

  Future<DailyProgress> upsertProgress({
    required String date,
    required List<String> completedHabitIds,
    required double learningHours,
    required String mood,
    required String notes,
  }) async {
    try {
      final response = await apiClient.dio.put(
        '/api/progress/$date',
        data: {
          'completed_habit_ids': completedHabitIds,
          'learning_hours': learningHours,
          'mood': mood,
          'notes': notes,
        },
      );
      return DailyProgress.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to save daily progress';
      throw Exception(message);
    }
  }

  Future<StreakStats> getStats() async {
    try {
      final response = await apiClient.dio.get('/api/me/stats');
      final data = response.data as Map<String, dynamic>;
      final streak = data['streak'] as Map<String, dynamic>? ?? {};
      return StreakStats.fromJson(streak);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load stats';
      throw Exception(message);
    }
  }
}

