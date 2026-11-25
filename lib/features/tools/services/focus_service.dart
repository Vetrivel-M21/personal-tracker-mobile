import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class FocusSessionSummary {
  final String id;
  final String sessionType;
  final int durationMinutes;
  final String completedAt;

  const FocusSessionSummary({
    required this.id,
    required this.sessionType,
    required this.durationMinutes,
    required this.completedAt,
  });

  factory FocusSessionSummary.fromJson(Map<String, dynamic> json) {
    return FocusSessionSummary(
      id: json['id'] as String? ?? '',
      sessionType: json['session_type'] as String? ?? 'Focus',
      durationMinutes: json['duration_minutes'] as int? ?? 25,
      completedAt: json['completed_at'] as String? ?? '',
    );
  }
}

class FocusService {
  final ApiClient apiClient;

  FocusService({required this.apiClient});

  Future<FocusSessionSummary> logFocusSession({
    required String sessionType,
    required int durationMinutes,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/focus-sessions',
        data: {
          'session_type': sessionType,
          'duration_minutes': durationMinutes,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final sessionData = data['session'] as Map<String, dynamic>? ?? data;
      return FocusSessionSummary.fromJson(sessionData);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to log focus session';
      throw Exception(message);
    }
  }

  Future<List<FocusSessionSummary>> listFocusSessions() async {
    try {
      final response = await apiClient.dio.get('/api/focus-sessions');
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => FocusSessionSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load focus history';
      throw Exception(message);
    }
  }
}
