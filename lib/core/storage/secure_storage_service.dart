import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  static const String _keyAccessToken = 'aura_access_token';
  static const String _keyRefreshToken = 'aura_refresh_token';
  static const String _keyUserId = 'aura_user_id';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _keyUserId);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
