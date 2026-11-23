import 'package:flutter/material.dart';
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final displayName = user?.displayName ?? 'Athlete';
    final level = user?.level ?? 1;
    final xp = user?.xp ?? 0;
    final xpInto = user?.xpIntoLevel ?? 0;
    final xpNext = user?.xpForNextLevel ?? 100;
    final area = user?.area ?? 'Anna Nagar';
    final district = user?.district ?? 'Chennai';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            LevelBadge(level: level),
            const SizedBox(width: AppSpacing.sm),
            Text(displayName, style: AppTypography.headingMedium),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(child: RankBadge.fromXP(xp)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // EXP Progress Header Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgCardSolid,
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: ExpBar(xpIntoLevel: xpInto, xpForNextLevel: xpNext),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Location Rank Badge
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: AppSpacing.roundedLg,
                  border: Border.all(color: AppColors.borderHover),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('COMPETING IN', style: AppTypography.bodySmall),
                          Text(
                            '$area, $district',
                            style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    Text('#14 In Area', style: AppTypography.badge.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Large Start Challenge Button
              Container(
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: AppSpacing.roundedXl,
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryGlow,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppSpacing.roundedXl,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Starting Push-Up Max-Rep Challenge...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on, size: 40, color: AppColors.bgMain),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'START CHALLENGE',
                                  style: AppTypography.headingLarge.copyWith(
                                    color: AppColors.bgMain,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Post Push-Ups & Climb TN Rank',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.bgMain.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: AppColors.bgMain, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.fitness_center,
                      label: 'BEST PUSHUPS',
                      value: '65',
                      sublabel: 'Verified',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      icon: Icons.sports_gymnastics,
                      label: 'BEST PULLUPS',
                      value: '18',
                      iconColor: AppColors.secondary,
                      sublabel: 'Verified',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Logout / Switch
              SecondaryButton(
                text: 'LOG OUT',
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
