import 'dart:convert';

class SentenceAnalysis {
  final String banglaSentence;
  final String tense;
  final String subject;
  final String object;
  final String wordBreakdown;
  final String englishTranslation;
  final String explanation;

  SentenceAnalysis({
    required this.banglaSentence,
    required this.tense,
    required this.subject,
    required this.object,
    required this.wordBreakdown,
    required this.englishTranslation,
    required this.explanation,
  });

  factory SentenceAnalysis.fromJson(Map<String, dynamic> json) {
    return SentenceAnalysis(
      banglaSentence: _readString(json['banglaSentence'] ?? json['sentence'] ?? json['bangla']),
      tense: _readString(json['tense']),
      subject: _readString(json['subject']),
      object: _normalizeObject(_readString(json['object'])),
      wordBreakdown: _readString(json['wordBreakdown'] ?? json['breakdown'] ?? json['words']),
      englishTranslation: _readString(json['englishTranslation'] ?? json['translation'] ?? json['english']),
      explanation: _readString(json['explanation'] ?? json['banglaExplanation']),
    );
  }

  bool get isValid =>
      banglaSentence.trim().isNotEmpty &&
      tense.trim().isNotEmpty &&
      subject.trim().isNotEmpty &&
      explanation.trim().isNotEmpty;
}

class PracticeTask {
  final String instruction;
  final String correctAnswer;

  PracticeTask({
    required this.instruction,
    required this.correctAnswer,
  });

  factory PracticeTask.fromJson(Map<String, dynamic> json) {
    return PracticeTask(
      instruction: _readString(json['instruction'] ?? json['question'] ?? json['task']),
      correctAnswer: _readString(json['correctAnswer'] ?? json['answer'] ?? json['expectedAnswer']),
    );
  }

  bool get isValid => instruction.trim().isNotEmpty && correctAnswer.trim().isNotEmpty;
}

class AnswerReview {
  final bool isCorrect;
  final String feedback;

  AnswerReview({
    required this.isCorrect,
    required this.feedback,
  });

  factory AnswerReview.fromJson(Map<String, dynamic> json) {
    return AnswerReview(
      isCorrect: _readBool(json['isCorrect'] ?? json['correct'] ?? json['result']),
      feedback: _readString(json['feedback'] ?? json['comment'] ?? json['explanation']),
    );
  }
}

enum AnalyzerStep { topic, analyzing, explanation, generatingTask, practicing, reviewing, completed }

String _readString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is num || value is bool) return value.toString();
  if (value is List) {
    return value.map(_readString).where((e) => e.trim().isNotEmpty).join('\n');
  }
  if (value is Map) {
    return value.entries
        .map((entry) => '${entry.key}: ${_readString(entry.value)}')
        .where((line) => line.trim().isNotEmpty)
        .join('\n');
  }
  try {
    return jsonEncode(value);
  } catch (_) {
    return value.toString().trim();
  }
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.trim().toLowerCase();
    return lower == 'true' || lower == 'yes' || lower == 'correct' || lower == 'সঠিক';
  }
  return false;
}

String _normalizeObject(String value) {
  final lower = value.trim().toLowerCase();
  if (lower.isEmpty ||
      lower == 'none' ||
      lower == 'no object' ||
      lower == 'n/a' ||
      lower == 'null' ||
      lower == 'অকর্মক' ||
      lower.contains('no object')) {
    return '';
  }
  return value.trim();
}
