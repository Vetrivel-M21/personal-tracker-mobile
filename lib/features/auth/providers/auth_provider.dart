import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient: apiClient, storage: storage);
});

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);
  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.authenticated(UserModel user) : this(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.error(String message) : this(status: AuthStatus.error, errorMessage: message);

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final ApiClient _apiClient;

  AuthNotifier(this._repository, this._apiClient) : super(const AuthState.initial()) {
    _apiClient.onSessionExpired = handleSessionExpired;
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    try {
      final hasSession = await _repository.hasSavedSession();
      if (!hasSession) {
        state = const AuthState.unauthenticated();
        return;
      }

      final user = await _repository.getMe();
      state = AuthState.authenticated(user);
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login(String username, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(username: username, password: password);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> signup({
    required String username,
    required String password,
    required String displayName,
    required String email,
    required String dateOfBirth,
    String? referralCode,
  }) async {
    state = const AuthState.loading();
    try {
      await _repository.signup(
        username: username,
        password: password,
        displayName: displayName,
        email: email,
        dateOfBirth: dateOfBirth,
        referralCode: referralCode,
      );
      state = const AuthState.unauthenticated();
      return true;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> loginWithGoogle(String credential) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.loginWithGoogle(credential);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    await _repository.logout();
    state = const AuthState.unauthenticated();
  }

  void handleSessionExpired() {
    state = const AuthState.unauthenticated();
  }

  void updateUser(UserModel updatedUser) {
    if (state.isAuthenticated) {
      state = AuthState.authenticated(updatedUser);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final apiClient = ref.watch(apiClientProvider);
  return AuthNotifier(repository, apiClient);
});
