import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/calisthenics_skill.dart';

class SkillNodeCard extends StatelessWidget {
  final CalisthenicsSkill skill;
  final bool isUnlocking;
  final VoidCallback onUnlock;

  const SkillNodeCard({
    super.key,
    required this.skill,
    required this.isUnlocking,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = _resolveBorderColor();
    final bgColor = _resolveBgColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: borderColor, width: skill.unlocked ? 1.5 : 1.0),
        boxShadow: skill.unlocked ? [AppColors.glowShadow(AppColors.primary)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTierBadge(),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  skill.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: skill.unlocked
                        ? AppColors.textPrimary
                        : skill.available
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusIcon(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            skill.description,
            style: AppTypography.bodySmall.copyWith(
              color: skill.unlocked || skill.available
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
            ),
          ),
          if (skill.available && !skill.unlocked) ...[
            const SizedBox(height: AppSpacing.md),
            _buildUnlockButton(),
          ],
        ],
      ),
    );
  }

  Color _resolveBorderColor() {
    if (skill.unlocked) return AppColors.primary;
    if (skill.available) return AppColors.warning;
    return AppColors.border;
  }

  Color _resolveBgColor() {
    if (skill.unlocked) return AppColors.primaryMuted;
    if (skill.available) return AppColors.bgCardSolid;
    return AppColors.bgCard;
  }

  Widget _buildTierBadge() {
    final tierColor = _tierColor(skill.tier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tierColor.withValues(alpha: 0.15),
        borderRadius: AppSpacing.roundedSm,
        border: Border.all(color: tierColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        'T${skill.tier}',
        style: AppTypography.labelSmall.copyWith(color: tierColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _tierColor(int tier) {
    switch (tier) {
      case 1:
        return AppColors.rankD;
      case 2:
        return AppColors.rankC;
      case 3:
        return AppColors.rankB;
      case 4:
        return AppColors.rankA;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildStatusIcon() {
    if (skill.unlocked) {
      return const Icon(Icons.check_circle, color: AppColors.primary, size: 22);
    }
    if (skill.available) {
      return const Icon(Icons.lock_open, color: AppColors.warning, size: 22);
    }
    return const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 22);
  }

  Widget _buildUnlockButton() {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: ElevatedButton(
        onPressed: isUnlocking ? null : onUnlock,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.bgMain,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
        ),
        child: isUnlocking
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bgMain),
              )
            : Text(
                'UNLOCK SKILL',
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

