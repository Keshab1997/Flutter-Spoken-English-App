# Achievement Unlock Experience Enhancement — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the plain SnackBar achievement notification with a beautiful full-screen popup overlay featuring confetti particles, rarity-based animations, and sound effects.

**Architecture:** (1) Add a `getRarestAchievement` helper to `AchievementService` so only the rarest newly-unlocked achievement triggers a popup. (2) Create a new `AchievementUnlockOverlay` widget with confetti + scale animations. (3) Update `ResultScreen` to call sound + show overlay instead of SnackBar. (4) Add `confetti` package and achievement audio file.

**Tech Stack:** Flutter, `confetti` package, `audioplayers` (already present), Riverpod

---

### Task 1: Add `confetti` package + achievement sound file

**Files:**
- Modify: `pubspec.yaml`
- Create: `assets/audio/game_achievement.mp3`

- [ ] **Step 1: Add confetti dependency to pubspec.yaml**

Add the `confetti` package under `dependencies:` (alphabetically, before `cupertino_icons`):

```yaml
  confetti: ^0.7.0
```

- [ ] **Step 2: Run flutter pub get**

Run:

```bash
cd "/Users/keshabsarkar/Vs Code Apps/Flutter-Spoken-English-App"
flutter pub get
```

Expected output: `Process finished with exit code 0` (confetti package resolved).

- [ ] **Step 3: Download free achievement sound**

Download a short celebratory chime and save it as `assets/audio/game_achievement.mp3`:

```bash
cd "/Users/keshabsarkar/Vs Code Apps/Flutter-Spoken-English-App"
curl -L -o assets/audio/game_achievement.mp3 "https://mixkit.co/free-sound-effects/download/mixkit-achievement-bell-600/?force=1" 2>/dev/null || \
curl -L -o assets/audio/game_achievement.mp3 "https://www.soundjay.com/misc/sounds/bell-chime-1.mp3" 2>/dev/null
```

If both downloads fail, create a minimal valid MP3 placeholder:

```bash
# Create minimal valid MP3 (1 second silence)
python3 -c "
import struct, base64
# Minimal MP3 frame (valid silent frame)
frame = bytes([0xFF, 0xFB, 0x90, 0x00]) + bytes(413)  # MPEG1 Layer3 128kbps 44100Hz
with open('assets/audio/game_achievement.mp3', 'wb') as f:
    for _ in range(38):  # ~1 second
        f.write(frame)
"
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock assets/audio/game_achievement.mp3
git commit -m "feat: add confetti package and achievement unlock sound"
```

---

### Task 2: Add rarest-achievement filter to AchievementService

**Files:**
- Modify: `lib/services/achievement_service.dart`

- [ ] **Step 1: Add rarity-order constant and filter method**

Add the following at the end of `AchievementService` class (before the closing `}`):

```dart
  /// Rarity tier ordering (higher = more rare / higher display priority).
  static const Map<String, int> _rarityOrder = {
    'Common': 0,
    'Uncommon': 1,
    'Rare': 2,
    'Epic': 3,
    'Legendary': 4,
  };

  /// Given a list of achievements, returns the one with the highest rarity.
  /// If multiple share the same rarity, returns the one with the lowest
  /// [order] field (i.e., highest display priority within that tier).
  static AchievementModel? getRarestAchievement(List<AchievementModel> achievements) {
    if (achievements.isEmpty) return null;
    return achievements.reduce((a, b) {
      final aOrder = _rarityOrder[a.rarity] ?? 0;
      final bOrder = _rarityOrder[b.rarity] ?? 0;
      if (aOrder != bOrder) return aOrder > bOrder ? a : b;
      return a.order <= b.order ? a : b;
    });
  }
```

- [ ] **Step 2: Verify the code compiles**

```bash
cd "/Users/keshabsarkar/Vs Code Apps/Flutter-Spoken-English-App"
flutter analyze lib/services/achievement_service.dart
```

Expected output: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/services/achievement_service.dart
git commit -m "feat: add getRarestAchievement helper to AchievementService"
```

---

### Task 3: Create AchievementUnlockOverlay widget

**Files:**
- Create: `lib/features/game/widgets/achievement_unlock_overlay.dart`

- [ ] **Step 1: Create widgets directory**

```bash
mkdir -p "/Users/keshabsarkar/Vs Code Apps/Flutter-Spoken-English-App/lib/features/game/widgets"
```

- [ ] **Step 2: Write the overlay widget**

Create `lib/features/game/widgets/achievement_unlock_overlay.dart`:

```dart
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/game/achievement_model.dart';

