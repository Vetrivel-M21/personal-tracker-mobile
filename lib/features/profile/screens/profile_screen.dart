import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/services/analytics_service.dart';
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
        content: Text(
          'Referral code "$code" copied to clipboard!',
          style: AppTypography.rawOnPrimaryBold,
        ),
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
          backgroundColor: AppColors.surface3,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedLg,
            side: const BorderSide(color: AppColors.borderStrong),
          ),
          title: Text('Change Password', style: AppTypography.headingMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordCtrl,
                obscureText: true,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: newPasswordCtrl,
                obscureText: true,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'New Password (min 8 chars)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
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
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
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
    final locationDisplay = user?.locationDisplay ?? 'Location Not Set';
    final area = user?.city ?? user?.area ?? 'Not Set';
    final district = user?.region ?? user?.district ?? 'Global';
    final stateName = user?.countryCode ?? user?.state ?? 'World';

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('Hunter Profile', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.lock, color: AppColors.textSecondary),
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
            // Character Card (surface1 + hairline; violet only in badges)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.surface2,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'H',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(displayName, style: AppTypography.headingLarge),
                  const SizedBox(height: 2),
                  Text(locationDisplay, style: AppTypography.bodySmall),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LevelBadge(level: level),
                      const SizedBox(width: AppSpacing.sm),
                      RankBadge.fromXP(xp),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                    icon: AppIcons.flame,
                    label: 'CURRENT STREAK',
                    value: '$streak Days',
                    iconColor: AppColors.gold,
                    sublabel: 'Daily Protocol',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    icon: AppIcons.shield,
                    label: 'STREAK SHIELDS',
                    value: '$shields Left',
                    iconColor: AppColors.primary,
                    sublabel: 'Earn 1 every 7 days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: AppIcons.award,
                    label: 'TOTAL XP',
                    value: '$xp',
                    iconColor: AppColors.gold,
                    sublabel: 'Lifetime Earned',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: StatCard(
                    icon: AppIcons.arena,
                    label: 'DISTRICT RANK',
                    value: myRank != null ? '#${myRank.rank}' : '--',
                    iconColor: AppColors.primary,
                    sublabel: district,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Territory Card
            Text('ASSIGNED TERRITORY', style: AppTypography.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(AppIcons.location, color: AppColors.primary, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$area, $district',
                          style: AppTypography.headingSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(stateName, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: AppSpacing.minTouchTarget,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(84, AppSpacing.minTouchTarget),
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.borderStrong),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.roundedMd,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LocationSetupScreen(isModal: true),
                          ),
                        );
                      },
                      child: const Text('Change'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Referral Code & Share Card
            Text('REFERRAL RECRUITMENT', style: AppTypography.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(color: AppColors.border),
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
                          Text('YOUR RECRUIT CODE', style: AppTypography.labelSmall),
                          const SizedBox(height: 2),
                          Text(
                            referralCode,
                            style: AppTypography.statNumber.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(AppIcons.copy, color: AppColors.primary),
                        tooltip: 'Copy Code',
                        onPressed: () => _copyReferralCode(referralCode),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Share Link',
                          icon: AppIcons.share,
                          onPressed: () =>
                              _shareInvite(referralCode, displayName, area),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Copy Code',
                          icon: AppIcons.copy,
                          onPressed: () => _copyReferralCode(referralCode),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Achievements Showcase (Gold for unlocked achievements)
            Text('ACHIEVEMENTS & BADGES', style: AppTypography.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            _buildAchievementTile(
              title: 'First Blood',
              description: 'Submit first verified challenge attempt',
              icon: AppIcons.challenge,
              isUnlocked: (myRank?.bestReps ?? 0) > 0,
            ),
            _buildAchievementTile(
              title: 'Iron Will',
              description: 'Maintain a 7-day habit streak',
              icon: AppIcons.flame,
              isUnlocked: streak >= 7,
            ),
            _buildAchievementTile(
              title: 'Centurion Reps',
              description: 'Achieve 50+ reps in a single attempt',
              icon: AppIcons.training,
              isUnlocked: (myRank?.bestReps ?? 0) >= 50,
            ),
            _buildAchievementTile(
              title: 'District Elite',
              description: 'Climb into the top 10 on your district leaderboard',
              icon: AppIcons.arena,
              isUnlocked: myRank != null && myRank.rank <= 10,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Logout Button
            SecondaryButton(
              text: 'Log Out',
              icon: Icons.logout_rounded,
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
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
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: isUnlocked
              ? AppColors.gold.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.gold.withValues(alpha: 0.14)
                  : AppColors.surface2,
              borderRadius: AppSpacing.roundedSm,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? AppColors.gold : AppColors.textMuted,
              size: 20,
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
                    color: isUnlocked
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(description, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Icon(
            isUnlocked ? AppIcons.check : AppIcons.lock,
            color: isUnlocked ? AppColors.success : AppColors.textMuted,
            size: 18,
          ),
        ],
      ),
    );
  }
}
