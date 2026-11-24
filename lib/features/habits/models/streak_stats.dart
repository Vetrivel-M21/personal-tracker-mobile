class StreakStats {
  final int currentStreak;
  final int shieldsRemaining;

  const StreakStats({
    required this.currentStreak,
    required this.shieldsRemaining,
  });

  factory StreakStats.initial() {
    return const StreakStats(currentStreak: 0, shieldsRemaining: 0);
  }

  factory StreakStats.fromJson(Map<String, dynamic> json) {
    return StreakStats(
      currentStreak: json['current_streak'] as int? ?? 0,
      shieldsRemaining: json['shields_remaining'] as int? ?? 0,
    );
  }
}

