# Notification Background Delivery Improvement Design

**Date:** 2026-07-01
**Status:** Approved

## Problem Statement

The app's notification system needs improvement in several areas:
1. Admin notifications are pull-based (client fetches from Firestore) — they do not work when the app is closed
2. No re-engagement mechanism for inactive users (no push/motivation to return)
3. Daily Word notification lacks rich formatting (word, meaning, example not visible in notification)
4. Scheduling reliability needs improvement across device states (Doze mode, reboot)

## Scope

Implement background notification delivery **without FCM** using WorkManager + enhanced local notifications:

- **Background Admin Sync** — WorkManager periodically fetches admin notifications from Firestore and shows local notifications
- **Re-engagement System** — Motivational notifications for inactive users
- **Rich Daily Word** — Enhanced notification with word, Bangla meaning, example sentence
- **Scheduling Reliability** — Better handling of Doze mode, battery optimization, reboot

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Flutter App (Android)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────────┐    ┌────────────────────────────────┐   │
│  │  NotificationService │    │     WorkManager (Background)   │   │
│  │  (Enhanced)          │    │                                │   │
│  │                      │    │  ┌─────────────────────────┐   │   │
│  │  - Schedule Daily    │    │  │ AdminSyncTask           │   │   │
│  │    Word (Rich)       │    │  │ - Firestore চেক          │   │   │
│  │  - Schedule Practice │◄──►│  │ - নতুন পেলে Local Notif │   │   │
│  │    Reminder          │    │  └─────────────────────────┘   │   │
│  │  - Schedule Re-      │    │  ┌─────────────────────────┐   │   │
│  │    engagement        │    │  │ ReEngagementTask        │   │   │
│  │  - Show Local Notif  │    │  │ - inactivity চেক        │   │   │
│  └────────┬────────────┘    │  │ - motivation msg পাঠায়  │   │   │
│           │                 │  └─────────────────────────┘   │   │
│           │                 └────────────────────────────────┘   │
│           ▼                                                      │
│  ┌─────────────────────┐                                         │
│  │  HiveService         │                                         │
│  │  (Notification Hist) │                                         │
│  └─────────────────────┘                                         │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────────┐                                         │
│  │  NotificationProvider│  (Riverpod - reactive UI)              │
│  └─────────────────────┘                                         │
│           │                                                      │
│           ▼                                                      │
│  ┌────────────────────────────────────────────────────────┐      │
│  │  UI: HomeScreen (badge) / NotificationHistoryScreen    │      │
│  └────────────────────────────────────────────────────────┘      │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
         │                        │
         ▼                        ▼
  ┌──────────────┐      ┌──────────────────┐
  │  Firestore    │      │   Admin Panel    │
  │  (Admin Notif)│◄─────│   (Send Notif)   │
  └──────────────┘      └──────────────────┘
