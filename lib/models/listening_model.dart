import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ListeningSentence {
  final String bangla;
  final String english;
  final String grammarFocus;
  final List<String> rules;
  final String hint;

  ListeningSentence({
    required this.bangla,
    required this.english,
    this.grammarFocus = '',
    this.rules = const [],
    this.hint = '',
  });

  factory ListeningSentence.fromJson(Map<String, dynamic> j) =>
      ListeningSentence(
        bangla: j['bangla'] ?? '',
        english: j['english'] ?? '',
        grammarFocus: j['grammar_focus'] ?? '',
        rules: (j['rules'] as List<dynamic>?)?.cast<String>() ?? [],
        hint: j['hint'] ?? '',
      );
}

class ListeningStory {
  final String id;
  final String title;
  final String level;
  final List<ListeningSentence> sentences;

  ListeningStory({
    required this.id,
    required this.title,
    required this.level,
    this.sentences = const [],
  });

  factory ListeningStory.fromJson(Map<String, dynamic> j) => ListeningStory(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        level: j['level'] ?? '',
        sentences: (j['sentences'] as List<dynamic>?)
                ?.map((s) =>
                    ListeningSentence.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class ListeningCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  List<ListeningStory> stories;

  ListeningCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.stories = const [],
  });

  factory ListeningCategory.fromJson(Map<String, dynamic> j) {
    final iconMap = <String, IconData>{
      'star': Icons.star_rounded,
      'trending_up': Icons.trending_up_rounded,
      'psychology': Icons.psychology_rounded,
      'child_care': Icons.child_care,
      'forum': Icons.forum,
      'auto_stories': Icons.auto_stories,
      'business_center': Icons.business_center,
      'flight_takeoff': Icons.flight_takeoff,
      'school': Icons.school,
      'newspaper': Icons.newspaper,
    };
    return ListeningCategory(
      id: j['id'] ?? '',
      title: j['title'] ?? '',
      subtitle: j['subtitle'] ?? '',
      icon: iconMap[j['icon']] ?? Icons.book_rounded,
      color: _parseColor(j['color'] as String? ?? '#2563EB'),
    );
  }

  static Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  static Future<List<ListeningCategory>> loadAll() async {
    final raw = await rootBundle
        .loadString('assets/json/listening_practice/categories.json');
    final list = jsonDecode(raw) as List<dynamic>;

    final categories = list
        .map((e) => ListeningCategory.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final cat in categories) {
      try {
        final storiesRaw = await rootBundle
            .loadString('assets/json/listening_practice/${cat.id}.json');
        final storiesList = jsonDecode(storiesRaw) as List<dynamic>;
        cat.stories = storiesList
            .map((s) => ListeningStory.fromJson(s as Map<String, dynamic>))
            .toList();
      } catch (_) {
        cat.stories = [];
      }
    }

    return categories.where((c) => c.stories.isNotEmpty).toList();
  }
}
