import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/level_badge.dart';
import '../../../widgets/rank_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/community_user.dart';
import '../services/community_service.dart';

final communityServiceProvider = Provider<CommunityService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommunityService(apiClient: apiClient);
});

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CommunityUser> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({String? query}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(communityServiceProvider);
      final list = await service.listUsers(query: query);
      if (mounted) {
        setState(() {
          _users = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGiveKudos(CommunityUser user) async {
    HapticFeedback.lightImpact();
    try {
      final service = ref.read(communityServiceProvider);
      final newKudos = await service.giveKudos(user.userId);
      if (mounted) {
        setState(() {
          _users = _users.map((u) {
            if (u.userId == user.userId) {
              return u.copyWith(kudosCount: newKudos);
            }
            return u;
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sent Kudos to ${user.displayName}! 🎉 +XP'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _showHabitsModal(CommunityUser user) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCardSolid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<UserHabitsSummary>(
          future: ref.read(communityServiceProvider).getHabitsSummary(user.userId),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text('Failed to load user habits: ${snapshot.error}', style: AppTypography.bodySmall),
              );
            }

            final summary = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${summary.displayName}\'s Habits', style: AppTypography.headingMedium),
                          Text('Current Streak: 🔥 ${summary.currentStreak} Days', style: AppTypography.labelSmall),
                        ],
                      ),
                      LevelBadge(level: user.level),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  if (summary.habitNames.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('No public habits active.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
                      ),
                    )
                  else
                    ...summary.habitNames.map(
                      (name) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.accentGreen, size: 18),
                            const SizedBox(width: 10),
                            Text(name, style: AppTypography.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
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
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('COMMUNITY HUNTERS', style: AppTypography.headingMedium),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              style: AppTypography.bodyMedium,
              onSubmitted: (q) => _loadUsers(query: q),
              decoration: InputDecoration(
                hintText: 'Search hunters by name...',
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    _loadUsers();
                  },
                ),
                filled: true,
                fillColor: AppColors.bgCardSolid,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),

          // Hunter Count Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_users.length} HUNTERS ACTIVE', style: AppTypography.labelSmall),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
                  onPressed: () => _loadUsers(query: _searchController.text),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.danger)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _loadUsers(),
                              child: const Text('RETRY'),
                            ),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? Center(
                            child: Text(
                              'No hunters found.',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: _users.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (ctx, index) {
                              final u = _users[index];
                              return _buildUserCard(u);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(CommunityUser user) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCardSolid,
        borderRadius: AppSpacing.roundedLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          LevelBadge(level: user.level),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: InkWell(
              onTap: () => _showHabitsModal(user),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: AppTypography.headingSmall.copyWith(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      RankBadge.fromXP(user.xp),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '🔥 ${user.currentStreak}d Streak',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.orange),
                      ),
                      if (user.activeSplitName != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '• ${user.activeSplitName}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.secondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Kudos Button
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _handleGiveKudos(user),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👏', style: AppTypography.rawEmojiSmall),
                  const SizedBox(width: 4),
                  Text(
                    '${user.kudosCount}',
                    style: AppTypography.badge.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
