import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game/game_question_model.dart';

class GameRepository {
  static const String _boxName = 'game_cache';
  static const String _questionsKey = 'cached_questions';
  static const String _legacyJsonPath = 'assets/json/game/game_questions.json';
  static const String _firestoreCollection = 'game_questions';

  /// Per-tense question files. Each file has shape:
  /// `{ "tenseType": "...", "questions": [ ... ] }`.
  /// New content is authored here (see assets/json/game/CONTENT_GUIDE.md).
  static const List<String> _tenseQuestionFiles = [
    'assets/json/game/questions/01_present_indefinite.json',
    'assets/json/game/questions/02_present_continuous.json',
    'assets/json/game/questions/03_present_perfect.json',
    'assets/json/game/questions/04_present_perfect_continuous.json',
    'assets/json/game/questions/05_past_indefinite.json',
    'assets/json/game/questions/06_past_continuous.json',
    'assets/json/game/questions/07_past_perfect.json',
    'assets/json/game/questions/08_past_perfect_continuous.json',
    'assets/json/game/questions/09_future_indefinite.json',
    'assets/json/game/questions/10_future_continuous.json',
    'assets/json/game/questions/11_future_perfect.json',
    'assets/json/game/questions/12_future_perfect_continuous.json',
  ];

  // ── JSON (Asset) ──

  /// Loads questions from all per-tense files and merges them.
  /// Falls back to the legacy single-file path if no per-tense files
  /// contain questions.
  Future<List<GameQuestionModel>> loadFromJson() async {
    final List<GameQuestionModel> all = [];

    for (final path in _tenseQuestionFiles) {
      try {
        final jsonString = await rootBundle.loadString(path);
        final data = json.decode(jsonString) as Map<String, dynamic>;
        final questionsList = data['questions'] as List<dynamic>? ?? [];
        all.addAll(
          questionsList.map(
            (q) => GameQuestionModel.fromMap(q as Map<String, dynamic>, ''),
          ),
        );
      } catch (_) {
        // File missing or invalid — skip silently and continue.
      }
    }

    // Legacy fallback: if per-tense files yielded nothing, try the old path.
    if (all.isEmpty) {
      try {
        final jsonString = await rootBundle.loadString(_legacyJsonPath);
        final data = json.decode(jsonString) as Map<String, dynamic>;
        final questionsList = data['questions'] as List<dynamic>? ?? [];
        return questionsList
            .map((q) => GameQuestionModel.fromMap(q as Map<String, dynamic>, ''))
            .toList();
      } catch (_) {
        return [];
      }
    }

    return all;
  }

  // ── Hive (Local Cache) ──

  Future<Box> _ensureBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> cacheQuestions(List<GameQuestionModel> questions) async {
    final box = await _ensureBox();
    final maps = questions.map((q) => q.toMap()).toList();
    await box.put(_questionsKey, maps);
  }

  List<GameQuestionModel> getCachedQuestions() {
    if (!Hive.isBoxOpen(_boxName)) return [];
    final box = Hive.box(_boxName);
    final raw = box.get(_questionsKey, defaultValue: <Map<String, dynamic>>[]) as List;
    return raw
        .map((e) => GameQuestionModel.fromMap(Map<String, dynamic>.from(e as Map), ''))
        .toList();
  }

  Future<void> clearCache() async {
    final box = await _ensureBox();
    await box.delete(_questionsKey);
  }

  // ── Firestore (Remote) ──

  Future<List<GameQuestionModel>> fetchFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(_firestoreCollection)
        .get();
    return snapshot.docs
        .map((doc) => GameQuestionModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> uploadToFirestore(GameQuestionModel question) async {
    await FirebaseFirestore.instance
        .collection(_firestoreCollection)
        .doc(question.id)
        .set(question.toMap());
  }

  Future<void> batchUploadToFirestore(List<GameQuestionModel> questions) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final question in questions) {
      final ref = FirebaseFirestore.instance
          .collection(_firestoreCollection)
          .doc(question.id);
      batch.set(ref, question.toMap());
    }
    await batch.commit();
  }

  Future<void> deleteFromFirestore(String questionId) async {
    await FirebaseFirestore.instance
        .collection(_firestoreCollection)
        .doc(questionId)
        .delete();
  }

  // ── Sync (JSON → Hive → Firestore) ──

  Future<void> syncFromJsonToHive() async {
    final questions = await loadFromJson();
    await cacheQuestions(questions);
  }

  Future<void> syncFromFirestoreToHive() async {
    final questions = await fetchFromFirestore();
    await cacheQuestions(questions);
  }
}