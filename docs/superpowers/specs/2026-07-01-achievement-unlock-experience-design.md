# Achievement Unlock Experience Enhancement

**Date:** 2026-07-01
**Status:** Approved Design

## 1. Problem Statement

Currently when achievements unlock after a game, the app only shows a plain green
SnackBar (`ScaffoldMessenger.of(context).showSnackBar(...)`) for each unlocked
achievement. There is no animation, no sound, and no celebratory feel. Additionally,
multiple achievements often unlock simultaneously after a single game, flooding the
user with sequential SnackBars.

## 2. Goals

1. **One achievement per game popup** — Only the rarest newly-unlocked achievement
   is displayed. All achievements still unlock in the background.
2. **Beautiful animated popup overlay** — Scale/fade entrance with confetti particles.
3. **Sound effect** — Play achievement sound on unlock.
4. **Rarity-based visual effects** — Higher rarity = more impressive animation.
5. **User-controlled dismissal** — Tap anywhere or press a button to close.

## 3. Logic Change

### 3.1 Achievement filtering

In `AchievementService.checkGameAchievements()`, all newly-unlocked achievements
are still unlocked and saved. However, the method will return only **one**
achievement — the one with the highest rarity tier.

Rarity priority (ascending):
```
Common (0) < Uncommon (1) < Rare (2) < Epic (3) < Legendary (4)
```

### 3.2 Affected files

| File | Change |
|------|--------|
| `lib/services/achievement_service.dart` | Filter `newlyUnlocked` list to return only the rarest item |
| `lib/providers/game/achievement_provider.dart` | No logic change needed — passes through the filtered list |
| `lib/features/game/screens/result_screen.dart` | Replace `_showAchievementNotification()` (SnackBar) with new overlay |

## 4. Visual Design

### 4.1 New widget: `AchievementUnlockOverlay`

A new stateless widget or dialog component will be created at:
`lib/features/game/widgets/achievement_unlock_overlay.dart`

### 4.2 Layout structure

```
┌─────────────────────────────────┐
│    Semi-transparent backdrop     │
│    (black, 60% opacity)          │
│  ┌───────────────────────────┐   │
│  │  Achievement Card         │   │
│  │  ┌─────────────────────┐  │   │
│  │  │   🏆 (large emoji)  │  │   │  ← 64px, animated bounce
│  │  │  ACHIEVEMENT        │  │   │
│  │  │  UNLOCKED!          │  │   │  ← Bold title
│  │  │                     │  │   │
│  │  │  🎉 First Win       │  │   │  ← Achievement icon + title
│  │  │  Win your first     │  │   │  ← Description
│  │  │  game               │  │   │
│  │  │                     │  │   │
│  │  │ ⚡+50 XP  🪙+25     │  │   │  ← Reward chips
│  │  │                     │  │   │
│  │  │   [ CONTINUE ]     │  │   │  ← Button or tap-to-close
│  │  └─────────────────────┘  │   │
│  │                           │   │
│  └───────────────────────────┘   │
│    ✨ Confetti particles          │  ← Rarity-based
└─────────────────────────────────┘
```

### 4.3 Rarity-based effects

| Rarity | Color | Confetti Count | Extra Effects |
|--------|-------|----------------|---------------|
| Common | Grey `#9E9E9E` | 20 particles | Simple scale-in |
| Uncommon | Green `#4CAF50` | 40 particles | Slight bounce on entry |
| Rare | Blue `#2196F3` | 60 particles | Bounce + glow border |
| Epic | Purple `#9C27B0` | 80 particles | Bounce + glow + sparkle trail |
| Legendary | Orange `#FF9800` | 100+ particles | Gold burst + intense glow |

### 4.4 Animation timeline

```
0ms      ─ Backdrop fade-in (300ms ease-in)
0ms      ─ Confetti start (continues for 3s)
100ms    ─ Card scale 0→1.1→1.0 (400ms spring curve)
300ms    ─ Icon bounce (200ms)
500ms    ─ Title fade-in (200ms)
700ms    ─ Description fade-in (200ms)
900ms    ─ Reward chips fade-in (200ms)
Tap      ─ Fade-out all (200ms) → dismiss
```

## 5. Sound

### 5.1 Existing infrastructure

- `SoundService.playAchievement()` exists but is never called.
- Sound file expected at `assets/audio/game_achievement.mp3`.
- `assets/audio/` directory is empty.

### 5.2 Requirements

- Add `assets/audio/game_achievement.mp3` — a short celebratory chime/tada sound
  (~1-2 seconds).
- Call `SoundService.playAchievement()` right before showing the overlay.

### 5.3 Sound file source

An appropriate royalty-free achievement sound will be sourced. Options:
- Short chime from a free SFX library (e.g., mixkit.co, freesound.org)
- Or create a simple synthesized chime

## 6. Dependencies

### 6.1 New package: `confetti`

Add `confetti: ^0.7.0` (or latest) to `pubspec.yaml` for particle effects.

## 7. Files to Create/Modify

### New files:
- `lib/features/game/widgets/achievement_unlock_overlay.dart` — The overlay widget

### Modified files:
- `pubspec.yaml` — Add `confetti` package, ensure `assets/audio/` is included
- `lib/services/achievement_service.dart` — Filter to rarest achievement
- `lib/features/game/screens/result_screen.dart` — Replace SnackBar with overlay
- `assets/audio/game_achievement.mp3` — Add sound file

## 8. Error / Edge Cases

| Scenario | Behavior |
|----------|----------|
| Sound file missing | `SoundService` silently catches errors, overlay still shows |
| Confetti package fails | Fallback: just show overlay without particles |
| User leaves screen mid-animation | Overlay tied to `Navigator` context; if screen pops, overlay dismisses |
| Muted sound | `SoundService.playAchievement()` checks `_muted` flag automatically |
| Already unlocked achievement | Service returns `null`, no popup shown |
| Zero newly unlocked | No overlay shown at all |
