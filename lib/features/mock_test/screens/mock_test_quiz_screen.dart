import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/mock_test_model.dart';
import '../../../providers/mock_test_provider.dart';
import 'mock_test_result_screen.dart';

class MockTestQuizScreen extends ConsumerStatefulWidget {
  final int testNumber;
  final String testTitle;

  const MockTestQuizScreen({
    super.key,
    required this.testNumber,
    required this.testTitle,
  });

  @override
  ConsumerState<MockTestQuizScreen> createState() => _MockTestQuizScreenState();
}

class _MockTestQuizScreenState extends ConsumerState<MockTestQuizScreen> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  final Map<int, int> _answers = {};
  bool _isSubmitting = false;

  MockTestModel? get _test {
    final tests = ref.read(mockTestListProvider);
    try {
      return tests.firstWhere((t) => t.testNumber == widget.testNumber);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final test = _test;
    if (test == null || test.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.testTitle)),
        body: const Center(child: Text('Test questions not available.')),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final questions = test.questions;
    final question = questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _isSubmitting
              ? null
              : () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Leave Test?'),
                      content: const Text('Your progress in this attempt will be lost.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continue Test')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: const Text('Leave', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
      body: Column(
        children: [
          // ── Progress Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestion + 1}/${questions.length}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54),
                    ),
                    Text(
                      '${_answers.length} answered',
                      style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    color: AppColors.primary,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),

          // ── Question ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Q${_currentQuestion + 1}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Question text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.primaryGradient),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      question.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...question.options.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedAnswer == idx;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: _isSubmitting ? null : () => setState(() => _selectedAnswer = idx),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + idx),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  option,
                                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Bottom Navigation ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                // Skip / Previous
                if (_currentQuestion > 0)
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_selectedAnswer != null) {
                              _answers[_currentQuestion] = _selectedAnswer!;
                            }
                            setState(() {
                              _currentQuestion--;
                              _selectedAnswer = _answers[_currentQuestion];
                            });
                          },
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),

                const Spacer(),

                // Next / Submit
                SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _selectedAnswer != null && !_isSubmitting
                        ? () {
                            _answers[_currentQuestion] = _selectedAnswer!;
                            if (_currentQuestion < questions.length - 1) {
                              setState(() {
                                _currentQuestion++;
                                _selectedAnswer = _answers[_currentQuestion];
                              });
                            } else {
                              _submitQuiz();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _currentQuestion < questions.length - 1 ? 'Next' : 'Submit',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitQuiz() {
    setState(() => _isSubmitting = true);

    final test = _test!;
    int correct = 0;
    for (final entry in _answers.entries) {
      if (entry.value == test.questions[entry.key].correctIndex) {
        correct++;
      }
    }

    // Save result
    ref.read(mockTestProvider.notifier).saveResult(widget.testNumber, correct);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MockTestResultScreen(
          testNumber: widget.testNumber,
          testTitle: widget.testTitle,
          score: correct,
          total: test.questions.length,
          questions: test.questions,
          answers: _answers,
        ),
      ),
    );
  }
}
