import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/daily_progress.dart';

class ProgressService {
  final ApiClient apiClient;

  ProgressService({required this.apiClient});

  Future<DailyProgress?> getProgress(String date) async {
    try {
      final response = await apiClient.dio.get('/api/progress/$date');
      return DailyProgress.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      final message = e.response?.data?['error'] ?? 'Failed to load progress';
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
      final message = e.response?.data?['error'] ?? 'Failed to save progress';
      throw Exception(message);
    }
  }
}
