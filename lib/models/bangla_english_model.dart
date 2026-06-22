import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BanglaEnglishExercise {
  final String bangla;
  final String english;
  final String grammarFocus;
  final List<String> rules;
  final String hint;

  BanglaEnglishExercise({
    required this.bangla,
    required this.english,
    this.grammarFocus = '',
    this.rules = const [],
    this.hint = '',
  });

  factory BanglaEnglishExercise.fromJson(Map<String, dynamic> j) =>
      BanglaEnglishExercise(
        bangla: j['bangla'] ?? '',
        english: j['english'] ?? '',
        grammarFocus: j['grammar_focus'] ?? '',
        rules: (j['rules'] as List<dynamic>?)?.cast<String>() ?? [],
        hint: j['hint'] ?? '',
      );
}

class BanglaEnglishCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  List<BanglaEnglishExercise> exercises;

  BanglaEnglishCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.exercises = const [],
  });

  factory BanglaEnglishCategory.fromJson(Map<String, dynamic> j) {
    final iconMap = <String, IconData>{
      'check_circle': Icons.check_circle_rounded,
      'timelapse': Icons.timelapse_rounded,
      'done_all': Icons.done_all_rounded,
      'history': Icons.history_rounded,
      'hourglass_top': Icons.hourglass_top_rounded,
      'timeline': Icons.timeline_rounded,
      'trending_up': Icons.trending_up_rounded,
      'article': Icons.article_rounded,
      'linear_scale': Icons.linear_scale_rounded,
      'handyman': Icons.handyman_rounded,
      'call_split': Icons.call_split_rounded,
      'swap_horiz': Icons.swap_horiz_rounded,
      'help_outline': Icons.help_outline_rounded,
      'menu_book': Icons.menu_book_rounded,
    };
    return BanglaEnglishCategory(
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

  static Future<List<BanglaEnglishCategory>> loadAll() async {
    final raw =
        await rootBundle.loadString('assets/json/bangla_to_english/categories.json');
    final list = jsonDecode(raw) as List<dynamic>;

    final categories = list
        .map((e) => BanglaEnglishCategory.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final cat in categories) {
      try {
        final exRaw = await rootBundle
            .loadString('assets/json/bangla_to_english/${cat.id}.json');
        final exList = jsonDecode(exRaw) as List<dynamic>;
        cat.exercises = exList
            .map((e) => BanglaEnglishExercise.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        cat.exercises = [];
      }
    }

    return categories.where((c) => c.exercises.isNotEmpty).toList();
  }
}
