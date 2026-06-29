class MockTestModel {
  final String id;
  final int testNumber;
  final String title;
  final String description;
  final List<MockTestQuestion> questions;

  MockTestModel({
    required this.id,
    required this.testNumber,
    required this.title,
    required this.description,
    this.questions = const [],
  });

  factory MockTestModel.fromJson(Map<String, dynamic> json) {
    return MockTestModel(
      id: json['id'] as String,
      testNumber: json['testNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => MockTestQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testNumber': testNumber,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class MockTestQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  MockTestQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory MockTestQuestion.fromJson(Map<String, dynamic> json) {
    return MockTestQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }
}
