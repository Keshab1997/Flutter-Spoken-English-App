import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_model.dart';

final lessonProvider = StateNotifierProvider<LessonNotifier, AsyncValue<List<LessonModel>>>((ref) {
  return LessonNotifier();
});

final lessonsByLevelProvider = Provider.family<AsyncValue<List<LessonModel>>, String>((ref, level) {
  final lessons = ref.watch(lessonProvider);
  return lessons.when(
    data: (list) => AsyncValue.data(list.where((l) => l.level == level).toList()),
    error: (e, s) => AsyncValue.error(e, s),
    loading: () => const AsyncValue.loading(),
  );
});

class LessonNotifier extends StateNotifier<AsyncValue<List<LessonModel>>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LessonNotifier() : super(const AsyncValue.loading()) {
    fetchLessons();
  }

  Future<void> fetchLessons() async {
    try {
      final snapshot = await _firestore.collection('lessons').orderBy('title').get();
      final lessons = snapshot.docs.map((doc) =>
        LessonModel.fromMap(doc.data(), doc.id)
      ).toList();
      state = AsyncValue.data(lessons);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<LessonModel>> getLessonsByLevel(String level) async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .where('level', isEqualTo: level)
          .get();
      return snapshot.docs.map((doc) =>
        LessonModel.fromMap(doc.data(), doc.id)
      ).toList();
    } catch (_) {
      return [];
    }
  }
}
