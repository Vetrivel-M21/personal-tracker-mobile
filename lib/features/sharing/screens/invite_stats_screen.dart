import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/services/analytics_service.dart';
import '../../../widgets/app_buttons.dart';
import '../../../widgets/stat_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../community/screens/community_screen.dart';
import '../providers/referral_provider.dart';
import '../services/invite_link_service.dart';
import '../services/share_card_service.dart';
import '../widgets/share_card.dart';

class InviteStatsScreen extends ConsumerStatefulWidget {
  const InviteStatsScreen({super.key});

  @override
  ConsumerState<InviteStatsScreen> createState() => _InviteStatsScreenState();
}

class _InviteStatsScreenState extends ConsumerState<InviteStatsScreen> {
  final GlobalKey _shareCardKey = GlobalKey();
  String _selectedExercise = 'pushup';
  bool _isSharing = false;

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Referral code "$code" copied to clipboard!',
          style: AppTypography.rawOnPrimaryBold,
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareInviteLink(
    String code,
    String displayName,
    String? area,
  ) async {
    final analytics = ref.read(analyticsServiceProvider);
    final message = InviteLinkService.buildInviteMessage(
      referralCode: code,
      displayName: displayName,
      area: area,
    );
    await ShareCardService.shareText(
      text: message,
      analytics: analytics,
      platform: 'whatsapp_or_sheet',
    );
  }

  Future<void> _shareCardImage({
    required String displayName,
    required String referralCode,
    required int reps,
    String? area,
    String? district,
    String? state,
  }) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final analytics = ref.read(analyticsServiceProvider);
      final message = InviteLinkService.buildInviteMessage(
        referralCode: referralCode,
        displayName: displayName,
        area: area,
      );

