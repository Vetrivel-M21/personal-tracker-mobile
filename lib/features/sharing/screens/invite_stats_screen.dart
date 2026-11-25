import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code "$code" copied to clipboard!'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareInviteLink(String code, String displayName, String? area) async {
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

  void _showChallengeDialog(String referralCode, String displayName, String? area) {
    final repsController = TextEditingController(text: '30');
    String challengeExercise = _selectedExercise;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCardSolid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flash_on_rounded, color: AppColors.accentGold),
                      const SizedBox(width: 8),
                      Text(
                        'CHALLENGE A FRIEND',
                        style: AppTypography.headingMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set a target rep score and challenge your gym partner to beat it.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Exercise toggle
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: challengeExercise == 'pushup'
                                ? AppColors.primary
                                : AppColors.bgSidebar,
                            foregroundColor: challengeExercise == 'pushup'
                                ? AppColors.bgMain
                                : AppColors.textPrimary,
                          ),
                          onPressed: () => setModalState(() => challengeExercise = 'pushup'),
                          child: const Text('PUSH-UPS'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: challengeExercise == 'pullup'
                                ? AppColors.primary
                                : AppColors.bgSidebar,
                            foregroundColor: challengeExercise == 'pullup'
                                ? AppColors.bgMain
                                : AppColors.textPrimary,
                          ),
                          onPressed: () => setModalState(() => challengeExercise = 'pullup'),
                          child: const Text('PULL-UPS'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Target reps input
                  TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Target Reps to Beat',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      filled: true,
                      fillColor: AppColors.bgSidebar,
                    ),
                  ),
                  const SizedBox(height: 20),

                  PrimaryButton(
                    text: 'SEND 1-ON-1 CHALLENGE',
                    icon: Icons.send_rounded,
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
        backgroundColor: AppColors.bgMain,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined, color: AppColors.primary),
            tooltip: 'Hunters Directory',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CommunityScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Failed to load invite stats',
                  style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'RETRY',
                  onPressed: () => ref.read(referralStatsProvider.notifier).refresh(),
                ),
              ],
            ),
          ),
        ),
        data: (stats) {
          final code = stats.referralCode.isNotEmpty ? stats.referralCode : 'AURA88';

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.bgCardSolid,
            onRefresh: () => ref.read(referralStatsProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Referral Code Hero Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCardSolid,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'YOUR EXCLUSIVE INVITE CODE',
                          style: AppTypography.badge.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              code,
                              style: AppTypography.displayMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
                              tooltip: 'Copy Code',
                              onPressed: () => _copyToClipboard(code),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                text: 'SHARE LINK',
                                icon: Icons.share_rounded,
                                onPressed: () => _shareInviteLink(code, displayName, userArea),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SecondaryButton(
                                text: 'CHALLENGE',
                                icon: Icons.flash_on_rounded,
                                onPressed: () => _showChallengeDialog(code, displayName, userArea),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Growth Metric Bento Cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.group_rounded,
                          label: 'FRIENDS JOINED',
                          value: '${stats.inviteCount}',
                          sublabel: 'Registered Athletes',
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.verified_user_rounded,
                          label: 'VERIFIED',
                          value: '${stats.verifiedInvitesCount}',
                          sublabel: 'Confirmed Email',
                          iconColor: AppColors.accentGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StatCard(
                    icon: Icons.military_tech_rounded,
                    label: 'ACTIVE DISTRICT COMPETITORS',
                    value: '${stats.activeCompetitorsCount}',
                    sublabel: 'Submitted verified attempts',
                    iconColor: AppColors.accentGold,
                  ),

                  const SizedBox(height: 28),

                  // 3. Share Card Preview & Generation Section
                  Text(
                    'SOCIAL SHARE CARD',
                    style: AppTypography.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Exercise toggle chips
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Push-ups'),
                        selected: _selectedExercise == 'pushup',
                        selectedColor: AppColors.primary,
                        onSelected: (val) {
                          if (val) setState(() => _selectedExercise = 'pushup');
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Pull-ups'),
                        selected: _selectedExercise == 'pullup',
                        selectedColor: AppColors.primary,
                        onSelected: (val) {
                          if (val) setState(() => _selectedExercise = 'pullup');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Preview the high-contrast card that will be generated for your WhatsApp status or Instagram story.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // ShareCard inside RepaintBoundary for PNG capture
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

                  const SizedBox(height: 20),

                  PrimaryButton(
                    text: _isSharing ? 'GENERATING IMAGE...' : 'SHARE CARD TO WHATSAPP / INSTA',
                    icon: Icons.image_rounded,
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

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
