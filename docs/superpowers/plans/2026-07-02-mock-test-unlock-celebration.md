# Mock Test Unlock Celebration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show a full-screen celebration overlay with confetti and animations when a student scores 20/20 on a mock test and unlocks the next test.

**Architecture:** New `MockTestUnlockOverlay` StatefulWidget with `AnimationController`s for entry animations and a `ConfettiController` for particle effects. The overlay is conditionally rendered in a `Stack` on top of the result screen. The existing `MockTestResultScreen` is converted from `ConsumerWidget` to `ConsumerStatefulWidget` to manage overlay show/hide state.

**Tech Stack:** Flutter, Riverpod, confetti (already in pubspec.yaml)

**Reference:** Design spec at `docs/superpowers/specs/2026-07-02-mock-test-unlock-celebration-design.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/features/mock_test/widgets/mock_test_unlock_overlay.dart` | **Create** | Full-screen celebration overlay with confetti, animations, and card layout |
| `lib/features/mock_test/screens/mock_test_result_screen.dart` | **Modify** | Convert to StatefulWidget, add overlay trigger on perfect score |

---

### Task 1: Create `MockTestUnlockOverlay` widget

**Files:**
- Create: `lib/features/mock_test/widgets/mock_test_unlock_overlay.dart`

- [ ] **Step 1: Write the overlay widget skeleton with imports and constructor**

```dart
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Full-screen celebration overlay shown when a student scores 20/20
/// on a mock test and unlocks the next test.
///
/// Displays a gold-themed animated card over a semi-transparent backdrop
/// with confetti particles. The card scales and fades in with a spring
/// animation, and the trophy icon bounces separately.
class MockTestUnlockOverlay extends StatefulWidget {
  final int completedTestNumber;
  final String completedTestTitle;
  final int nextTestNumber;
  final int totalCompleted;
  final int totalTests;
  final int xpReward;
  final int coinReward;
  final VoidCallback onTakeNextTest;
  final VoidCallback onDismiss;

  const MockTestUnlockOverlay({
    super.key,
    required this.completedTestNumber,
    required this.completedTestTitle,
    required this.nextTestNumber,
    required this.totalCompleted,
    required this.totalTests,
    this.xpReward = 50,
    this.coinReward = 25,
    required this.onTakeNextTest,
    required this.onDismiss,
  });

  @override
  State<MockTestUnlockOverlay> createState() => _MockTestUnlockOverlayState();
}
```

- [ ] **Step 2: Add state class with AnimationControllers and ConfettiController**

