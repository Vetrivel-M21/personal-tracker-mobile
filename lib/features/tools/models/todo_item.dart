class TodoItem {
  final String id;
  final String title;
  final String status; // 'todo', 'in_progress', 'done'
  final String priority; // 'low', 'medium', 'high'
  final String createdAt;

  const TodoItem({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  bool get isDone => status == 'done';

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'todo',
      priority: json['priority'] as String? ?? 'medium',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  TodoItem copyWith({
    String? id,
    String? title,
    String? status,
    String? priority,
    String? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
