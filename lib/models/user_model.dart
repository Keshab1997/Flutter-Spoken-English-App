import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime joinedAt;
  final int streak;
  final String currentLevel; // 'Beginner', 'Intermediate', 'Advanced'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    required this.joinedAt,
    this.streak = 0,
    this.currentLevel = 'Beginner',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      streak: map['streak'] ?? 0,
      currentLevel: map['currentLevel'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'streak': streak,
      'currentLevel': currentLevel,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? joinedAt,
    int? streak,
    String? currentLevel,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      joinedAt: joinedAt ?? this.joinedAt,
      streak: streak ?? this.streak,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }
}
