import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/chapter_vocabulary_provider.dart';
import 'chapter_words_screen.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  static const _levelOrder = ['Beginner', 'Intermediate', 'Advanced'];
  static const _levelEmojis = {
    'Beginner': '🌱',
    'Intermediate': '📖',
    'Advanced': '🚀',
  };
  static const _levelColors = {
    'Beginner': AppColors.primary,
    'Intermediate': Color(0xFF7C3AED),
    'Advanced': Color(0xFFEA580C),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chaptersAsync = ref.watch(chaptersByLevelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: chaptersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (byLevel) {
          if (byLevel.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No chapters found.\nAdd chapter JSON files to\nassets/json/vocabulary/',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              for (final level in _levelOrder)
                if (byLevel.containsKey(level)) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 10),
                    child: Row(
                      children: [
                        Text(_levelEmojis[level]!,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          level,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: _levelColors[level],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${byLevel[level]!.length} chapters',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  for (final chapter in byLevel[level]!)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: (_levelColors[level] ?? AppColors.primary)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${chapter.chapter}',
                              style: TextStyle(
                                color:
                                    _levelColors[level] ?? AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(chapter.title,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${chapter.words.length} words',
                            style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: Colors.grey),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ChapterWordsScreen(chapter: chapter)),
                        ),
                      ),
                    ),
                  const Divider(height: 8),
                ],
            ],
          );
        },
      ),
    );
  }
}
