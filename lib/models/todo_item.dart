enum TodoStatus { pending, completed }

class TodoItem {
  final String id;
  final String type;
  final int chapterNumber;
  final String title;
  final String level;
  final TodoStatus status;
  final DateTime? completedAt;

  const TodoItem({
    required this.id,
    required this.type,
    required this.chapterNumber,
    required this.title,
    required this.level,
    this.status = TodoStatus.pending,
    this.completedAt,
  });

  TodoItem copyWith({
    TodoStatus? status,
    DateTime? completedAt,
  }) {
    return TodoItem(
      id: id,
      type: type,
      chapterNumber: chapterNumber,
      title: title,
      level: level,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'chapterNumber': chapterNumber,
        'title': title,
        'level': level,
        'status': status.name,
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> j) => TodoItem(
        id: j['id'] as String,
        type: j['type'] as String,
        chapterNumber: j['chapterNumber'] as int,
        title: j['title'] as String,
        level: j['level'] as String,
        status: TodoStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => TodoStatus.pending,
        ),
        completedAt: j['completedAt'] != null
            ? DateTime.parse(j['completedAt'] as String)
            : null,
      );
}
