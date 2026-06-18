class QuizModel {
  final String id;
  final String title;
  final String type; // 'MCQ', 'FillBlanks', 'MatchWords', 'Listening', 'Speaking'
  final String level;
  final List<QuestionModel> questions;
  final int timeLimit; // in seconds

  QuizModel({
    required this.id,
    required this.title,
    required this.type,
    required this.level,
    this.questions = const [],
    this.timeLimit = 300,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map, String docId) {
    return QuizModel(
      id: docId,
      title: map['title'] ?? '',
      type: map['type'] ?? 'MCQ',
      level: map['level'] ?? 'Beginner',
      questions: (map['questions'] as List? ?? [])
          .map((q) => QuestionModel.fromMap(q))
          .toList(),
      timeLimit: map['timeLimit'] ?? 300,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'level': level,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimit': timeLimit,
    };
  }
}

class QuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
      explanation: map['explanation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }
}
