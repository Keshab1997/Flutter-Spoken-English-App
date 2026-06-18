import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';

final quizProvider = StateNotifierProvider<QuizNotifier, AsyncValue<List<QuizModel>>>((ref) {
  return QuizNotifier();
});

class QuizNotifier extends StateNotifier<AsyncValue<List<QuizModel>>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  QuizNotifier() : super(const AsyncValue.loading()) {
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    try {
      final snapshot = await _firestore.collection('quizzes').get();
      final quizzes = snapshot.docs.map((doc) =>
        QuizModel.fromMap(doc.data(), doc.id)
      ).toList();
      state = AsyncValue.data(quizzes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
