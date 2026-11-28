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
    int? page,
    int? pageSize,
    int limit = 20,
    int offset = 0,
    String? countryCode,
    String? region,
    String? city,
    String? area,
    String? district,
    String? state,
  }) async {
    final queryParams = <String, dynamic>{
      'exercise': exercise,
      'scope': scope,
      'period': period,
    };
    if (page != null && pageSize != null) {
      queryParams['page'] = page;
      queryParams['page_size'] = pageSize;
    } else {
      queryParams['limit'] = limit;
      queryParams['offset'] = offset;
    }
    if (countryCode != null && countryCode.isNotEmpty) {
      queryParams['country_code'] = countryCode;
    }
    if (region != null && region.isNotEmpty) queryParams['region'] = region;
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (area != null && area.isNotEmpty) queryParams['area'] = area;
    if (district != null && district.isNotEmpty) queryParams['district'] = district;
    if (state != null && state.isNotEmpty) queryParams['state'] = state;

    final response = await apiClient.dio.get(
      '/api/competition/leaderboard',
      queryParameters: queryParams,
    );

    return LeaderboardResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches prefix location suggestions for region or city.
  Future<List<String>> suggestLocations({
    required String type,
    String? countryCode,
    String query = '',
  }) async {
    final queryParams = <String, dynamic>{
      'type': type,
      'q': query,
    };
    if (countryCode != null && countryCode.isNotEmpty) {
      queryParams['country_code'] = countryCode;
    }

    final response = await apiClient.dio.get(
      '/api/locations/suggest',
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>? ?? {};
    final list = data['suggestions'] as List<dynamic>? ?? [];
    return list.map((e) => e.toString()).toList();
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
    final response = await apiClient.dio.get('/api/competition/attempts/mine');
    final list = response.data as List<dynamic>? ?? [];
    return list.map((item) => AttemptModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Fetches referral code, friend invites count, and active competitors count.
  Future<ReferralStatsModel> getReferralStats() async {
    final response = await apiClient.dio.get('/api/referrals/stats');
    return ReferralStatsModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates user global location through profile update.
  Future<UserModel> updateProfileLocation({
    required String displayName,
    required String countryCode,
    required String region,
    required String city,
    bool locationVisible = true,
  }) async {
    final payload = {
      'display_name': displayName,
      'country_code': countryCode,
      'region': region,
      'city': city,
      'location_visible': locationVisible,
    };

    final response = await apiClient.dio.patch(
      '/api/me',
      data: payload,
    );

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}

