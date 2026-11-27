class WorkoutSessionSet {
  final String id;
  final String? exerciseId;
  final String exerciseName;
  final int setNumber;
  final int reps;
  final double? weightKg;
  final int? durationSeconds;
  final double? rpe;
  final String setType;
  final bool isPr;
  final String? prType;

  const WorkoutSessionSet({
    required this.id,
    this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    this.weightKg,
    this.durationSeconds,
    this.rpe,
    this.setType = 'normal',
    this.isPr = false,
    this.prType,
  });

  factory WorkoutSessionSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionSet(
      id: json['id'] as String? ?? '',
      exerciseId: json['exercise_id'] as String?,
      exerciseName: json['exercise_name'] as String? ?? '',
      setNumber: json['set_number'] as int? ?? 1,
      reps: json['reps'] as int? ?? 0,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      durationSeconds: json['duration_seconds'] as int?,
      rpe: (json['rpe'] as num?)?.toDouble(),
      setType: json['set_type'] as String? ?? 'normal',
      isPr: json['is_pr'] as bool? ?? false,
      prType: json['pr_type'] as String?,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      if (exerciseId != null) 'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'setNumber': setNumber,
      'reps': reps,
      if (weightKg != null) 'weightKg': weightKg,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      if (rpe != null) 'rpe': rpe,
      'setType': setType,
    };
  }
}

class WorkoutSession {
  final String id;
  final String? splitId;
  final String? splitDayId;
  final String dayLabel;
  final String sessionDate;
  final String notes;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final double? bodyweightKg;
  final String? clientRequestId;
  final double totalVolume;
  final int totalSets;
  final String? nextDayId;
  final List<dynamic> newPrs;
  final List<WorkoutSessionSet> sets;

  const WorkoutSession({
    required this.id,
    this.splitId,
    this.splitDayId,
    required this.dayLabel,
    required this.sessionDate,
    required this.notes,
    this.startedAt,
    this.endedAt,
    this.bodyweightKg,
    this.clientRequestId,
    this.totalVolume = 0.0,
    this.totalSets = 0,
    this.nextDayId,
    this.newPrs = const [],
    required this.sets,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final rawSets = json['sets'] as List<dynamic>? ?? [];
    DateTime? parseDate(dynamic d) {
      if (d == null) return null;
      if (d is String) return DateTime.tryParse(d);
      return null;
    }

    return WorkoutSession(
      id: json['id'] as String? ?? '',
      splitId: json['split_id'] as String?,
      splitDayId: json['split_day_id'] as String?,
      dayLabel: json['day_label'] as String? ?? 'Workout',
      sessionDate: json['session_date'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      startedAt: parseDate(json['started_at']),
      endedAt: parseDate(json['ended_at']),
      bodyweightKg: (json['bodyweight_kg'] as num?)?.toDouble(),
      clientRequestId: json['client_request_id'] as String?,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      totalSets: json['total_sets'] as int? ?? rawSets.length,
      nextDayId: json['next_day_id'] as String?,
      newPrs: json['new_prs'] as List<dynamic>? ?? [],
      sets: rawSets
          .map((s) => WorkoutSessionSet.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

