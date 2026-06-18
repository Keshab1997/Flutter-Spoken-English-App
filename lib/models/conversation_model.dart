class ConversationModel {
  final String id;
  final String title;
  final String category; // 'Daily', 'Restaurant', 'Interview', 'Office', 'Travel'
  final List<DialogueModel> dialogues;

  ConversationModel({
    required this.id,
    required this.title,
    required this.category,
    this.dialogues = const [],
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String docId) {
    return ConversationModel(
      id: docId,
      title: map['title'] ?? '',
      category: map['category'] ?? 'Daily',
      dialogues: (map['dialogues'] as List? ?? [])
          .map((d) => DialogueModel.fromMap(d))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'dialogues': dialogues.map((d) => d.toMap()).toList(),
    };
  }
}

class DialogueModel {
  final String speaker; // 'Person A', 'Person B'
  final String englishText;
  final String banglaTranslation;
  final String? audioUrl;

  DialogueModel({
    required this.speaker,
    required this.englishText,
    required this.banglaTranslation,
    this.audioUrl,
  });

  factory DialogueModel.fromMap(Map<String, dynamic> map) {
    return DialogueModel(
      speaker: map['speaker'] ?? '',
      englishText: map['englishText'] ?? '',
      banglaTranslation: map['banglaTranslation'] ?? '',
      audioUrl: map['audioUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speaker': speaker,
      'englishText': englishText,
      'banglaTranslation': banglaTranslation,
      'audioUrl': audioUrl,
    };
  }
}