```dart
class _MockTestUnlockOverlayState extends State<MockTestUnlockOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  late final AnimationController _contentController;
  late final Animation<double> _contentFade;

  late final ConfettiController _confettiController;

  bool _isLastTest = false;

  @override
  void initState() {
    super.initState();

    _isLastTest = widget.nextTestNumber > widget.totalTests;

    // Entry animation: scale 0 → 1.05 → 1.0 with spring feel
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );

    // Trophy bounce animation (starts after card appears)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Content staggered fade-in
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    // Confetti particle controller
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Start animations
    _entryController.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _bounceController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _contentController.forward();
    });
    _confettiController.play();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _bounceController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 3: Add confetti color getter and star path drawer**

```dart
  List<Color> get _confettiColors => [
        const Color(0xFFFF9800), // Gold
        const Color(0xFFFFC107), // Amber
        Colors.white,
        Colors.yellowAccent,
        const Color(0xFF4CAF50), // Green (AppColors.secondary)
      ];

  /// Draws a simple 5-pointed star path for confetti particles.
  static Path _drawStar(Size size) {
    const numPoints = 5;
    const outerRadius = 6.0;
    const innerRadius = 2.5;
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 0; i < numPoints * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (pi * i / numPoints) - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
```

- [ ] **Step 4: Add the build method with Stack, backdrop, confetti, and centered card**

```dart
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = widget.totalCompleted / widget.totalTests;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent backdrop (tap to dismiss)
          GestureDetector(
            onTap: widget.onDismiss,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, _) => Container(
                color: Colors.black.withOpacity(0.55 * _fadeAnimation.value),
              ),
            ),
          ),

          // Confetti particle system
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: _confettiColors,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 5,
              gravity: 0.2,
              particleDrag: 0.05,
              createParticlePath: _drawStar,
            ),
          ),

          // Celebration card (wrapped to absorb taps on margin area)
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {}, // prevent taps from passing to backdrop
              child: AnimatedBuilder(
                animation: _entryController,
                builder: (context, _) {
                  final scale = _scaleAnimation.value;
                  final opacity = _fadeAnimation.value;
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: _buildCard(context, theme, isDark, progress),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 5: Add the card builder with all content sections**

```dart
  Widget _buildCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    double progress,
  ) {
    const goldColor = Color(0xFFFF9800);
    const goldColorLight = Color(0xFFFFC107);

    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: goldColor.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: goldColor.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy icon with bounce
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, _) {
                final bounce = _bounceAnimation.value;
                return Transform.scale(
                  scale: 0.8 + (bounce * 0.4),
                  child: const Text('🏆', style: TextStyle(fontSize: 72)),
                );
              },
            ),
            const SizedBox(height: 12),

            // "PERFECT SCORE!" header
            Text(
              'PERFECT SCORE!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: goldColorLight,
              ),
            ),
            const SizedBox(height: 8),

            // Score
            Text(
              '🎉 You scored 20/20!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 4),

            // Test completed
            Text(
              '${widget.completedTestTitle}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.secondary, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Completed ✅',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // Divider
            if (!_isLastTest) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),

              // Next test unlocked
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_open_rounded,
                      color: goldColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Mock Test ${widget.nextTestNumber} Unlocked!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: goldColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'You\'ve earned the right to advance! 🎯',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ] else ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              Text(
                '🎉 You completed all ${widget.totalTests} tests!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What an incredible achievement! 🌟',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],

            // Progress bar
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${widget.totalCompleted}/${widget.totalTests}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedBuilder(
                    animation: _contentController,
                    builder: (context, _) => LinearProgressIndicator(
                      value: progress * _contentFade.value,
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[200],
                      color: AppColors.secondary,
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),

            // Rewards
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.xpReward > 0) ...[
                  _RewardChip(
                    icon: '⚡',
                    label: '+${widget.xpReward} XP',
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.coinReward > 0)
                  _RewardChip(
                    icon: '🪙',
                    label: '+${widget.coinReward}',
                    color: AppColors.warning,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
            if (!_isLastTest)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: widget.onTakeNextTest,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    'TAKE NEXT TEST',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: widget.onDismiss,
                  icon: const Icon(Icons.emoji_events_rounded),
                  label: const Text(
                    'VIEW RESULTS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onDismiss,
              child: Text(
                'Stay & Review',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
```

- [ ] **Step 6: Add the `_RewardChip` helper widget at the bottom of the file**

```dart
/// Small badge showing a reward (XP or coins).
class _RewardChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _RewardChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 7: Run flutter analyze to verify no issues**

Run: `flutter analyze lib/features/mock_test/widgets/mock_test_unlock_overlay.dart`
Expected: No errors, warnings only if minor

- [ ] **Step 8: Commit**

```bash
git add lib/features/mock_test/widgets/mock_test_unlock_overlay.dart
git commit -m "feat(mock_test): create MockTestUnlockOverlay celebration widget"
```

---

### Task 2: Integrate overlay into `MockTestResultScreen`

**Files:**
- Modify: `lib/features/mock_test/screens/mock_test_result_screen.dart`

- [ ] **Step 1: Add import for the new overlay and convert to StatefulWidget**

Change the class declaration:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/mock_test_model.dart';
import '../../../providers/mock_test_provider.dart';
import '../widgets/mock_test_unlock_overlay.dart';
import 'mock_test_quiz_screen.dart';
import 'mock_test_list_screen.dart';
```

Replace the class signature:

```dart
// OLD:
class MockTestResultScreen extends ConsumerWidget {

// NEW:
class MockTestResultScreen extends ConsumerStatefulWidget {
  final int testNumber;
  final String testTitle;
  final int score;
  final int total;
  final List<MockTestQuestion> questions;
  final Map<int, int> answers;
  final Map<int, List<String>>? shuffledOptionsMap;
  final Map<int, int>? shuffledCorrectIndexMap;

  const MockTestResultScreen({
    super.key,
    required this.testNumber,
    required this.testTitle,
    required this.score,
    required this.total,
    required this.questions,
    required this.answers,
    this.shuffledOptionsMap,
    this.shuffledCorrectIndexMap,
  });

  @override
  ConsumerState<MockTestResultScreen> createState() =>
      _MockTestResultScreenState();
}

class _MockTestResultScreenState extends ConsumerState<MockTestResultScreen> {
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    if (widget.score == widget.total) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _showCelebration = true);
      });
    }
  }
```

- [ ] **Step 2: Move all references from `widget` properties to `widget.` prefix**

In the build method, change all direct references to use `widget.` prefix:
- `testNumber` → `widget.testNumber`
- `testTitle` → `widget.testTitle`
- `score` → `widget.score`
- `total` → `widget.total`
- `questions` → `widget.questions`
- `answers` → `widget.answers`
- `shuffledOptionsMap` → `widget.shuffledOptionsMap`
- `shuffledCorrectIndexMap` → `widget.shuffledCorrectIndexMap`

- [ ] **Step 3: Wrap the return Scaffold in a Stack and add the overlay**

Replace the current build method's return:

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentage = (widget.score / widget.total * 100).round();
    final isPerfect = widget.score == widget.total;
    final nextTestNumber = widget.testNumber + 1;
    final nextTestUnlocked = nextTestNumber <= 70 &&
        ref.read(mockTestProvider.notifier).isTestUnlocked(nextTestNumber);
    final totalCompleted =
        ref.read(mockTestProvider.notifier).getTotalCompleted();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Test Result',
                style: TextStyle(fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.home_rounded),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const MockTestListScreen()),
                (route) => false,
              ),
              tooltip: 'Back to Test List',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ── Score Circle ──
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isPerfect
                        ? const LinearGradient(
                            colors: [
                              AppColors.secondary,
                              Color(0xFF00BFA5)
                            ])
                        : const LinearGradient(
                            colors: [Colors.orange, Colors.redAccent]),
                    boxShadow: [
                      BoxShadow(
                        color: (isPerfect ? AppColors.secondary : Colors.orange)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '/ ${widget.total}',
                          style:
                              const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title ──
                Text(
                  widget.testTitle,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // ── Percentage ──
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isPerfect ? AppColors.secondary : Colors.orange)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      color: isPerfect ? AppColors.secondary : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Shuffle Badge ──
                if (widget.shuffledOptionsMap != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shuffle_rounded,
                            size: 14, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          'Options were shuffled in this attempt',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (widget.shuffledOptionsMap != null)
                  const SizedBox(height: 12),

                // ── Message ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPerfect
                        ? AppColors.secondary.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPerfect
                          ? AppColors.secondary.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPerfect
                            ? Icons.emoji_events_rounded
                            : Icons.tips_and_updates_rounded,
                        color: isPerfect ? AppColors.secondary : Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isPerfect
                              ? '🎉 Perfect score! You have mastered this test. ${nextTestNumber <= 70 ? "Next test is now unlocked!" : "You have completed all tests!"}'
                              : 'You need ${widget.total}/${widget.total} to unlock the next test. Review your answers and try again!',
                          style: TextStyle(
                            color:
                                isPerfect ? AppColors.secondary : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Action Buttons ──
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MockTestQuizScreen(
                              testNumber: widget.testNumber,
                              testTitle: widget.testTitle,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Retry'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    if (isPerfect && nextTestUnlocked &&
                        nextTestNumber <= 70) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MockTestQuizScreen(
                                testNumber: nextTestNumber,
                                testTitle: 'Mock Test $nextTestNumber',
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Next Test'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!isPerfect) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MockTestListScreen()),
                        (route) => false,
                      ),
                      icon: const Icon(Icons.list_rounded),
                      label: const Text('Back to Test List'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // ── Answer Review ──
                Row(
                  children: [
                    Text('Review Answers',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      '${widget.answers.length} of ${widget.total} answered',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...widget.questions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final q = entry.value;

                  final displayOptions = widget.shuffledOptionsMap != null
                      ? widget.shuffledOptionsMap![idx]!
                      : q.options;
                  final correctIdx = widget.shuffledCorrectIndexMap != null
                      ? widget.shuffledCorrectIndexMap![idx]!
                      : q.correctIndex;

                  final userAnswer = widget.answers[idx];
                  final isCorrect = userAnswer == correctIdx;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCorrect
                            ? AppColors.secondary
                            : Colors.redAccent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: (isCorrect
                                        ? AppColors.secondary
                                        : Colors.redAccent)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isCorrect
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: isCorrect
                                    ? AppColors.secondary
                                    : Colors.redAccent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Q${idx + 1}: ${q.question}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_rounded,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  const Text('Your answer: ',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  Expanded(
                                    child: Text(
                                      userAnswer != null
                                          ? displayOptions[userAnswer]
                                          : 'Not answered',
                                      style: TextStyle(
                                        color: isCorrect
                                            ? AppColors.secondary
                                            : Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (!isCorrect) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        size: 14,
                                        color: AppColors.secondary),
                                    const SizedBox(width: 6),
                                    const Text('Correct: ',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12)),
                                    Expanded(
                                      child: Text(
                                        displayOptions[correctIdx],
                                        style: const TextStyle(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (q.explanation != null &&
                                  q.explanation!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.lightbulb_rounded,
                                        size: 14, color: Colors.amber),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        q.explanation!,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // ── Bottom Action ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MockTestListScreen()),
                      (route) => false,
                    ),
                    icon: const Icon(Icons.list_rounded),
                    label: const Text('Back to Test List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // ── Celebration Overlay ──
        if (_showCelebration)
          MockTestUnlockOverlay(
            completedTestNumber: widget.testNumber,
            completedTestTitle: widget.testTitle,
            nextTestNumber: nextTestNumber,
            totalCompleted: totalCompleted,
            totalTests: 70,
            xpReward: widget.testNumber * 10,
            coinReward: widget.testNumber * 5,
            onTakeNextTest: () {
              setState(() => _showCelebration = false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MockTestQuizScreen(
                    testNumber: nextTestNumber,
                    testTitle: 'Mock Test $nextTestNumber',
                  ),
                ),
              );
            },
            onDismiss: () => setState(() => _showCelebration = false),
          ),
      ],
    );
  }
```

- [ ] **Step 2: Run flutter analyze to verify no errors**

Run: `flutter analyze lib/features/mock_test/screens/mock_test_result_screen.dart`
Expected: No errors

- [ ] **Step 3: Run full project analysis**

Run: `flutter analyze`
Expected: No errors (pre-existing warnings acceptable)

- [ ] **Step 4: Commit**

```bash
git add lib/features/mock_test/screens/mock_test_result_screen.dart
git commit -m "feat(mock_test): integrate celebration overlay on perfect score"
```

---

## Self-Review

**Spec coverage check:**
- ✅ New `MockTestUnlockOverlay` widget created (Task 1)
- ✅ Confetti particles with star path (Task 1, Step 3)
- ✅ Entry animations: scale, fade, bounce (Task 1, Step 2)
- ✅ Staggered content fade-in (Task 1, Step 2)
- ✅ Card layout: trophy, "PERFECT SCORE!", score, test name, next test info (Task 1, Step 5)
- ✅ Progress bar X/70 (Task 1, Step 5)
- ✅ XP and coin rewards (Task 1, Step 5)
- ✅ "Take Next Test" button (Task 1, Step 5)
- ✅ "Stay & Review" dismiss button (Task 1, Step 5)
- ✅ Last test edge case (Task 1, Step 5, `_isLastTest` flag)
- ✅ Result screen integration (Task 2)
- ✅ 400ms delay before overlay appears (Task 2, Step 1)

**Placeholder scan:** No placeholders, TODOs, or incomplete sections found.

**Type consistency:** All method signatures and property names consistent across tasks.
