import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/calisthenics_skill.dart';

class CalisthenicsService {
  final ApiClient apiClient;

  CalisthenicsService({required this.apiClient});

  Future<Map<String, List<CalisthenicsSkill>>> getSkills() async {
    try {
      final response = await apiClient.dio.get('/api/calisthenics/skills');
      final data = response.data as Map<String, dynamic>;
      final branchesMap = data['branches'] as Map<String, dynamic>? ?? {};

      final Map<String, List<CalisthenicsSkill>> result = {};
      branchesMap.forEach((branchName, list) {
        if (list is List) {
          result[branchName] = list
              .map((item) => CalisthenicsSkill.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      });
      return result;
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load skills';
      throw Exception(message);
    }
  }

  Future<Map<String, List<CalisthenicsSkill>>> unlockSkill(String skillId) async {
    try {
      final response = await apiClient.dio.post('/api/calisthenics/skills/$skillId/unlock');
      final data = response.data as Map<String, dynamic>;
      final branchesMap = data['branches'] as Map<String, dynamic>? ?? {};

      final Map<String, List<CalisthenicsSkill>> result = {};
      branchesMap.forEach((branchName, list) {
        if (list is List) {
          result[branchName] = list
              .map((item) => CalisthenicsSkill.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      });
      return result;
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to unlock skill';
      throw Exception(message);
    }
  }
}

