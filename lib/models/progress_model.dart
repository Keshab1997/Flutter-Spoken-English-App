import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String userId;
  final int lessonsCompleted;
  final int quizScore;
  final int speakingScore;
  final int studyTime; // in minutes
  final int streakDays;
  final DateTime lastActiveDate;
  final List<String> completedLessonIds;

  ProgressModel({
    required this.userId,
    this.lessonsCompleted = 0,
    this.quizScore = 0,
    this.speakingScore = 0,
    this.studyTime = 0,
    this.streakDays = 0,
    required this.lastActiveDate,
    this.completedLessonIds = const [],
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map, String userId) {
    return ProgressModel(
      userId: userId,
      lessonsCompleted: map['lessonsCompleted'] ?? 0,
      quizScore: map['quizScore'] ?? 0,
      speakingScore: map['speakingScore'] ?? 0,
      studyTime: map['studyTime'] ?? 0,
      streakDays: map['streakDays'] ?? 0,
      lastActiveDate: (map['lastActiveDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedLessonIds: List<String>.from(map['completedLessonIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonsCompleted': lessonsCompleted,
      'quizScore': quizScore,
      'speakingScore': speakingScore,
      'studyTime': studyTime,
      'streakDays': streakDays,
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'completedLessonIds': completedLessonIds,
    };
  }
}
