import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/workout_session.dart';
import '../models/workout_split.dart';
import '../models/workout_template.dart';

class WorkoutsService {
  final ApiClient apiClient;

  WorkoutsService({required this.apiClient});

  Future<List<WorkoutTemplateSummary>> listTemplates() async {
    try {
      final response = await apiClient.dio.get('/api/workouts/templates');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => WorkoutTemplateSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load templates';
      throw Exception(message);
    }
  }

  Future<List<WorkoutSplitSummary>> listSplits() async {
    try {
      final response = await apiClient.dio.get('/api/workouts/splits');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => WorkoutSplitSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load splits';
      throw Exception(message);
    }
  }

  Future<WorkoutSplitDetail?> getActiveSplit() async {
    try {
      final response = await apiClient.dio.get('/api/workouts/splits/active');
      return WorkoutSplitDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      final message = e.response?.data?['error'] ?? 'Failed to load active split';
      throw Exception(message);
    }
  }

  Future<WorkoutSplitDetail> createSplitFromTemplate(String name, String templateId) async {
    try {
      final response = await apiClient.dio.post(
        '/api/workouts/splits',
        data: {'name': name, 'templateId': templateId},
      );
      return WorkoutSplitDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to create split';
      throw Exception(message);
    }
  }

  Future<void> activateSplit(String splitId) async {
    try {
      await apiClient.dio.post('/api/workouts/splits/$splitId/activate');
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to activate split';
      throw Exception(message);
    }
  }

  Future<WorkoutSession> logSession({
    String? splitId,
    String? splitDayId,
    required String label,
    required String sessionDate,
    String notes = '',
    required List<WorkoutSessionSet> sets,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/workouts/sessions',
        data: {
          if (splitId != null) 'splitId': splitId,
          if (splitDayId != null) 'splitDayId': splitDayId,
          'label': label,
          'sessionDate': sessionDate,
          'notes': notes,
          'sets': sets.map((s) => s.toRequestJson()).toList(),
        },
      );
      return WorkoutSession.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to log session';
      throw Exception(message);
    }
  }

  Future<List<WorkoutSession>> listSessions() async {
    try {
      final response = await apiClient.dio.get('/api/workouts/sessions');
      final list = response.data as List<dynamic>;
      return list
          .map((item) => WorkoutSession.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load workout sessions';
      throw Exception(message);
    }
  }
}

