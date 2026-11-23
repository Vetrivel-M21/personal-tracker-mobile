import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authNotifierProvider.notifier).login(
          _usernameController.text.trim(),
          _passwordController.text,
        );

    if (!success && mounted) {
      final err = ref.read(authNotifierProvider).errorMessage ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Game-style emblem / title
                  Container(
                    width: 72,
                    height: 72,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.primaryGlow,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'AURA SYSTEM',
                    style: AppTypography.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'MAX-REP CHALLENGE TN',
                    style: AppTypography.headingSmall.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter username';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter password';
                      return null;
                    },
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Sign In Button
                  PrimaryButton(
                    text: 'ENTER THE ARENA',
                    isLoading: isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Google Sign-In
                  SecondaryButton(
                    text: 'SIGN IN WITH GOOGLE',
                    icon: Icons.g_mobiledata,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Google Sign-In ready for native credentials.'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Link to Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?", style: AppTypography.bodySmall),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          'Register',
                          style: AppTypography.button.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