```

### Component Roles

| Component | Type | Role |
|-----------|------|------|
| `workmanager` | Package | Background task scheduling |
| `flutter_local_notifications` | Package | Display local notifications (existing) |
| `AdminSyncTask` | WorkManager Task | Periodic Firestore fetch for admin notifications |
| `ReEngagementTask` | WorkManager Task | Check user inactivity, send motivational notifications |
| `NotificationService` | Enhanced Service | Rich Daily Word, scheduling, WorkManager callbacks |
| `ReEngagementService` | New Service | Inactivity detection, message generation |
| `DailyWordService` | New Service | Fetch today's word from Firestore or local fallback |

## WorkManager Tasks

### Task 1: AdminSyncTask

**Interval:** Every 15 minutes (Android WorkManager minimum)

```dart
@pragma('vm:entry-point')
void adminSyncTask() async {
  await Workmanager().executeTask((task, inputData) async {
    try {
      final newCount = await AdminNotificationSyncService.syncLatest();
      if (newCount > 0) {
        await NotificationService().showLocalNotification(
          id: _adminSyncNotifId,
          title: '📢 নতুন ঘোষণা',
          body: 'অ্যাডমিন একটি নতুন নোটিফিকেশন পাঠিয়েছেন',
          actionType: 'admin',
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  });
}
```

**Schedule:**
```dart
await Workmanager().registerPeriodicTask(
  'adminSync',
  'adminSyncTask',
  frequency: Duration(minutes: 15),
  constraints: Constraints(
    networkType: NetworkType.connected,
  ),
  existingWorkPolicy: ExistingWorkPolicy.keep,
);
```

### Task 2: ReEngagementTask

**Interval:** Daily

```dart
@pragma('vm:entry-point')
void reEngagementTask() async {
  await Workmanager().executeTask((task, inputData) async {
    final result = await ReEngagementService.checkInactivity();
    if (result.shouldNotify) {
      final message = MotivationMessageBank.getMessage(result.daysInactive);
      await NotificationService().showLocalNotification(
        id: _reEngagementNotifId,
        title: '⏰ ফিরে আসুন!',
        body: message,
        actionType: 'home',
        actions: [
          AndroidNotificationAction('continue_learning', '📖 Continue Learning',
            showsUserInterface: true),
          AndroidNotificationAction('remind_later', '⏰ Remind Later',
            showsUserInterface: false),
        ],
      );
    }
    return true;
  });
}
```

**Schedule:**
```dart
await Workmanager().registerPeriodicTask(
  'reEngagement',
  'reEngagementTask',
  frequency: Duration(hours: 24),
  constraints: Constraints(
    networkType: NetworkType.connected,
  ),
  existingWorkPolicy: ExistingWorkPolicy.keep,
);
```

## Re-engagement System

### Inactivity Detection

```dart
class ReEngagementService {
  static Future<InactivityResult> checkInactivity() async {
    final lastOpenDate = HiveService.getLastAppOpenDate();
    final now = DateTime.now();
    final daysInactive = now.difference(lastOpenDate).inDays;
    
    // Already opened today → skip
    if (lastOpenDate.year == now.year && 
        lastOpenDate.month == now.month && 
        lastOpenDate.day == now.day) {
      return InactivityResult(shouldNotify: false);
    }
    
    return InactivityResult(
      daysInactive: daysInactive,
      shouldNotify: daysInactive >= 1,
    );
  }
}
```

### Message Bank

| Days Inactive | Message |
|---------------|---------|
| 1 | "{name}, আপনার আজকের একটি Daily Word অপেক্ষা করছে! 🎯" |
| 2 | "{name}, 🔥 ২ দিন ধরে আসেননি! আপনার streak বাঁচান!" |
| 3-5 | "{name}, 💪 {days} দিন! নতুন অধ্যায় যোগ হয়েছে!" |
| 6-7 | "{name}, ⚡ এক সপ্তাহ! ছোট করে হলেও শুরু করুন!" |
| 8+ | "{name}, 🚀 {days} দিন! ফিরতে কখনো দেরি হয় না!" |

## Rich Daily Word Notification

### Format

```dart
final bigTextStyle = BigTextStyleInformation(
  '''
📖 *{word}* ({pronunciation})
━━━━━━━━━━━━━━━
🔤 বাংলা অর্থ: {banglaMeaning}

📝 উদাহরণ:
{exampleSentence}
━━━━━━━━━━━━━━━
ℹ️ বিস্তারিত জানতে Tap করুন
  ''',
  contentTitle: '📚 Word of the Day',
  summaryText: '{word} → {banglaMeaning}',
);
```

### Data Source

```dart
Future<DailyWordData> _getTodayWord() async {
  // 1. Try Firestore daily_words collection
  final doc = await FirebaseFirestore.instance
      .collection('daily_words')
      .doc(_getTodayDateString())
      .get();
  if (doc.exists) return DailyWordData.fromMap(doc.data()!);
  
  // 2. Fallback: Local vocabulary cache থেকে random
  return _getRandomWordFromLocal();
}
```

### Scheduled Time

- **Daily Word:** 9:00 AM (existing, enriched with BigTextStyle)
- **Schedule Mode:** `AndroidScheduleMode.inexactAllowWhileIdle` (Doze-friendly)

## Scheduling Reliability Improvements

| Issue | Fix |
|-------|-----|
| Doze mode blocking | Use `inexactAllowWhileIdle` schedule mode |
| Battery optimization | Guide user to disable battery optimization for app |
| Device reboot | Already handled by `ScheduledNotificationBootReceiver` (existing) |
| WorkManager task lost | `ExistingWorkPolicy.keep` ensures task persists |
| Periodic task exact timing | Use `flexInterval` for system-friendly scheduling |

## Data Flow

### Admin Notification → Background Delivery

1. Admin sends notification from Admin Dashboard → Firestore `admin_notifications`
2. WorkManager `AdminSyncTask` triggers (every 15 min)
3. `AdminNotificationSyncService.syncLatest()` fetches new/updated docs
4. If new notifications found, `NotificationService.showLocalNotification()` called
5. User sees notification in system tray
6. User taps → app opens → `NotificationHistoryScreen` shows full details

### Daily Word → Rich Notification

1. `NotificationService._scheduleDailyWord()` at 9:00 AM
2. Fetches today's word from Firestore/local
3. Shows notification with `BigTextStyleInformation` (word, meaning, example)
4. User can expand to see full content
5. "See Details" action button opens vocabulary screen

### Re-engagement → Motivational Notification

1. WorkManager `ReEngagementTask` triggers (daily)
2. `ReEngagementService.checkInactivity()` reads `lastAppOpenDate` from Hive
3. If days inactive >= 1 and user hasn't opened app today → generate message
4. `NotificationService.showLocalNotification()` with action buttons
5. "Continue Learning" → open app; "Remind Later" → postpone

## Files to Create

1. `lib/services/workmanager_tasks.dart` — All background task definitions
2. `lib/services/re_engagement_service.dart` — Inactivity check + message bank
3. `lib/services/daily_word_service.dart` — Fetch today's word

## Files to Modify

1. `pubspec.yaml` — Add `workmanager` dependency
2. `lib/main.dart` — Initialize WorkManager, register tasks
3. `lib/services/notification_service.dart` — Rich Daily Word, enhanced scheduling, WorkManager callbacks
4. `lib/services/admin_notification_sync_service.dart` — Return new count
5. `lib/providers/notification_provider.dart` — Handle background-synced state
6. `lib/features/settings/screens/settings_screen.dart` — Re-engagement toggle
7. `lib/services/hive_service.dart` — Add `lastAppOpenDate` getter/setter

## New Dependencies

- `workmanager: ^0.5.2` — Background periodic task scheduling

## Implementation Order

1. Add `workmanager` dependency → Setup in `main.dart`
2. Create `workmanager_tasks.dart` (AdminSyncTask + ReEngagementTask)
3. Create `re_engagement_service.dart` (inactivity check + message bank)
4. Create `daily_word_service.dart` (fetch today's word)
5. Enhance `NotificationService` (rich Daily Word, schedule improvements)
6. Update `HiveService` (lastAppOpenDate storage)
7. Update `AdminNotificationSyncService` (return new count from sync)
8. Update Settings screen (re-engagement toggle)
9. Update `NotificationProvider` (handle background synced state)
10. Testing & verification

## Self-Review

1. **Placeholder scan:** No TBD or TODO. All sections filled.
2. **Internal consistency:** Architecture matches feature descriptions. WorkManager tasks align with notification service. Rich Daily Word uses existing `flutter_local_notifications` with BigTextStyle enhancement.
3. **Scope check:** Focused on background delivery improvement without FCM. Does not include unrelated refactoring of existing notification UI (already done in previous iteration).
4. **Ambiguity check:** 
   - WorkManager interval is minimum 15 min on Android — documented
   - Re-engagement only fires if user hasn't opened app today — documented
   - Daily Word fallback strategy (Firestore → local) — documented
