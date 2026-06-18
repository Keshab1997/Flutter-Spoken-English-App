import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/vocabulary_chapter_model.dart';

class ChapterWordsScreen extends StatelessWidget {
  final VocabularyChapter chapter;
  const ChapterWordsScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chapter ${chapter.chapter}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(chapter.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chapter.words.length,
        itemBuilder: (context, index) {
          final w = chapter.words[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    w.word[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
              title:
                  Text(w.word, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (w.pronunciation.isNotEmpty)
                    Text(w.pronunciation,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                            fontSize: 12)),
                  Text(
                    w.banglaMeaning.isNotEmpty ? w.banglaMeaning : w.meaning,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              onTap: () => _showDetail(context, w, theme),
            ),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, ChapterWord w, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(w.word,
                  style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900, color: AppColors.primary)),
            ),
            if (w.pronunciation.isNotEmpty)
              Center(
                child: Text(w.pronunciation,
                    style: const TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
            const SizedBox(height: 20),
            _tile('Meaning', w.meaning, AppColors.primary),
            const SizedBox(height: 10),
            _tile('বাংলা অর্থ', w.banglaMeaning, AppColors.secondary),
            const SizedBox(height: 10),
            _tile('Example', w.exampleSentence, AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value, Color color) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
