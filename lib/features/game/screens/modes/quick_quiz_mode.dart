import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/game/xp_provider.dart';
import '../../../../providers/game/coin_provider.dart';
import '../../../../providers/game/streak_provider.dart';
import '../../../../providers/game/achievement_provider.dart';
import '../../../../services/tts_service.dart';
import '../../../../repositories/statistics_repository.dart';
import '../../../../models/game/game_result_model.dart';
import '../../../../providers/game/game_provider.dart';
import '../result_screen.dart';

class _WordEntry {
  final String bn;
  final String en;
  _WordEntry({required this.bn, required this.en});
}

class _Question {
  final String banglaWord;
  final String correctEnglish;
  final List<String> options;
  _Question({
    required this.banglaWord,
    required this.correctEnglish,
    required this.options,
  });
}

class QuickQuizModeScreen extends ConsumerStatefulWidget {
  const QuickQuizModeScreen({super.key});

  @override
  ConsumerState<QuickQuizModeScreen> createState() => _QuickQuizModeScreenState();
}

class _QuickQuizModeScreenState extends ConsumerState<QuickQuizModeScreen>
    with TickerProviderStateMixin {
  final TtsService _tts = TtsService();

  List<_Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _streak = 0;
  int _bestStreak = 0;
  String _selectedAnswer = '';
  bool _isAnswered = false;
  bool _isGameOver = false;
  int _timeLeft = 10;
  Timer? _questionTimer;
  Timer? _autoAdvanceTimer;
  int _totalQuestions = 10;
  final Set<int> _usedIndices = {};
  Map<int, String> _userAnswers = {};

  // Animations
  late AnimationController _timerAnimCtrl;
  late Animation<double> _timerAnim;
  late AnimationController _scoreAnimCtrl;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _timerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _timerAnim = Tween(begin: 0.0, end: 1.0).animate(_timerAnimCtrl);
    _scoreAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scoreAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _scoreAnimCtrl, curve: Curves.easeInOut),
    );
    _loadQuestions();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    _timerAnimCtrl.dispose();
    _scoreAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final List<_WordEntry> allEntries = [];

      // Discover chapter files dynamically via AssetManifest
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final vocabPaths = manifest
          .listAssets()
          .where((p) => p.startsWith('assets/json/vocabulary/'))
          .where((p) => p.endsWith('.json'))
          .toList();

      for (final path in vocabPaths) {
        try {
          final chapterStr = await rootBundle.loadString(path);
          final Map<String, dynamic> chapterData =
              json.decode(chapterStr) as Map<String, dynamic>;
          final List<dynamic> words =
              (chapterData['words'] as List?) ?? <dynamic>[];

          for (final w in words) {
            final en = (w['word'] as String?)?.trim() ?? '';
            final bn = (w['banglaMeaning'] as String?)?.trim() ??
                (w['bangla'] as String?)?.trim() ??
                '';
            if (en.isNotEmpty && bn.isNotEmpty) {
              allEntries.add(_WordEntry(en: en, bn: bn));
            }
          }
        } catch (_) {
          // Skip malformed chapter files
        }
      }

      if (allEntries.isEmpty) {
        if (!mounted) return;
        setState(() => _isGameOver = true);
        return;
      }

      if (allEntries.length < _totalQuestions) {
        _totalQuestions = allEntries.length;
      }

      allEntries.shuffle(Random());
      final selectedEntries = allEntries.take(_totalQuestions).toList();

      _questions = selectedEntries.map((entry) {
        // Generate distractors
        final distractors = (allEntries
                .where((e) => e.en != entry.en)
                .toList()
              ..shuffle(Random()))
            .take(3)
            .map((e) => e.en)
            .toList();

        final options = [entry.en, ...distractors]..shuffle(Random());
        return _Question(
          banglaWord: entry.bn,
          correctEnglish: entry.en,
          options: options,
        );
      }).toList();

      if (mounted) setState(() {});
      _startTimer();
      _autoSpeakCurrentWord();
    } catch (e) {
      debugPrint('Error loading questions: $e');
      if (mounted) setState(() => _isGameOver = true);
    }
  }

  void _startTimer() {
    _questionTimer?.cancel();
    _timeLeft = 10;
    _timerAnimCtrl.reset();
    _timerAnimCtrl.forward();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeLeft--;
      });
      if (_timeLeft <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (_isAnswered || _isGameOver) return;
    setState(() {
      _isAnswered = true;
      _wrongCount++;
      _userAnswers[_currentIndex] = '';
    });
    _autoAdvance();
  }

  void _selectAnswer(String answer) {
    if (_isAnswered || _isGameOver) return;
    _questionTimer?.cancel();

    setState(() {
      _isAnswered = true;
      _selectedAnswer = answer;
      _userAnswers[_currentIndex] = answer;

      if (answer == _questions[_currentIndex].correctEnglish) {
        _correctCount++;
        _score += _calculateScore();
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
      } else {
        _wrongCount++;
        _streak = 0;
      }
    });

    _autoAdvance();
  }

  int _calculateScore() {
    return 100 + (_streak > 1 ? (_streak - 1) * 10 : 0) + (_timeLeft * 5);
  }

  void _autoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      if (_currentIndex + 1 < _totalQuestions) {
        setState(() {
          _currentIndex++;
          _isAnswered = false;
          _selectedAnswer = '';
        });
        _startTimer();
        _autoSpeakCurrentWord();
      } else {
        _endGame();
      }
    });
  }

  Future<void> _autoSpeakCurrentWord() async {
    try {
      if (_questions.isNotEmpty && _currentIndex < _questions.length) {
        await _tts.speakBangla(_questions[_currentIndex].banglaWord);
      }
    } catch (_) {
      // Silently fail — TTS is non-critical
    }
  }

  void _endGame() {
    _questionTimer?.cancel();
    _autoAdvanceTimer?.cancel();

    final accuracy = _totalQuestions > 0 ? _correctCount / _totalQuestions : 0.0;

    // Calculate XP and coins
    final xpEarned = (_correctCount * 20) + (_streak * 5);
    final coinsEarned = (_correctCount * 5) + (_streak * 2);

    _saveProgress(xpEarned, coinsEarned, accuracy);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: _score,
          correctAnswers: _correctCount,
          wrongAnswers: _wrongCount,
          earnedXP: xpEarned,
          earnedCoins: coinsEarned,
          gameMode: 'quick_quiz',
        ),
      ),
    );
  }

  Future<void> _saveProgress(int xp, int coins, double accuracy) async {
    try {
      await ref.read(xpProvider.notifier).addXP(xp);
    } catch (_) {}
    try {
      await ref.read(coinProvider.notifier).addCoins(coins);
    } catch (_) {}
    try {
      await ref.read(streakProvider.notifier).checkAndUpdateStreak();
    } catch (_) {}
    try {
      await ref.read(streakProvider.notifier).recordActiveDay();
    } catch (_) {}
    try {
      await ref.read(achievementProvider.notifier).checkGameAchievements(
        score: _score,
        correctAnswers: _correctCount,
        accuracy: accuracy,
      );
    } catch (_) {}
    try {
      final repo = StatisticsRepository();
      await repo.saveResult(GameResultModel(
        earnedXP: xp,
        earnedCoins: coins,
        correctAnswers: _correctCount,
        wrongAnswers: _wrongCount,
        score: _score,
      ));
    } catch (_) {}

    // 🔥 Upload updated streak/progress to Firestore
    try {
      final progressRepo = ref.read(progressRepositoryProvider);
      final gameProgress = progressRepo.getProgress();
      if (gameProgress != null) {
        await progressRepo.uploadProgressToFirestore(gameProgress);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameOver && _questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.orange.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.deepOrange),
                const SizedBox(height: 16),
                const Text(
                  'Could not load quiz data',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please make sure vocabulary data is available and try again.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.orange.shade50,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.deepOrange),
              SizedBox(height: 12),
              Text('Loading quiz...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _totalQuestions;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B35),
              Color(0xFFFF8E53),
              Color(0xFFFFF3E0),
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              _buildHeader(progress),

              // ── Timer bar ──
              _buildTimerBar(),

              const SizedBox(height: 8),

              // ── Question card ──
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Question card
                            _buildQuestionCard(question),
                            const SizedBox(height: 24),
                            // Option buttons
                            _buildOptionList(question),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader(double progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Column(
        children: [
          Row(
            children: [
              // Close button with glass effect
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              // Title
              const Text(
                'Quick Quiz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              // Score badge
              AnimatedBuilder(
                animation: _scoreAnim,
                builder: (_, child) => Transform.scale(
                  scale: _scoreAnim.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade400,
                          Colors.orange.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '$_score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Streak fire
              if (_streak > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: Colors.orange, size: 18),
                      const SizedBox(width: 3),
                      Text(
                        '$_streak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(
                  '${_currentIndex + 1} / $_totalQuestions',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TIMER BAR
  // ─────────────────────────────────────────────
  Widget _buildTimerBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: _timeLeft / 10.0),
        duration: const Duration(milliseconds: 500),
        builder: (_, value, __) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                value < 0.25
                    ? Colors.redAccent
                    : value < 0.5
                        ? Colors.orange
                        : Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // QUESTION CARD
  // ─────────────────────────────────────────────
  Widget _buildQuestionCard(_Question question) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutBack,
      child: Container(
        key: ValueKey(_currentIndex),
        margin: const EdgeInsets.only(top: 16),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Translate this word',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.deepOrange.shade300,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Bangla word
            Text(
              question.banglaWord,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            // Audio indicator row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded,
                      color: Colors.deepOrange.shade300, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Auto-playing...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // OPTION LIST
  // ─────────────────────────────────────────────
  Widget _buildOptionList(_Question question) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index == question.options.length - 1 ? 0 : 12),
          child: _buildOptionButton(option, question.correctEnglish, optionIndex: index),
        );
      }).toList(),
    );
  }

  Widget _buildOptionButton(String option, String correctAnswer, {int optionIndex = 0}) {
    final bool isCorrectOption = option == correctAnswer;
    final bool isSelectedOption = option == _selectedAnswer;

    Color? bgColor;
    Color? borderColor;
    IconData? trailingIcon;
    Color? textColor;

    if (_isAnswered) {
      if (isCorrectOption) {
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF4CAF50);
        trailingIcon = Icons.check_circle_rounded;
        textColor = const Color(0xFF2E7D32);
      } else if (isSelectedOption && !isCorrectOption) {
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFE53935);
        trailingIcon = Icons.cancel_rounded;
        textColor = const Color(0xFFC62828);
      } else {
        bgColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade200;
        textColor = Colors.grey.shade400;
      }
    }

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAnswered ? null : () => _selectAnswer(option),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: bgColor ?? Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor ??
                    (_isAnswered
                        ? Colors.grey.shade200
                        : Colors.deepOrange.withOpacity(0.2)),
                width: isCorrectOption && _isAnswered ? 2.5 : 1.5,
              ),
              boxShadow: [
                if (!_isAnswered)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Option letter indicator
                if (!_isAnswered)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange.shade400,
                          Colors.deepOrange.shade300,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      String.fromCharCode(65 + optionIndex),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_isAnswered) const SizedBox(width: 4),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _isAnswered && isCorrectOption
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                ),
                if (trailingIcon != null)
                  Icon(trailingIcon,
                      color: isCorrectOption
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                      size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}