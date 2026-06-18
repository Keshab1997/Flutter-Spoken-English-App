import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  bool _isPlaying = false;
  double _speed = 1.0;
  int _selectedTrack = 0;

  final tracks = [
    {'title': 'A Day at the Market', 'duration': '1:30', 'level': 'Beginner'},
    {'title': 'Ordering Coffee', 'duration': '1:15', 'level': 'Beginner'},
    {'title': 'Talking About Hobbies', 'duration': '2:00', 'level': 'Intermediate'},
    {'title': 'Job Interview Conversation', 'duration': '2:30', 'level': 'Intermediate'},
    {'title': 'News Report Summary', 'duration': '3:00', 'level': 'Advanced'},
  ];

  final questions = [
    {'q': 'What is the man buying?', 'options': ['Vegetables', 'Fruits', 'Fish', 'Rice'], 'answer': 0},
    {'q': 'How much does he pay?', 'options': ['100 Taka', '200 Taka', '150 Taka', '250 Taka'], 'answer': 1},
  ];

  int? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final track = tracks[_selectedTrack];

    return Scaffold(
      appBar: AppBar(title: const Text('Listening Practice', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.infoGradient),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.headphones_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(track['title']!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${track['duration']!}  •  ${track['level']!}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          onPressed: () => setState(() => _isPlaying = !_isPlaying),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Speed:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 8),
                      ...['0.5x', '1.0x', '1.5x', '2.0x'].map((s) {
                        final isSelected = _speed.toString() == s.replaceAll('x', '');
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(s, style: const TextStyle(fontSize: 11)),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _speed = double.parse(s.replaceAll('x', ''))),
                            selectedColor: Colors.white,
                            labelStyle: TextStyle(color: isSelected ? AppColors.primary : Colors.white, fontWeight: FontWeight.bold),
                            backgroundColor: Colors.white.withOpacity(0.2),
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Track List', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedTrack == index;
                  final t = tracks[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTrack = index),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t['title']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('${t['duration']!}  •  ${t['level']!}', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text('Comprehension Questions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...questions.asMap().entries.map((entry) {
              final idx = entry.key;
              final q = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Q${idx + 1}: ${q['q']}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    ...(q['options'] as List<String>).asMap().entries.map((opt) {
                      final optIdx = opt.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () => setState(() => _selectedAnswer = optIdx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedAnswer == optIdx
                                  ? AppColors.primary.withOpacity(0.1)
                                  : (isDark ? Colors.grey[850] : Colors.grey[50]),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedAnswer == optIdx ? AppColors.primary : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedAnswer == optIdx ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: _selectedAnswer == optIdx ? AppColors.primary : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(opt.value, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
