class WorkoutSplitExercise {
  final String id;
  final String? exerciseId;
  final String name;
  final int targetSets;
  final String targetReps;
  final String notes;
  final int order;

  const WorkoutSplitExercise({
    required this.id,
    this.exerciseId,
    required this.name,
    required this.targetSets,
    required this.targetReps,
    required this.notes,
    required this.order,
  });

  factory WorkoutSplitExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutSplitExercise(
      id: json['id'] as String? ?? '',
      exerciseId: json['exercise_id'] as String?,
      name: json['name'] as String? ?? '',
      targetSets: json['target_sets'] as int? ?? 3,
      targetReps: json['target_reps'] as String? ?? '8-12',
      notes: json['notes'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class WorkoutSplitDay {
  final String id;
  final String name;
  final int order;
  final bool isRest;
  final List<WorkoutSplitExercise> exercises;

  const WorkoutSplitDay({
    required this.id,
    required this.name,
    required this.order,
    this.isRest = false,
    required this.exercises,
  });

  factory WorkoutSplitDay.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List<dynamic>? ?? [];
    return WorkoutSplitDay(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      isRest: json['is_rest'] as bool? ?? false,
      exercises: rawExercises
          .map((e) => WorkoutSplitExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WorkoutSplitSummary {
  final String id;
  final String name;
  final String source;
  final bool isActive;
  final int dayCount;

  const WorkoutSplitSummary({
    required this.id,
    required this.name,
    required this.source,
    required this.isActive,
    required this.dayCount,
  });

  factory WorkoutSplitSummary.fromJson(Map<String, dynamic> json) {
    return WorkoutSplitSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      source: json['source'] as String? ?? 'custom',
      isActive: json['is_active'] as bool? ?? false,
      dayCount: json['day_count'] as int? ?? 0,
    );
  }
}

class WorkoutSplitDetail {
  final String id;
  final String name;
  final String source;
  final bool isActive;
  final String? nextDayId;
  final List<WorkoutSplitDay> days;

  const WorkoutSplitDetail({
    required this.id,
    required this.name,
    required this.source,
    required this.isActive,
    this.nextDayId,
    required this.days,
  });

  factory WorkoutSplitDetail.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List<dynamic>? ?? [];
    return WorkoutSplitDetail(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      source: json['source'] as String? ?? 'custom',
      isActive: json['is_active'] as bool? ?? false,
      nextDayId: json['next_day_id'] as String?,
      days: rawDays
          .map((d) => WorkoutSplitDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

