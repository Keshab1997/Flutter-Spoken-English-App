import 'package:flutter/material.dart';

/// Model for the entire guide (Student Guide or Study Routine)
class GuideData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<GuideSection> sections;

  GuideData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sections,
  });

  factory GuideData.fromJson(Map<String, dynamic> json, {IconData? iconOverride}) {
    final iconName = json['icon'] as String? ?? 'school';
    final icon = iconOverride ??
        (iconName == 'calendar'
            ? Icons.calendar_today_rounded
            : Icons.school_rounded);

    return GuideData(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      icon: icon,
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => GuideSection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// A section/part of a guide, which may contain text, bullets, subsections, or a table
class GuideSection {
  final String title;
  final String? content;
  final List<String>? bullets;
  final List<GuideSubSection>? subsections;
  final GuideTable? table;
  final String? note;
  final String? footer;

  GuideSection({
    required this.title,
    this.content,
    this.bullets,
    this.subsections,
    this.table,
    this.note,
    this.footer,
  });

  factory GuideSection.fromJson(Map<String, dynamic> json) {
    return GuideSection(
      title: json['title'] as String? ?? '',
      content: json['content'] as String?,
      bullets: (json['bullets'] as List<dynamic>?)
          ?.map((b) => b.toString())
          .toList(),
      subsections: (json['subsections'] as List<dynamic>?)
          ?.map((s) => GuideSubSection.fromJson(s as Map<String, dynamic>))
          .toList(),
      table: json['table'] != null
          ? GuideTable.fromJson(json['table'] as Map<String, dynamic>)
          : null,
      note: json['note'] as String?,
      footer: json['footer'] as String?,
    );
  }
}

/// A sub-section within a section
class GuideSubSection {
  final String title;
  final String? content;
  final List<String>? bullets;

  GuideSubSection({
    required this.title,
    this.content,
    this.bullets,
  });

  factory GuideSubSection.fromJson(Map<String, dynamic> json) {
    return GuideSubSection(
      title: json['title'] as String? ?? '',
      content: json['content'] as String?,
      bullets: (json['bullets'] as List<dynamic>?)
          ?.map((b) => b.toString())
          .toList(),
    );
  }
}

/// A table structure (like the weekly chart)
class GuideTable {
  final List<String> headers;
  final List<List<String>> rows;

  GuideTable({
    required this.headers,
    required this.rows,
  });

  factory GuideTable.fromJson(Map<String, dynamic> json) {
    return GuideTable(
      headers: (json['headers'] as List<dynamic>?)
              ?.map((h) => h.toString())
              .toList() ??
          [],
      rows: (json['rows'] as List<dynamic>?)
              ?.map((r) =>
                  (r as List<dynamic>).map((c) => c.toString()).toList())
              .toList() ??
          [],
    );
  }
}
