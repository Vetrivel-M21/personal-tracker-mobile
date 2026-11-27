import 'package:flutter_test/flutter_test.dart';
import 'package:personal_tracker_mobile/features/system/models/hunter_models.dart';

void main() {
  group('Hunter System Models', () {
    test('HunterStats parses JSON correctly', () {
      final json = {
        'str': 25,
        'agi': 30,
        'vit': 22,
        'end': 18,
        'streak_shields': 2,
      };
      final stats = HunterStats.fromJson(json);
      expect(stats.str, 25);
      expect(stats.agi, 30);
      expect(stats.vit, 22);
      expect(stats.end, 18);
      expect(stats.streakShields, 2);
    });

    test('QuestItem calculates completion status accurately', () {
      final json = {
        'id': 'itm-1',
        'quest_id': 'q-1',
        'description': 'Perform 50 Push-Ups',
        'target_count': 50,
        'current_count': 50,
        'unit': 'reps',
        'stat_type': 'STR',
        'is_completed': true,
      };
      final item = QuestItem.fromJson(json);
      expect(item.id, 'itm-1');
      expect(item.isCompleted, true);
      expect(item.currentCount, 50);
      expect(item.statType, 'STR');
    });

    test('Quest evaluates allItemsFinished and status getters', () {
      final item1 = QuestItem(
        id: '1',
        questId: 'q',
        description: 'Trial 1',
        targetCount: 10,
        currentCount: 10,
        unit: 'reps',
        statType: 'STR',
        isCompleted: true,
      );
      final item2 = QuestItem(
        id: '2',
        questId: 'q',
        description: 'Trial 2',
        targetCount: 1,
        currentCount: 1,
        unit: 'session',
        statType: 'VIT',
        isCompleted: true,
      );

      final quest = Quest(
        id: 'q',
        userId: 'u',
        questDate: '2026-11-26',
        rank: 'E',
        status: 'in_progress',
        title: 'Daily Training',
        description: 'Conditioning',
        rewardXp: 120,
        items: [item1, item2],
      );

      expect(quest.isInProgress, true);
      expect(quest.isCompleted, false);
      expect(quest.allItemsFinished, true);
    });

    test('HunterProfile deserializes nested stats and titles', () {
      final json = {
        'user_id': 'u-1',
        'name': 'Jinwoo',
        'rank': 'S',
        'level': 55,
        'xp': 150000,
        'xp_into_level': 1200,
        'xp_for_next_level': 151250,
        'stats': {
          'str': 88,
          'agi': 92,
          'vit': 85,
          'end': 90,
          'streak_shields': 3,
        },
        'active_title': 'Monarch of Fitness',
        'titles': [
          {
            'id': 't-1',
            'title_name': 'Monarch of Fitness',
            'unlocked_at': '2026-11-20',
            'is_active': true,
          }
        ],
        'recent_xp_events': [
          {
            'id': 'ev-1',
            'amount': 250,
            'source': 'quest',
            'created_at': '2026-11-26 10:00:00',
          }
        ],
      };

      final profile = HunterProfile.fromJson(json);
      expect(profile.name, 'Jinwoo');
      expect(profile.rank, 'S');
      expect(profile.level, 55);
      expect(profile.stats.str, 88);
      expect(profile.activeTitle, 'Monarch of Fitness');
      expect(profile.titles.length, 1);
      expect(profile.recentXpEvents.first.amount, 250);
    });
  });
}