      await ShareCardService.captureAndShare(
        boundaryKey: _shareCardKey,
        messageText: message,
        analytics: analytics,
        exercise: _selectedExercise,
        reps: reps,
        rank: reps >= 50 ? 'S' : (reps >= 35 ? 'A' : 'B'),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _showChallengeDialog(
    String referralCode,
    String displayName,
    String? area,
  ) {
    final repsController = TextEditingController(text: '30');
    String challengeExercise = _selectedExercise;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xl,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(AppIcons.challenge, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'CHALLENGE A FRIEND',
                        style: AppTypography.headingMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Set a target rep score and challenge your gym partner to beat it.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: challengeExercise == 'pushup'
                                ? AppColors.primary
                                : AppColors.surface2,
                            foregroundColor: challengeExercise == 'pushup'
                                ? AppColors.onPrimary
                                : AppColors.textPrimary,
                            elevation: 0,
                          ),
                          onPressed: () =>
                              setModalState(() => challengeExercise = 'pushup'),
                          child: const Text('PUSH-UPS'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: challengeExercise == 'pullup'
                                ? AppColors.primary
                                : AppColors.surface2,
                            foregroundColor: challengeExercise == 'pullup'
                                ? AppColors.onPrimary
                                : AppColors.textPrimary,
                            elevation: 0,
                          ),
                          onPressed: () =>
                              setModalState(() => challengeExercise = 'pullup'),
                          child: const Text('PULL-UPS'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.rawTextPrimary,
                    decoration: InputDecoration(
                      labelText: 'Target Reps to Beat',
                      labelStyle: AppTypography.rawTextSecondary,
                      filled: true,
                      fillColor: AppColors.surface2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  PrimaryButton(
                    text: 'SEND 1-ON-1 CHALLENGE',
                    icon: AppIcons.share,
                    onPressed: () {
                      final targetReps = int.tryParse(repsController.text) ?? 25;
                      final analytics = ref.read(analyticsServiceProvider);
                      final message = InviteLinkService.buildChallengeMessage(
                        referralCode: referralCode,
                        challengerName: displayName,
                        exercise: challengeExercise,
                        reps: targetReps,
                        area: area,
                      );
                      Navigator.pop(ctx);
                      ShareCardService.shareText(
                        text: message,
                        analytics: analytics,
                        platform: 'challenge_friend',
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(referralStatsProvider);
    final user = ref.watch(authNotifierProvider).user;
    final displayName = user?.displayName ?? 'Athlete';
    final userArea = user?.area;
    final userDistrict = user?.district;
    final userState = user?.state ?? 'Tamil Nadu';

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: const Text('TERRITORY SQUAD & INVITES'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.squad, color: AppColors.textSecondary),
            tooltip: 'Hunters Directory',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CommunityScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(AppIcons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: () => ref.read(referralStatsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.danger,
                  size: 44,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Failed to load invite stats',
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  text: 'RETRY',
                  onPressed: () =>
                      ref.read(referralStatsProvider.notifier).refresh(),
                ),
              ],
            ),
          ),
        ),
        data: (stats) {
          final code = stats.referralCode.isNotEmpty ? stats.referralCode : 'AURA88';

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface2,
            onRefresh: () => ref.read(referralStatsProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                104,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Referral Code Hero Card (surface1 + 1px hairline, no glow)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface1,
                      borderRadius: AppSpacing.roundedLg,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'YOUR EXCLUSIVE INVITE CODE',
                          style: AppTypography.badge.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              code,
                              style: AppTypography.statNumber.copyWith(
                                fontSize: 28,
                                letterSpacing: 3.5,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              icon: const Icon(
                                AppIcons.copy,
                                color: AppColors.primary,
                              ),
                              tooltip: 'Copy Code',
                              onPressed: () => _copyToClipboard(code),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                text: 'SHARE LINK',
                                icon: AppIcons.share,
                                onPressed: () =>
                                    _shareInviteLink(code, displayName, userArea),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: SecondaryButton(
                                text: 'CHALLENGE',
                                icon: AppIcons.challenge,
                                onPressed: () =>
                                    _showChallengeDialog(code, displayName, userArea),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 2. Growth Metric Cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: AppIcons.squad,
                          label: 'FRIENDS JOINED',
                          value: '${stats.inviteCount}',
                          sublabel: 'Registered Athletes',
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(
                          icon: AppIcons.check,
                          label: 'VERIFIED',
                          value: '${stats.verifiedInvitesCount}',
                          sublabel: 'Confirmed Email',
                          iconColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatCard(
                    icon: AppIcons.award,
                    label: 'ACTIVE DISTRICT COMPETITORS',
                    value: '${stats.activeCompetitorsCount}',
                    sublabel: 'Submitted verified attempts',
                    iconColor: AppColors.gold,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 3. Share Card Preview & Generation Section
                  Text('SOCIAL SHARE CARD', style: AppTypography.labelSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Push-ups'),
                        selected: _selectedExercise == 'pushup',
                        selectedColor: AppColors.primaryMuted,
                        backgroundColor: AppColors.surface2,
                        side: BorderSide(
                          color: _selectedExercise == 'pushup'
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedExercise = 'pushup');
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ChoiceChip(
                        label: const Text('Pull-ups'),
                        selected: _selectedExercise == 'pullup',
                        selectedColor: AppColors.primaryMuted,
                        backgroundColor: AppColors.surface2,
                        side: BorderSide(
                          color: _selectedExercise == 'pullup'
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedExercise = 'pullup');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Preview the high-contrast card that will be generated for your WhatsApp status or Instagram story.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Center(
                    child: RepaintBoundary(
                      key: _shareCardKey,
                      child: ShareCard(
                        displayName: displayName,
                        exercise: _selectedExercise,
                        reps: _selectedExercise == 'pushup' ? 42 : 18,
                        rank: _selectedExercise == 'pushup' ? 'A' : 'S',
                        area: userArea,
                        district: userDistrict,
                        state: userState,
                        referralCode: code,
                        isAiVerified: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  PrimaryButton(
                    text: _isSharing
                        ? 'GENERATING IMAGE...'
                        : 'SHARE CARD TO WHATSAPP / INSTA',
                    icon: AppIcons.share,
                    isLoading: _isSharing,
                    onPressed: () => _shareCardImage(
                      displayName: displayName,
                      referralCode: code,
                      reps: _selectedExercise == 'pushup' ? 42 : 18,
                      area: userArea,
                      district: userDistrict,
                      state: userState,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
