import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService storage;

  AuthRepository({required this.apiClient, required this.storage});

  Future<UserModel> login({required String username, required String password}) async {
    final response = await apiClient.dio.post(
      '/api/auth/login',
      data: {'username': username, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;

    if (accessToken != null && refreshToken != null) {
      await storage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    }

    final user = UserModel.fromJson(data);
    await storage.saveUserId(user.id);
    return user;
  }

  Future<Map<String, dynamic>> signup({
    required String username,
    required String password,
    required String displayName,
    required String email,
    required String dateOfBirth,
    String? referralCode,
  }) async {
    final payload = {
      'username': username,
      'password': password,
      'display_name': displayName,
      'email': email,
      'date_of_birth': dateOfBirth,
    };
    if (referralCode != null && referralCode.isNotEmpty) {
      payload['referral_code'] = referralCode;
    }

    final response = await apiClient.dio.post(
      '/api/auth/signup',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<UserModel> loginWithGoogle(String credential) async {
    final response = await apiClient.dio.post(
      '/api/auth/google',
      data: {'credential': credential},
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;

    if (accessToken != null && refreshToken != null) {
      await storage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    }

    final user = UserModel.fromJson(data);
    await storage.saveUserId(user.id);
    return user;
  }

  Future<UserModel> getMe() async {
    final response = await apiClient.dio.get('/api/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await storage.getRefreshToken();
      await apiClient.dio.post(
        '/api/auth/logout',
        data: refreshToken != null ? {'refresh_token': refreshToken} : null,
      );
    } catch (_) {
      // Ignore network errors on logout to allow clean local logout
    } finally {
      await storage.clearAll();
    }
  }

  Future<bool> hasSavedSession() async {
    final token = await storage.getAccessToken();
    final refresh = await storage.getRefreshToken();
    return token != null && refresh != null;
  }
}
