class HunterStats {
  final int str;
  final int agi;
  final int vit;
  final int end;
  final int streakShields;

  const HunterStats({
    required this.str,
    required this.agi,
    required this.vit,
    required this.end,
    required this.streakShields,
  });

  factory HunterStats.fromJson(Map<String, dynamic> json) {
    return HunterStats(
      str: json['str'] as int? ?? 10,
      agi: json['agi'] as int? ?? 10,
      vit: json['vit'] as int? ?? 10,
      end: json['end'] as int? ?? 10,
      streakShields: json['streak_shields'] as int? ?? 1,
    );
  }
}

class QuestItem {
  final String id;
  final String questId;
  final String description;
  final int targetCount;
  final int currentCount;
  final String unit;
  final String statType;
  final bool isCompleted;

  const QuestItem({
    required this.id,
    required this.questId,
    required this.description,
    required this.targetCount,
    required this.currentCount,
    required this.unit,
    required this.statType,
    required this.isCompleted,
  });

  factory QuestItem.fromJson(Map<String, dynamic> json) {
    return QuestItem(
      id: json['id'] as String? ?? '',
      questId: json['quest_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetCount: json['target_count'] as int? ?? 1,
      currentCount: json['current_count'] as int? ?? 0,
      unit: json['unit'] as String? ?? 'reps',
      statType: json['stat_type'] as String? ?? 'STR',
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

class Quest {
  final String id;
  final String userId;
  final String questDate;
  final String rank;
  final String status; // pending, in_progress, completed, failed
  final String title;
  final String description;
  final int rewardXp;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? failureReason;
  final List<QuestItem> items;

  const Quest({
    required this.id,
    required this.userId,
    required this.questDate,
    required this.rank,
    required this.status,
    required this.title,
    required this.description,
    required this.rewardXp,
    this.startedAt,
    this.completedAt,
    this.failureReason,
    required this.items,
  });

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';

  bool get allItemsFinished => items.isNotEmpty && items.every((i) => i.currentCount >= i.targetCount);

  factory Quest.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is String) return DateTime.tryParse(d);
      return null;
    }

    return Quest(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      questDate: json['quest_date'] as String? ?? '',
      rank: json['rank'] as String? ?? 'E',
      status: json['status'] as String? ?? 'pending',
      title: json['title'] as String? ?? 'Daily Quest',
      description: json['description'] as String? ?? '',
      rewardXp: json['reward_xp'] as int? ?? 100,
      startedAt: parseDate(json['started_at']),
      completedAt: parseDate(json['completed_at']),
      failureReason: json['failure_reason'] as String?,
      items: rawItems
          .map((i) => QuestItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UserTitle {
  final String id;
  final String titleName;
  final String unlockedAt;
  final bool isActive;

  const UserTitle({
    required this.id,
    required this.titleName,
    required this.unlockedAt,
    required this.isActive,
  });

  factory UserTitle.fromJson(Map<String, dynamic> json) {
    return UserTitle(
      id: json['id'] as String? ?? '',
      titleName: json['title_name'] as String? ?? '',
      unlockedAt: json['unlocked_at'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}

class XPEvent {
  final String id;
  final int amount;
  final String source;
  final String? sourceId;
  final String createdAt;

  const XPEvent({
    required this.id,
    required this.amount,
    required this.source,
    this.sourceId,
    required this.createdAt,
  });

  factory XPEvent.fromJson(Map<String, dynamic> json) {
    return XPEvent(
      id: json['id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      source: json['source'] as String? ?? '',
      sourceId: json['source_id'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class HunterProfile {
  final String userId;
  final String name;
  final String rank;
  final int level;
  final int xp;
  final int xpIntoLevel;
  final int xpForNextLevel;
  final HunterStats stats;
  final String? activeTitle;
  final List<UserTitle> titles;
  final List<XPEvent> recentXpEvents;
  final Quest? todayQuest;

  const HunterProfile({
    required this.userId,
    required this.name,
    required this.rank,
    required this.level,
    required this.xp,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.stats,
    this.activeTitle,
    required this.titles,
    required this.recentXpEvents,
    this.todayQuest,
  });

  factory HunterProfile.fromJson(Map<String, dynamic> json) {
    final rawTitles = json['titles'] as List<dynamic>? ?? [];
    final rawEvents = json['recent_xp_events'] as List<dynamic>? ?? [];
    return HunterProfile(
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? json['display_name'] as String? ?? 'Hunter',
      rank: json['rank'] as String? ?? 'E',
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      xpIntoLevel: json['xp_into_level'] as int? ?? 0,
      xpForNextLevel: json['xp_for_next_level'] as int? ?? 100,
      stats: json['stats'] != null
          ? HunterStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const HunterStats(str: 10, agi: 10, vit: 10, end: 10, streakShields: 1),
      activeTitle: json['active_title'] as String?,
      titles: rawTitles.map((t) => UserTitle.fromJson(t as Map<String, dynamic>)).toList(),
      recentXpEvents: rawEvents.map((e) => XPEvent.fromJson(e as Map<String, dynamic>)).toList(),
      todayQuest: json['today_quest'] != null
          ? Quest.fromJson(json['today_quest'] as Map<String, dynamic>)
          : null,
    );
  }
}
