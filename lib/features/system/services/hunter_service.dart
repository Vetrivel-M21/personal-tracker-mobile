import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/hunter_models.dart';

class HunterService {
  final ApiClient apiClient;

  HunterService({required this.apiClient});

  Future<Quest> getTodayQuest() async {
    try {
      final response = await apiClient.dio.get('/api/quests/today');
      return Quest.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load daily quest';
      throw Exception(message);
    }
  }

  Future<Quest> startQuest(String questId) async {
    try {
      final response = await apiClient.dio.post('/api/quests/$questId/start');
      return Quest.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to start quest';
      throw Exception(message);
    }
  }

  Future<Quest> updateQuestProgress(String questId, {String? itemId, int? count, int? delta}) async {
    try {
      final response = await apiClient.dio.put(
        '/api/quests/$questId/progress',
        data: {
          if (itemId != null) 'itemId': itemId,
          if (count != null) 'count': count,
          if (delta != null) 'delta': delta,
        },
      );
      return Quest.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to update quest progress';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> completeQuest(String questId) async {
    try {
      final response = await apiClient.dio.post('/api/quests/$questId/complete');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to complete quest';
      throw Exception(message);
    }
  }

  Future<HunterProfile> getHunterProfile() async {
    try {
      final response = await apiClient.dio.get('/api/me/system');
      return HunterProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load hunter system profile';
      throw Exception(message);
    }
  }
}
