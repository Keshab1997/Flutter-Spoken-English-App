class LessonModel {
  final String id;
  final String title;
  final String description;
  final String level; // 'Beginner', 'Intermediate', 'Advanced'
  final String category; // 'Vocabulary', 'Grammar', 'Conversation', 'Listening', 'Speaking'
  final int duration; // in minutes
  final List<String> content;
  final List<String> examples;
  final bool isPremium;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.category,
    this.duration = 10,
    this.content = const [],
    this.examples = const [],
    this.isPremium = false,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map, String docId) {
    return LessonModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      level: map['level'] ?? 'Beginner',
      category: map['category'] ?? 'Vocabulary',
      duration: map['duration'] ?? 10,
      content: List<String>.from(map['content'] ?? []),
      examples: List<String>.from(map['examples'] ?? []),
      isPremium: map['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'level': level,
      'category': category,
      'duration': duration,
      'content': content,
      'examples': examples,
      'isPremium': isPremium,
    };
  }
}
