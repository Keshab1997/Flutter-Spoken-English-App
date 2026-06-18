import 'dart:convert';
import 'package:flutter/services.dart';

class GrammarExample {
  final String en;
  final String bn;

  const GrammarExample({required this.en, required this.bn});

  factory GrammarExample.fromJson(Map<String, dynamic> j) => GrammarExample(
        en: j['en'] ?? '',
        bn: j['bn'] ?? '',
      );
}

class GrammarMistake {
  final String wrong;
  final String correct;
  final String explanation;

  const GrammarMistake({
    required this.wrong,
    required this.correct,
    required this.explanation,
  });

  factory GrammarMistake.fromJson(Map<String, dynamic> j) => GrammarMistake(
        wrong: j['wrong'] ?? '',
        correct: j['correct'] ?? '',
        explanation: j['explanation'] ?? '',
      );
}

class GrammarTopic {
  final String name;
  final String banglaName;
  final String definition;
  final String banglaDefinition;
  final String formula;
  final List<String> rules;
  final List<GrammarExample> examples;
  final String tips;

  const GrammarTopic({
    required this.name,
    required this.banglaName,
    required this.definition,
    required this.banglaDefinition,
    this.formula = '',
    this.rules = const [],
    this.examples = const [],
    this.tips = '',
  });

  factory GrammarTopic.fromJson(Map<String, dynamic> j) => GrammarTopic(
        name: j['name'] ?? '',
        banglaName: j['banglaName'] ?? '',
        definition: j['definition'] ?? '',
        banglaDefinition: j['banglaDefinition'] ?? '',
        formula: j['formula'] ?? '',
        rules: (j['rules'] as List<dynamic>?)?.cast<String>() ?? [],
        examples: (j['examples'] as List<dynamic>?)
                ?.map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        tips: j['tips'] ?? '',
      );
}

class GrammarChapter {
  final int chapter;
  final String level;
  final String title;
  final String icon;
  final String description;
  final String banglaDescription;
  final List<GrammarTopic> topics;
  final List<GrammarMistake> commonMistakes;

  const GrammarChapter({
    required this.chapter,
    required this.level,
    required this.title,
    this.icon = 'abc',
    this.description = '',
    this.banglaDescription = '',
    this.topics = const [],
    this.commonMistakes = const [],
  });

  factory GrammarChapter.fromJson(Map<String, dynamic> j) => GrammarChapter(
        chapter: j['chapter'] ?? 0,
        level: j['level'] ?? 'Beginner',
        title: j['title'] ?? '',
        icon: j['icon'] ?? 'abc',
        description: j['description'] ?? '',
        banglaDescription: j['banglaDescription'] ?? '',
        topics: (j['topics'] as List<dynamic>?)
                ?.map((t) => GrammarTopic.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [],
        commonMistakes: (j['commonMistakes'] as List<dynamic>?)
                ?.map((m) => GrammarMistake.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
      );

  static Future<GrammarChapter> loadAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return GrammarChapter.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
