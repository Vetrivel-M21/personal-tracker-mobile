import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/rank_badge.dart';

/// High-impact visual card generated for social sharing (WhatsApp status, Instagram stories).
/// Designed according to the "Athletic Cyber-HUD & Gamified Competition" design system.
class ShareCard extends StatelessWidget {
  final String displayName;
  final String exercise;
  final int reps;
  final String rank; // 'S', 'A', 'B', 'C', 'D', 'E'
  final String? area;
  final String? district;
  final String? state;
  final String referralCode;
  final bool isAiVerified;

  const ShareCard({
    super.key,
    required this.displayName,
    required this.exercise,
    required this.reps,
    this.rank = 'A',
    this.area,
    this.district,
    this.state = 'Tamil Nadu',
    required this.referralCode,
    this.isAiVerified = true,
  });

  String get territoryText {
    final parts = [area, district, state].where((p) => p != null && p.isNotEmpty).toList();
    if (parts.isEmpty) return 'TAMIL NADU';
    return parts.join(' • ').toUpperCase();
  }

  String get exerciseLabel {
    return exercise.toLowerCase() == 'pushup' ? 'PUSH-UPS' : 'PULL-UPS';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header: Brand & Territory
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'AURA CHAMPIONSHIP',
                        style: AppTypography.badge.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RankBadge(rank: rank),
            ],
          ),

          const SizedBox(height: 16),

          // Territory Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              territoryText,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Athlete Name
          Text(
            displayName.toUpperCase(),
            style: AppTypography.headingMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Big Reps Number HUD Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.bgMain.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$reps',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.primary,
                    fontSize: 72,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(
                        color: AppColors.primary.withValues(alpha: 0.8),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MAX $exerciseLabel',
                  style: AppTypography.badge.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Verification Stamp
          if (isAiVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentGreen.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppColors.accentGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AI POSE VERIFIED',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Footer: Referral / Challenge CTA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgSidebar,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'BEAT MY SCORE',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'CODE: ${referralCode.toUpperCase()}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'aura.fit',
                  style: AppTypography.badge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
