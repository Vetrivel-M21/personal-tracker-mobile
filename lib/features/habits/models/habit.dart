class Habit {
  final String id;
  final String name;
  final String color;
  final String icon;
  final int schedule;
  final DateTime? archivedAt;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.schedule,
    this.archivedAt,
    required this.createdAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String? ?? '#22D3EE',
      icon: json['icon'] as String? ?? 'check',
      schedule: json['schedule'] as int? ?? 127,
      archivedAt: json['archived_at'] != null ? DateTime.tryParse(json['archived_at'] as String) : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'schedule': schedule,
      if (archivedAt != null) 'archived_at': archivedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    int? schedule,
    DateTime? archivedAt,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      schedule: schedule ?? this.schedule,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

