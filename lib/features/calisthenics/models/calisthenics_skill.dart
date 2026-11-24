class CalisthenicsSkill {
  final String id;
  final String branch;
  final int order;
  final int tier;
  final String name;
  final String description;
  final bool unlocked;
  final bool available;

  const CalisthenicsSkill({
    required this.id,
    required this.branch,
    required this.order,
    required this.tier,
    required this.name,
    required this.description,
    required this.unlocked,
    required this.available,
  });

  factory CalisthenicsSkill.fromJson(Map<String, dynamic> json) {
    return CalisthenicsSkill(
      id: json['id'] as String,
      branch: json['branch'] as String,
      order: json['order'] as int? ?? 0,
      tier: json['tier'] as int? ?? 1,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      unlocked: json['unlocked'] as bool? ?? false,
      available: json['available'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch': branch,
      'order': order,
      'tier': tier,
      'name': name,
      'description': description,
      'unlocked': unlocked,
      'available': available,
    };
  }

  CalisthenicsSkill copyWith({
    String? id,
    String? branch,
    int? order,
    int? tier,
    String? name,
    String? description,
    bool? unlocked,
    bool? available,
  }) {
    return CalisthenicsSkill(
      id: id ?? this.id,
      branch: branch ?? this.branch,
      order: order ?? this.order,
      tier: tier ?? this.tier,
      name: name ?? this.name,
      description: description ?? this.description,
      unlocked: unlocked ?? this.unlocked,
      available: available ?? this.available,
    );
  }
}