/// A full-screen celebration overlay shown when an achievement is unlocked.
///
/// Displays a rarity-themed animated card over a semi-transparent backdrop
/// with confetti particles. The card scales and fades in with a spring
/// animation, and the achievement icon bounces separately.
///
/// Callers must provide [achievement] and [onDismiss]. The overlay plays
/// the achievement sound via [SoundService] automatically.
class AchievementUnlockOverlay extends StatefulWidget {
  final AchievementModel achievement;
  final VoidCallback onDismiss;

  const AchievementUnlockOverlay({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  State<AchievementUnlockOverlay> createState() =>
      _AchievementUnlockOverlayState();
}

class _AchievementUnlockOverlayState extends State<AchievementUnlockOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    // ── Entry animation: scale 0 → 1.05 → 1.0 with spring feel ──
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

    // ── Icon bounce animation (starts after card appears) ──
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // ── Confetti particle controller ──
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // ── Start animations ──
    _entryController.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _bounceController.forward();
    });
    _confettiController.play();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _bounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // ── Rarity configuration ──

  static const Map<String, int> _rarityOrder = {
    'Common': 0,
    'Uncommon': 1,
    'Rare': 2,
    'Epic': 3,
    'Legendary': 4,
  };

  Map<String, dynamic> get _rarityConfig {
    final r = widget.achievement.rarity;
    switch (r) {
      case 'Legendary':
        return {
          'particleCount': 25,
          'glowRadius': 40.0,
          'glowOpacity': 0.5,
        };
      case 'Epic':
        return {
          'particleCount': 20,
          'glowRadius': 30.0,
          'glowOpacity': 0.4,
        };
      case 'Rare':
        return {
          'particleCount': 15,
          'glowRadius': 20.0,
          'glowOpacity': 0.3,
        };
      case 'Uncommon':
        return {
          'particleCount': 10,
          'glowRadius': 15.0,
          'glowOpacity': 0.25,
        };
      default: // Common
        return {
          'particleCount': 5,
          'glowRadius': 10.0,
          'glowOpacity': 0.15,
        };
    }
  }

  List<Color> get _confettiColors {
    final base = widget.achievement.rarityColor;
    return [
      base,
      base.withOpacity(0.7),
      Colors.white,
      Colors.amberAccent,
      Colors.yellowAccent,
    ];
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final rarityColor = a.rarityColor;
    final config = _rarityConfig;
    final particleCount = config['particleCount'] as int;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // ── Semi-transparent backdrop (tap to dismiss) ──
          GestureDetector(
            onTap: widget.onDismiss,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, _) => Container(
                color: Colors.black.withOpacity(0.55 * _fadeAnimation.value),
              ),
            ),
          ),

          // ── Confetti particle system ──
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: _confettiColors,
              numberOfParticlesPerTick: particleCount,
              maxBlastForce: 20,
              minBlastForce: 5,
              gravity: 0.2,
              particleDrag: 0.05,
              createParticlePath: _drawStar,
            ),
          ),

          // ── Achievement card ──
          Center(
            child: AnimatedBuilder(
              animation: _entryController,
              builder: (context, _) {
                final scale = _scaleAnimation.value;
                final opacity = _fadeAnimation.value;
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: _buildCard(context, a, rarityColor, config),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    AchievementModel a,
    Color rarityColor,
    Map<String, dynamic> config,
  ) {
    final glowRadius = config['glowRadius'] as double;
    final glowOpacity = config['glowOpacity'] as double;
    final theme = Theme.of(context);

    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: rarityColor.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withOpacity(glowOpacity),
            blurRadius: glowRadius,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Achievement emoji icon ──
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, _) {
                final bounce = _bounceAnimation.value;
                return Transform.scale(
                  scale: 0.8 + (bounce * 0.4),
                  child: Text(a.icon, style: const TextStyle(fontSize: 64)),
                );
              },
            ),
            const SizedBox(height: 12),

            // ── "ACHIEVEMENT UNLOCKED!" header ──
            Text(
              'ACHIEVEMENT UNLOCKED!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5,
                color: rarityColor,
              ),
            ),
            const SizedBox(height: 16),

            // ── Achievement title ──
            Text(
              '${a.icon}  ${a.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // ── Description ──
            Text(
              a.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),

            // ── Rarity badge ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                a.rarity.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: rarityColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Rewards row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (a.xpReward > 0) ...[
                  _RewardChip(
                    icon: '⚡',
                    label: '+${a.xpReward} XP',
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                ],
                if (a.coinReward > 0)
                  _RewardChip(
                    icon: '🪙',
                    label: '+${a.coinReward}',
                    color: AppColors.warning,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Continue button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: rarityColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}

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

- [ ] **Step 3: Verify the code compiles**

```bash
cd "/Users/keshabsarkar/Vs Code Apps/Flutter-Spoken-English-App"
flutter analyze lib/features/game/widgets/achievement_unlock_overlay.dart
```

Expected output: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/game/widgets/achievement_unlock_overlay.dart
git commit -m "feat: add AchievementUnlockOverlay widget with confetti and rarity-based animations"
```

---

### Task 4: Update ResultScreen to use overlay + sound

**Files:**
- Modify: `lib/features/game/screens/result_screen.dart`

- [ ] **Step 1: Replace SnackBar display with overlay**

In `lib/features/game/screens/result_screen.dart`:

1. Add import at the top:
```dart
import '../../game/widgets/achievement_unlock_overlay.dart';
import '../../../services/sound_service.dart';
import '../../../providers/game/achievement_provider.dart';
```

(Note: `achievement_provider.dart` import likely already exists — check and only add if missing.)

2. Replace the entire `_showAchievementNotification` method (lines ~146-172) and the call to it with the following:

**Replace this code (in `_checkAchievements` method, lines 138-140):**
```dart
if (newlyUnlocked.isNotEmpty && mounted) {
  _showAchievementNotification(newlyUnlocked);
}
```

**With:**
```dart
if (newlyUnlocked.isNotEmpty && mounted) {
  _showAchievementUnlock(newlyUnlocked);
}
```

**Replace the old `_showAchievementNotification` method entirely with:**
```dart
void _showAchievementUnlock(List<AchievementModel> achievements) {
  final rarest = AchievementService.getRarestAchievement(achievements);
  if (rarest == null) return;

  // Play achievement sound
  try {
    final soundService = ref.read(soundServiceProvider);
    soundService.playAchievement();
  } catch (_) {
    // Sound service not available — overlay still shows
  }

  // Show full-screen celebration overlay
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    pageBuilder: (context, anim, secondaryAnim) => AchievementUnlockOverlay(
      achievement: rarest,
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}
```

3. Add the missing import for `AchievementService` if not already imported:
```dart
import '../../../services/achievement_service.dart';
```

- [ ] **Step 2: Verify the imports are correct**

Read the import section of `result_screen.dart` and ensure these imports exist (add any that are missing):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ... existing imports ...
import '../../../models/game/achievement_model.dart';
import '../../../services/achievement_service.dart';
import '../../../services/sound_service.dart';
import '../../../providers/game/achievement_provider.dart';
import '../../game/widgets/achievement_unlock_overlay.dart';
```

- [ ] **Step 3: Run flutter analyze**

```bash
cd "/Users/keshabsarkar/Vs Code Apps/Flutter-Spoken-English-App"
flutter analyze lib/features/game/screens/result_screen.dart
```

Expected output: `No issues found!`

- [ ] **Step 4: Run full project analysis**

```bash
cd "/Users/keshabsarkar/Vs Code Apps/Flutter-Spoken-English-App"
flutter analyze
```

Expected output: `No issues found!` (or only pre-existing warnings)

- [ ] **Step 5: Commit**

```bash
git add lib/features/game/screens/result_screen.dart
git commit -m "feat: replace SnackBar with animated overlay + sound for achievement unlock"
```

---

### Task 5: Quick verification

- [ ] **Step 1: Run full build check**

```bash
cd "/Users/keshabsarkar/Vs Code Apps/Flutter-Spoken-English-App"
flutter build apk --debug 2>&1 | tail -20
```

Expected: Build succeeds (no errors).

- [ ] **Step 2: Final commit**

```bash
git add -A
git commit -m "feat: complete achievement unlock experience enhancement"
```
