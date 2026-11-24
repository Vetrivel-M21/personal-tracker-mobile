class WorkoutTemplateSummary {
  final String id;
  final String name;
  final String description;
  final int daysPerWeek;
  final String level;

  const WorkoutTemplateSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.daysPerWeek,
    required this.level,
  });

  factory WorkoutTemplateSummary.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      daysPerWeek: json['days_per_week'] as int? ?? 3,
      level: json['level'] as String? ?? 'Intermediate',
    );
  }
}

