import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class RankBadge extends StatelessWidget {
  final String rank; // 'E', 'D', 'C', 'B', 'A', 'S'

  const RankBadge({super.key, required this.rank});

  factory RankBadge.fromXP(int xp) {
    if (xp >= 10000) return const RankBadge(rank: 'S');
    if (xp >= 5000) return const RankBadge(rank: 'A');
    if (xp >= 2000) return const RankBadge(rank: 'B');
    if (xp >= 800) return const RankBadge(rank: 'C');
    if (xp >= 200) return const RankBadge(rank: 'D');
    return const RankBadge(rank: 'E');
  }

  Color _getRankColor() {
    switch (rank.toUpperCase()) {
      case 'S':
        return AppColors.rankS;
      case 'A':
        return AppColors.rankA;
      case 'B':
        return AppColors.rankB;
      case 'C':
        return AppColors.rankC;
      case 'D':
        return AppColors.rankD;
      default:
        return AppColors.rankE;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRankColor();
    final isSRank = rank.toUpperCase() == 'S';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppSpacing.roundedFull,
        border: Border.all(color: color, width: 1.2),
        boxShadow: isSRank
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Text(
        '${rank.toUpperCase()}-RANK',
        style: AppTypography.badge.copyWith(color: color),
      ),
    );
  }
}
