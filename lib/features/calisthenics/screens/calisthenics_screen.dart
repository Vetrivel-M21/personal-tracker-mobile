import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/calisthenics_skill.dart';
import '../providers/calisthenics_provider.dart';
import '../widgets/skill_node_card.dart';

class CalisthenicsScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;

  const CalisthenicsScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<CalisthenicsScreen> createState() => _CalisthenicsScreenState();
}

class _CalisthenicsScreenState extends ConsumerState<CalisthenicsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _branches = ['Push', 'Pull', 'Core', 'Legs'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _branches.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calisthenicsNotifierProvider);

    final content = state.isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : state.errorMessage != null
            ? _buildErrorView(state.errorMessage!)
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.bgCardSolid,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.primary, width: 1.2),
                      ),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: _branches.map((b) => Tab(text: b.toUpperCase())).toList(),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _branches.map((branch) {
                        final skills = state.branches[branch] ?? [];
                        return _buildBranchView(branch, skills, state.unlockingSkillId);
                      }).toList(),
                    ),
                  ),
                ],
              );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('Calisthenics Skill Tree', style: AppTypography.headingMedium),
      ),
      body: content,
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => ref.read(calisthenicsNotifierProvider.notifier).loadSkills(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchView(String branch, List<CalisthenicsSkill> skills, String? unlockingId) {
    final unlockedCount = skills.where((s) => s.unlocked).length;
    final totalCount = skills.length;
    final progress = totalCount == 0 ? 0.0 : unlockedCount / totalCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBranchHeader(branch, unlockedCount, totalCount, progress),
          const SizedBox(height: AppSpacing.lg),
          ...skills.map(
            (skill) => SkillNodeCard(
              skill: skill,
              isUnlocking: unlockingId == skill.id,
              onUnlock: () => _handleUnlock(skill),
            ),
          ),
          const SizedBox(height: 70), // Bottom padding for floating navigation bar
        ],
      ),
    );
  }

  Widget _buildBranchHeader(String branch, int unlocked, int total, double progress) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$branch Branch Mastery', style: AppTypography.titleMedium),
              Text(
                '$unlocked / $total Unlocked',
                style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppSpacing.roundedPill,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgMain,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUnlock(CalisthenicsSkill skill) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCardSolid,
        title: Text('Unlock ${skill.name}?', style: AppTypography.titleMedium),
        content: Text(
          'Have you mastered the prerequisite movement?\n\n"${skill.description}"',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm Unlock', style: TextStyle(color: AppColors.bgMain)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success =
          await ref.read(calisthenicsNotifierProvider.notifier).unlockSkill(skill.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              'Mastered ${skill.name}! Skill unlocked.',
              style: const TextStyle(color: AppColors.bgMain, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }
}

