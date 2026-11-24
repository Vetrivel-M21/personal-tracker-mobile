class WorkoutSessionSet {
  final String id;
  final String exerciseName;
  final int setNumber;
  final int reps;
  final double? weightKg;

  const WorkoutSessionSet({
    required this.id,
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    this.weightKg,
  });

  factory WorkoutSessionSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionSet(
      id: json['id'] as String? ?? '',
      exerciseName: json['exercise_name'] as String? ?? '',
      setNumber: json['set_number'] as int? ?? 1,
      reps: json['reps'] as int? ?? 0,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'exerciseName': exerciseName,
      'setNumber': setNumber,
      'reps': reps,
      if (weightKg != null) 'weightKg': weightKg,
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
  final List<WorkoutSessionSet> sets;

  const WorkoutSession({
    required this.id,
    this.splitId,
    this.splitDayId,
    required this.dayLabel,
    required this.sessionDate,
    required this.notes,
    required this.sets,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final rawSets = json['sets'] as List<dynamic>? ?? [];
    return WorkoutSession(
      id: json['id'] as String? ?? '',
      splitId: json['split_id'] as String?,
      splitDayId: json['split_day_id'] as String?,
      dayLabel: json['day_label'] as String? ?? 'Workout',
      sessionDate: json['session_date'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      sets: rawSets
          .map((s) => WorkoutSessionSet.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

