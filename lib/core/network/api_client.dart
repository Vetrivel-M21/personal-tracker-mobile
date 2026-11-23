import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService storage;
  void Function()? onSessionExpired;

  ApiClient({
    required this.storage,
    this.onSessionExpired,
    String? customBaseUrl,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: customBaseUrl ?? AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client': AppConfig.clientHeaderValue,
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storage: storage,
        onSessionExpired: () => onSessionExpired?.call(),
      ),
    );
  }
}
