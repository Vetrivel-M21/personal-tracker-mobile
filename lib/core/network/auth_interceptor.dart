import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

/// QueuedInterceptor handles automatic token injection and silent 401 refresh
class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final SecureStorageService storage;
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required this.dio,
    required this.storage,
    this.onSessionExpired,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['X-Client'] = AppConfig.clientHeaderValue;

    final token = await storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isAuthEndpoint = err.requestOptions.path.contains('/api/auth/');

    // Only attempt refresh on 401 for non-auth endpoints
    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt silent refresh using a fresh Dio instance to avoid interceptor loop
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: dio.options.baseUrl,
              headers: {
                'X-Client': AppConfig.clientHeaderValue,
                'Content-Type': 'application/json',
              },
            ),
          );

          final response = await refreshDio.post(
            '/api/auth/refresh',
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200 && response.data is Map) {
            final newAccess = response.data['access_token'] as String?;
            final newRefresh = response.data['refresh_token'] as String?;

            if (newAccess != null && newRefresh != null) {
              await storage.saveTokens(
                accessToken: newAccess,
                refreshToken: newRefresh,
              );

              // Retry the queued original request with the refreshed token
              final retryOptions = err.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer $newAccess';
              final retryResponse = await dio.fetch(retryOptions);
              return handler.resolve(retryResponse);
            }
          }
        } catch (_) {
          // Refresh failed - session has truly expired
        }
      }

      await storage.clearAll();
      onSessionExpired?.call();
    }

    return handler.next(err);
  }
}
