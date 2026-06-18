import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/grammar_chapter_model.dart';

class GrammarDetailScreen extends StatelessWidget {
  final GrammarChapter chapter;

  const GrammarDetailScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (chapter.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                chapter.banglaDescription.isNotEmpty
                    ? chapter.banglaDescription
                    : chapter.description,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.grey[600], height: 1.5),
              ),
            ),
          ...chapter.topics.map((topic) => _TopicCard(topic: topic)),
          if (chapter.commonMistakes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _CommonMistakesSection(mistakes: chapter.commonMistakes),
          ],
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final GrammarTopic topic;
  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(topic.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              if (topic.banglaName.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(topic.banglaName,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ),
            ],
          ),
          if (topic.definition.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(topic.definition,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(height: 1.5, fontWeight: FontWeight.w500)),
          ],
          if (topic.banglaDefinition.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(topic.banglaDefinition,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey[700], height: 1.5)),
            ),
          ],
          if (topic.formula.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.accent.withOpacity(0.2)),
              ),
              child: Text(topic.formula,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent)),
            ),
          ],
          if (topic.rules.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...topic.rules.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2, right: 10),
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${e.key + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Expanded(
                        child: Text(e.value,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.4)),
                      ),
                    ],
                  ),
                )),
          ],
          if (topic.examples.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('Examples:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey)),
            const SizedBox(height: 8),
            ...topic.examples.map((ex) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.en,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic)),
                      const SizedBox(height: 4),
                      Text(ex.bn,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                )),
          ],
          if (topic.tips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.blue.withOpacity(0.2)),
              ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(topic.tips,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommonMistakesSection extends StatelessWidget {
  final List<GrammarMistake> mistakes;
  const _CommonMistakesSection({required this.mistakes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
              const SizedBox(width: 8),
              Text('Common Mistakes',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          ...mistakes.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.close_rounded, color: Colors.red, size: 18),
                        const SizedBox(width: 6),
                        Text(m.wrong,
                            style: const TextStyle(
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Text(m.correct,
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (m.explanation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(m.explanation,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600])),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
