import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../../../widgets/exp_bar.dart';
import '../../../widgets/level_badge.dart';
import '../../../widgets/rank_badge.dart';
import '../../../widgets/stat_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../competition/providers/competition_provider.dart';
import '../../habits/providers/habits_provider.dart';
import '../../onboarding/screens/location_setup_screen.dart';
import '../../sharing/services/invite_link_service.dart';
import '../../sharing/services/share_card_service.dart';
import '../../../data/services/analytics_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _copyReferralCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code "$code" copied to clipboard!'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareInvite(String code, String name, String? area) async {
    final analytics = ref.read(analyticsServiceProvider);
    final message = InviteLinkService.buildInviteMessage(
      referralCode: code,
      displayName: name,
      area: area,
    );
    await ShareCardService.shareText(
      text: message,
      analytics: analytics,
      platform: 'whatsapp_profile',
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgCardSolid,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
          title: Text('CHANGE PASSWORD', style: AppTypography.headingMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordCtrl,
                obscureText: true,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordCtrl,
                obscureText: true,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(labelText: 'New Password (min 8 chars)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (newPasswordCtrl.text.trim().length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password must be at least 8 characters'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isLoading = true);
                      try {
                        final apiClient = ref.read(apiClientProvider);
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(ctx);
                        await apiClient.dio.patch('/api/me/password', data: {
                          'old_password': oldPasswordCtrl.text,
                          'new_password': newPasswordCtrl.text,
                        });
                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Password updated successfully!'),
                            backgroundColor: AppColors.accentGreen,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('UPDATE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final leaderboardState = ref.watch(leaderboardNotifierProvider);
    final myRank = leaderboardState.data?.myRank;
    final habitsState = ref.watch(habitsNotifierProvider);
    final streakStats = habitsState.streakStats;

    final displayName = user?.displayName ?? 'Hunter';
    final level = user?.level ?? 1;
    final xp = user?.xp ?? 0;
    final xpInto = user?.xpIntoLevel ?? 0;
    final xpNext = user?.xpForNextLevel ?? 100;
    final streak = streakStats.currentStreak;
    final shields = streakStats.shieldsRemaining;
    final referralCode = user?.referralCode ?? 'TNCHAMP';
    final area = user?.area ?? 'Not Set';
    final district = user?.district ?? 'Tamil Nadu';
    final stateName = user?.state ?? 'Tamil Nadu';

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('HUNTER PROFILE', style: AppTypography.headingMedium),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset, color: AppColors.textSecondary),
            tooltip: 'Change Password',
            onPressed: _showChangePasswordDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Character Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.bgCardSolid,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryMuted,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'H',
                      style: AppTypography.displayMedium.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(displayName, style: AppTypography.headingLarge),
                  Text('$area, $district', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LevelBadge(level: level),
                      const SizedBox(width: AppSpacing.sm),
                      RankBadge.fromXP(xp),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ExpBar(xpIntoLevel: xpInto, xpForNextLevel: xpNext),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Streaks & Shields Stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department,
                    label: 'CURRENT STREAK',
                    value: '$streak Days',
                    iconColor: AppColors.orange,
                    sublabel: 'Daily Protocol',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    icon: Icons.shield,
                    label: 'STREAK SHIELDS',
                    value: '$shields Remaining',
                    iconColor: AppColors.primary,
                    sublabel: 'Earn 1 every 7 days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.military_tech,
                    label: 'TOTAL XP',
                    value: '$xp',
                    iconColor: AppColors.accentGold,
                    sublabel: 'Lifetime Earned',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    icon: Icons.fitness_center,
                    label: 'DISTRICT RANK',
                    value: myRank != null ? '#${myRank.rank}' : '--',
                    iconColor: AppColors.secondary,
                    sublabel: district,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Territory Card (Tap to change)
            Text('ASSIGNED TERRITORY', style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgCardSolid,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$area, $district', style: AppTypography.headingSmall),
                        Text(stateName, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LocationSetupScreen(isModal: true),
                        ),
                      );
                    },
                    child: const Text('CHANGE'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Referral Code & Share Card
            Text('REFERRAL RECRUITMENT', style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgCardSolid,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('YOUR RECRUIT CODE', style: AppTypography.bodySmall),
                          Text(
                            referralCode,
                            style: AppTypography.displayLarge.copyWith(
                              fontSize: 24,
                              color: AppColors.primary,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: AppColors.primary),
                        tooltip: 'Copy Code',
                        onPressed: () => _copyReferralCode(referralCode),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('SHARE LINK'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _shareInvite(referralCode, displayName, area),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('COPY CODE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.bgMain,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _copyReferralCode(referralCode),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Hunter Achievements Showcase
            Text('ACHIEVEMENTS & BADGES', style: AppTypography.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            _buildAchievementTile(
              title: 'First Blood',
              description: 'Submit first verified challenge attempt',
              icon: Icons.bolt,
              isUnlocked: (myRank?.bestReps ?? 0) > 0,
            ),
            _buildAchievementTile(
              title: 'Iron Will',
              description: 'Maintain a 7-day habit streak',
              icon: Icons.local_fire_department,
              isUnlocked: streak >= 7,
            ),
            _buildAchievementTile(
              title: 'Centurion Reps',
              description: 'Achieve 50+ reps in a single attempt',
              icon: Icons.fitness_center,
              isUnlocked: (myRank?.bestReps ?? 0) >= 50,
            ),
            _buildAchievementTile(
              title: 'District Elite',
              description: 'Climb into the top 10 on your district leaderboard',
              icon: Icons.emoji_events,
              isUnlocked: myRank != null && myRank.rank <= 10,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Logout Button
            SecondaryButton(
              text: 'LOG OUT OF HUNTER SYSTEM',
              icon: Icons.logout,
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementTile({
    required String title,
    required String description,
    required IconData icon,
    required bool isUnlocked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.bgCardSolid : AppColors.bgSidebar.withValues(alpha: 0.5),
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: isUnlocked ? AppColors.accentGold.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.accentGold.withValues(alpha: 0.15)
                  : AppColors.border.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? AppColors.accentGold : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headingSmall.copyWith(
                    color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 15,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: isUnlocked ? AppColors.accentGreen : AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}
