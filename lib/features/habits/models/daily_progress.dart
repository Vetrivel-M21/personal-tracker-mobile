class DailyProgress {
  final String id;
  final String date;
  final List<String> completedHabitIds;
  final double learningHours;
  final String mood;
  final String notes;

  const DailyProgress({
    required this.id,
    required this.date,
    required this.completedHabitIds,
    required this.learningHours,
    required this.mood,
    required this.notes,
  });

  factory DailyProgress.empty(String date) {
    return DailyProgress(
      id: '',
      date: date,
      completedHabitIds: const [],
      learningHours: 0.0,
      mood: 'Good',
      notes: '',
    );
  }

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      id: json['id'] as String? ?? '',
      date: json['date'] as String,
      completedHabitIds: (json['completed_habit_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      learningHours: (json['learning_hours'] as num?)?.toDouble() ?? 0.0,
      mood: json['mood'] as String? ?? 'Good',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_habit_ids': completedHabitIds,
      'learning_hours': learningHours,
      'mood': mood,
      'notes': notes,
    };
  }

  DailyProgress copyWith({
    String? id,
    String? date,
    List<String>? completedHabitIds,
    double? learningHours,
    String? mood,
    String? notes,
  }) {
    return DailyProgress(
      id: id ?? this.id,
      date: date ?? this.date,
      completedHabitIds: completedHabitIds ?? this.completedHabitIds,
      learningHours: learningHours ?? this.learningHours,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
    );
  }
}

