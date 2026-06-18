import 'dart:convert';
import 'package:flutter/services.dart';

class ChapterWord {
  final String word;
  final String pronunciation;
  final String meaning;
  final String banglaMeaning;
  final String exampleSentence;

  const ChapterWord({
    required this.word,
    required this.pronunciation,
    required this.meaning,
    required this.banglaMeaning,
    required this.exampleSentence,
  });

  factory ChapterWord.fromJson(Map<String, dynamic> j) => ChapterWord(
        word: j['word'] ?? '',
        pronunciation: j['pronunciation'] ?? '',
        meaning: j['meaning'] ?? '',
        banglaMeaning: j['banglaMeaning'] ?? '',
        exampleSentence: j['exampleSentence'] ?? '',
      );
}

class VocabularyChapter {
  final int chapter;
  final String title;
  final String level;
  final List<ChapterWord> words;

  const VocabularyChapter({
    required this.chapter,
    required this.title,
    required this.level,
    required this.words,
  });

  factory VocabularyChapter.fromJson(Map<String, dynamic> j) => VocabularyChapter(
        chapter: j['chapter'] ?? 0,
        title: j['title'] ?? '',
        level: j['level'] ?? 'Beginner',
        words: (j['words'] as List<dynamic>? ?? [])
            .map((w) => ChapterWord.fromJson(w as Map<String, dynamic>))
            .toList(),
      );

  static Future<VocabularyChapter> loadAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return VocabularyChapter.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
