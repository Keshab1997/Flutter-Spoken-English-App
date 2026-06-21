import 'package:hive/hive.dart';

part 'wrong_question_model.g.dart';

/// Represents a question the student answered incorrectly,
/// saved to Hive so they can review it later.
@HiveType(typeId: 10)
class WrongQuestionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String tenseType;

  @HiveField(2)
  final String question;

  @HiveField(3)
  final String options; // JSON-encoded List<String>

  @HiveField(4)
  final String correctAnswer;

  @HiveField(5)
  final String explanation;

  @HiveField(6)
  final String userAnswer;

  @HiveField(7)
  final String difficulty;

  @HiveField(8)
  final String mode;

  @HiveField(9)
  final String savedAt; // ISO-8601 date string

  @HiveField(10)
  final int reviewCount; // how many times the student has reviewed this

  const WrongQuestionModel({
    required this.id,
    required this.tenseType,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.userAnswer,
    required this.difficulty,
    required this.mode,
    required this.savedAt,
    this.reviewCount = 0,
  });

  factory WrongQuestionModel.fromGameQuestion({
    required String questionId,
    required String tenseType,
    required String question,
    required List<String> options,
    required String correctAnswer,
    required String explanation,
    required String userAnswer,
    required String difficulty,
    required String mode,
  }) {
    return WrongQuestionModel(
      id: questionId,
      tenseType: tenseType,
      question: question,
      options: _encode(options),
      correctAnswer: correctAnswer,
      explanation: explanation,
      userAnswer: userAnswer,
      difficulty: difficulty,
      mode: mode,
      savedAt: DateTime.now().toIso8601String(),
    );
  }

  List<String> get decodedOptions => _decode(options);

  WrongQuestionModel incrementReview() {
    return copyWith(reviewCount: reviewCount + 1);
  }

  WrongQuestionModel copyWith({
    String? id,
    String? tenseType,
    String? question,
    String? options,
    String? correctAnswer,
    String? explanation,
    String? userAnswer,
    String? difficulty,
    String? mode,
    String? savedAt,
    int? reviewCount,
  }) {
    return WrongQuestionModel(
      id: id ?? this.id,
      tenseType: tenseType ?? this.tenseType,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      userAnswer: userAnswer ?? this.userAnswer,
      difficulty: difficulty ?? this.difficulty,
      mode: mode ?? this.mode,
      savedAt: savedAt ?? this.savedAt,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenseType': tenseType,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'userAnswer': userAnswer,
      'difficulty': difficulty,
      'mode': mode,
      'savedAt': savedAt,
      'reviewCount': reviewCount,
    };
  }

  factory WrongQuestionModel.fromMap(Map<String, dynamic> map) {
    return WrongQuestionModel(
      id: map['id'] as String? ?? '',
      tenseType: map['tenseType'] as String? ?? '',
      question: map['question'] as String? ?? '',
      options: map['options'] as String? ?? '[]',
      correctAnswer: map['correctAnswer'] as String? ?? '',
      explanation: map['explanation'] as String? ?? '',
      userAnswer: map['userAnswer'] as String? ?? '',
      difficulty: map['difficulty'] as String? ?? '',
      mode: map['mode'] as String? ?? '',
      savedAt: map['savedAt'] as String? ?? '',
      reviewCount: map['reviewCount'] as int? ?? 0,
    );
  }

  // ── JSON encode/decode for List<String> ──

  static String _encode(List<String> list) {
    // Simple comma-separated encoding
    return list.join('‖');
  }

  static List<String> _decode(String encoded) {
    if (encoded.isEmpty) return [];
    return encoded.split('‖');
  }
}
