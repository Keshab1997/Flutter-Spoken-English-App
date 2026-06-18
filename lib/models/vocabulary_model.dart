class VocabularyModel {
  final String id;
  final String word;
  final String meaning;
  final String pronunciation;
  final String exampleSentence;
  final String banglaMeaning;
  final String category;
  final bool isFavorite;

  VocabularyModel({
    required this.id,
    required this.word,
    required this.meaning,
    required this.pronunciation,
    required this.exampleSentence,
    this.banglaMeaning = '',
    this.category = 'General',
    this.isFavorite = false,
  });

  factory VocabularyModel.fromMap(Map<String, dynamic> map, String docId) {
    return VocabularyModel(
      id: docId,
      word: map['word'] ?? '',
      meaning: map['meaning'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
      exampleSentence: map['exampleSentence'] ?? '',
      banglaMeaning: map['banglaMeaning'] ?? '',
      category: map['category'] ?? 'General',
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'meaning': meaning,
      'pronunciation': pronunciation,
      'exampleSentence': exampleSentence,
      'banglaMeaning': banglaMeaning,
      'category': category,
      'isFavorite': isFavorite,
    };
  }

  VocabularyModel copyWith({String? id, bool? isFavorite}) {
    return VocabularyModel(
      id: id ?? this.id,
      word: word,
      meaning: meaning,
      pronunciation: pronunciation,
      exampleSentence: exampleSentence,
      banglaMeaning: banglaMeaning,
      category: category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
