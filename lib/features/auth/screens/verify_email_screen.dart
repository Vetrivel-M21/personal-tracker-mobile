import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String username;
  final String? emailHint;

  const VerifyEmailScreen({
    super.key,
    required this.username,
    this.emailHint,
  });

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _cooldownTimer;
  int _cooldownSeconds = 60;
  bool _isResending = false;
  String? _statusBanner;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  void _startCooldownTimer([int seconds = 60]) {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldownSeconds = 0);
      } else {
        if (mounted) setState(() => _cooldownSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final code = _codeController.text.trim();
    final success = await ref.read(authNotifierProvider.notifier).verifyEmail(
          username: widget.username,
          code: code,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified! Welcome to Aura.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final err = ref.read(authNotifierProvider).errorMessage ?? 'Verification failed';
        setState(() {
          _statusBanner = err;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleResend() async {
    if (_cooldownSeconds > 0 || _isResending) return;
    setState(() {
      _isResending = true;
      _statusBanner = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).resendVerification(widget.username);
      if (mounted) {
        _startCooldownTimer(60);
        setState(() {
          _statusBanner = 'A fresh 6-digit code has been sent to your email.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New code sent! Check your email.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString();
        setState(() {
          _statusBanner = msg;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text('VERIFY EMAIL', style: AppTypography.headingMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'ENTER 6-DIGIT CODE',
                  style: AppTypography.headingLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.emailHint != null
                      ? 'We sent a verification code to ${widget.emailHint}.\nEnter it below to activate your player profile.'
                      : 'We sent a verification code to your email.\nEnter it below to activate your player profile.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                if (_statusBanner != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: _statusBanner!.contains('fresh') || _statusBanner!.contains('sent')
                          ? AppColors.primaryMuted
                          : AppColors.danger.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _statusBanner!.contains('fresh') || _statusBanner!.contains('sent')
                            ? AppColors.primary
                            : AppColors.danger,
                      ),
                    ),
                    child: Text(
                      _statusBanner!,
                      style: AppTypography.bodySmall.copyWith(
                        color: _statusBanner!.contains('fresh') || _statusBanner!.contains('sent')
                            ? AppColors.primary
                            : AppColors.danger,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Code Input Field
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: AppTypography.displayMedium.copyWith(
                    letterSpacing: 12.0,
                    color: AppColors.primary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    labelText: 'Verification Code',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length != 6) {
                      return 'Please enter the 6-digit code';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleVerify(),
                ),
                const SizedBox(height: AppSpacing.xl),

                PrimaryButton(
                  text: 'ACTIVATE PLAYER',
                  isLoading: isLoading,
                  onPressed: _handleVerify,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Resend Section
                Center(
                  child: _cooldownSeconds > 0
                      ? Text(
                          'Resend code in ${_cooldownSeconds}s',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        )
                      : TextButton.icon(
                          onPressed: _isResending ? null : _handleResend,
                          icon: _isResending
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                )
                              : const Icon(Icons.refresh, size: 18, color: AppColors.primary),
                          label: Text(
                            'Resend Code',
                            style: AppTypography.button.copyWith(color: AppColors.primary),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
