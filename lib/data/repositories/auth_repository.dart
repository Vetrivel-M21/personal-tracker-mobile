import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  ApiException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;
}

ApiException parseDioError(dynamic error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (error.response?.data is Map) {
      final map = error.response!.data as Map;
      final msg = map['error']?.toString() ?? error.message ?? 'Unknown error';
      final code = map['code']?.toString();
      return ApiException(msg, code: code, statusCode: status);
    }
    return ApiException(error.message ?? 'Network error', statusCode: status);
  }
  if (error is ApiException) return error;
  return ApiException(error.toString());
}

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService storage;

  AuthRepository({required this.apiClient, required this.storage});

  Future<UserModel> login({required String username, required String password}) async {
    try {
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
    } catch (e) {
      throw parseDioError(e);
    }
  }

  Future<Map<String, dynamic>> signup({
    required String username,
    required String password,
    required String displayName,
    required String email,
    required String dateOfBirth,
    String? referralCode,
  }) async {
    try {
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
    } catch (e) {
      throw parseDioError(e);
    }
  }

  Future<UserModel> verifyEmail({required String username, required String code}) async {
    try {
      final response = await apiClient.dio.post(
        '/api/auth/verify-email',
        data: {'username': username, 'code': code},
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
    } catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> resendVerification(String username) async {
    try {
      await apiClient.dio.post(
        '/api/auth/resend-verification',
        data: {'username': username},
      );
    } catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> forgotPassword(String username) async {
    try {
      await apiClient.dio.post(
        '/api/auth/forgot-password',
        data: {'username': username},
      );
    } catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> resetPassword({
    required String username,
    required String code,
    required String newPassword,
  }) async {
    try {
      await apiClient.dio.post(
        '/api/auth/reset-password',
        data: {
          'username': username,
          'code': code,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      throw parseDioError(e);
    }
  }

  Future<UserModel> loginWithGoogle(String credential) async {
    try {
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
    } catch (e) {
      throw parseDioError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await apiClient.dio.get('/api/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw parseDioError(e);
    }
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
