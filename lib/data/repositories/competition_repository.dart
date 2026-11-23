import '../../core/network/api_client.dart';
import '../models/competition_models.dart';
import '../models/user_model.dart';

class CompetitionRepository {
  final ApiClient apiClient;

  CompetitionRepository({required this.apiClient});

  /// Fetches paginated leaderboard filtered by exercise, scope, and period.
  Future<LeaderboardResponseModel> getLeaderboard({
    required String exercise,
    required String scope,
    required String period,
    int limit = 20,
    int offset = 0,
    String? area,
    String? district,
    String? state,
  }) async {
    final queryParams = <String, dynamic>{
      'exercise': exercise,
      'scope': scope,
      'period': period,
      'limit': limit,
      'offset': offset,
    };
    if (area != null && area.isNotEmpty) queryParams['area'] = area;
    if (district != null && district.isNotEmpty) queryParams['district'] = district;
    if (state != null && state.isNotEmpty) queryParams['state'] = state;

    final response = await apiClient.dio.get(
      '/api/competition/leaderboard',
      queryParameters: queryParams,
    );

    return LeaderboardResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Submits a new max-rep push-up or pull-up attempt.
  Future<AttemptModel> submitAttempt({
    required String exercise,
    required int reps,
    required String proofType,
    String? videoUrl,
  }) async {
    final payload = <String, dynamic>{
      'exercise': exercise,
      'reps': reps,
      'proof_type': proofType,
      'video_url': videoUrl,
    };

    final response = await apiClient.dio.post(
      '/api/competition/attempts',
      data: payload,
    );

    return AttemptModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Lists all attempts submitted by the current authenticated user.
  Future<List<AttemptModel>> getMyAttempts() async {
    final response = await apiClient.dio.get('/api/competition/attempts/my');
    final list = response.data as List<dynamic>? ?? [];
    return list.map((item) => AttemptModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Updates user location (State, District, Area) through profile update.
  Future<UserModel> updateProfileLocation({
    required String displayName,
    required String state,
    required String district,
    required String area,
  }) async {
    final payload = {
      'display_name': displayName,
      'state': state,
      'district': district,
      'area': area,
    };

    final response = await apiClient.dio.put(
      '/api/me',
      data: payload,
    );

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
