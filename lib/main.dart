import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/navigation/screens/main_nav_shell.dart';
import 'features/onboarding/screens/location_setup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AuraApp(),
    ),
  );
}

class AuraApp extends ConsumerWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: 'Aura Fitness Challenge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.loading:
      case AuthStatus.initial:
        return const Scaffold(
          backgroundColor: AppColors.bgMain,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      case AuthStatus.authenticated:
        final user = authState.user;
        if (user != null && (user.district == null || user.district!.isEmpty)) {
          return const LocationSetupScreen();
        }
        return const MainNavShell();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }
}
