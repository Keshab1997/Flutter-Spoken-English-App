import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocabulary_model.dart';

final vocabularyProvider = StateNotifierProvider<VocabularyNotifier, AsyncValue<List<VocabularyModel>>>((ref) {
  return VocabularyNotifier();
});

class VocabularyNotifier extends StateNotifier<AsyncValue<List<VocabularyModel>>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VocabularyNotifier() : super(const AsyncValue.loading()) {
    fetchVocabulary();
  }

  Future<void> fetchVocabulary() async {
    try {
      final snapshot = await _firestore.collection('vocabulary').orderBy('word').get();
      final words = snapshot.docs.map((doc) =>
        VocabularyModel.fromMap(doc.data(), doc.id)
      ).toList();
      state = AsyncValue.data(words);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleFavorite(String wordId, bool current) async {
    try {
      await _firestore.collection('vocabulary').doc(wordId).update({
        'isFavorite': !current,
      });
      await fetchVocabulary();
    } catch (_) {}
  }

  List<VocabularyModel> searchWords(String query) {
    final currentData = state.asData?.value ?? [];
    if (query.isEmpty) return currentData;
    return currentData.where((w) =>
      w.word.toLowerCase().contains(query.toLowerCase()) ||
      w.meaning.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
