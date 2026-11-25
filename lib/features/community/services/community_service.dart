import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/community_user.dart';

class CommunityService {
  final ApiClient apiClient;

  CommunityService({required this.apiClient});

  Future<List<CommunityUser>> listUsers({String? query, int limit = 50, int offset = 0}) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (query != null && query.trim().isNotEmpty) {
        queryParams['q'] = query.trim();
      }

      final response = await apiClient.dio.get('/api/users', queryParameters: queryParams);
      final data = response.data;
      final List<dynamic> entries;
      if (data is Map<String, dynamic> && data.containsKey('entries')) {
        entries = data['entries'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        entries = data;
      } else {
        entries = [];
      }

      return entries
          .map((e) => CommunityUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load community';
      throw Exception(message);
    }
  }

  Future<int> giveKudos(String userId) async {
    try {
      final response = await apiClient.dio.post('/api/users/$userId/kudos');
      final data = response.data as Map<String, dynamic>;
      return data['kudos_count'] as int? ?? 0;
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to send kudos';
      throw Exception(message);
    }
  }

  Future<UserHabitsSummary> getHabitsSummary(String userId) async {
    try {
      final response = await apiClient.dio.get('/api/users/$userId/habits-summary');
      return UserHabitsSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load user habits';
      throw Exception(message);
    }
  }
}
