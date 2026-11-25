class CommunityUser {
  final String userId;
  final String displayName;
  final int level;
  final int xp;
  final int currentStreak;
  final String? activeSplitName;
  final int kudosCount;

  const CommunityUser({
    required this.userId,
    required this.displayName,
    required this.level,
    required this.xp,
    required this.currentStreak,
    this.activeSplitName,
    required this.kudosCount,
  });

  factory CommunityUser.fromJson(Map<String, dynamic> json) {
    return CommunityUser(
      userId: json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Hunter',
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      activeSplitName: json['active_split_name'] as String?,
      kudosCount: json['kudos_count'] as int? ?? 0,
    );
  }

  CommunityUser copyWith({
    String? userId,
    String? displayName,
    int? level,
    int? xp,
    int? currentStreak,
    String? activeSplitName,
    int? kudosCount,
  }) {
    return CommunityUser(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      currentStreak: currentStreak ?? this.currentStreak,
      activeSplitName: activeSplitName ?? this.activeSplitName,
      kudosCount: kudosCount ?? this.kudosCount,
    );
  }
}

class UserHabitsSummary {
  final String displayName;
  final int currentStreak;
  final int totalHabits;
  final List<String> habitNames;

  const UserHabitsSummary({
    required this.displayName,
    required this.currentStreak,
    required this.totalHabits,
    required this.habitNames,
  });

  factory UserHabitsSummary.fromJson(Map<String, dynamic> json) {
    final habits = (json['habits'] as List<dynamic>?)
            ?.map((h) => (h is Map ? h['name']?.toString() : h.toString()) ?? '')
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    return UserHabitsSummary(
      displayName: json['display_name'] as String? ?? 'Hunter',
      currentStreak: json['current_streak'] as int? ?? 0,
      totalHabits: habits.length,
      habitNames: habits,
    );
  }
}
