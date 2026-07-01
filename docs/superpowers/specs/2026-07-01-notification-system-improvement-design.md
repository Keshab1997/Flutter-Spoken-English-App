# Notification System Improvement Design

**Date:** 2026-07-01
**Status:** Approved

## Problem Statement

The app's notification system has several issues:
1. Notification badge (unread count) is not reactive — only updates on manual navigate-back
2. "Go to Settings" button in NotificationDialog doesn't navigate anywhere
3. Notification tap doesn't navigate to relevant screens
4. No centralized state management for notifications (scattered HiveService calls)
5. Notification history lacks date grouping and pull-to-refresh

## Scope

Focus on three areas (chosen by user):
- **Badge & UI Reactive** — Riverpod provider for live notification state
- **Better UX/UI** — Dialog, history screen, settings improvements
- **Navigation & Deep Linking** — Tap notification to navigate to relevant screen

## Design

### Architecture

```
┌─────────────────────────────────────────────────────┐
│                   NotificationProvider               │
│                  (Riverpod StateNotifier)            │
│                                                      │
│  state: { unreadCount, notifications, isLoading }    │
│                                                      │
│  refresh() → HiveService + AdminNotificationSync     │
│  markAsRead(id) → Hive + update state               │
│  markAllAsRead() → Hive + update state               │
│  delete(id) → Hive + update state                    │
│  clearAll() → Hive + update state                     │
└──────────┬──────────────────────┬──────────────────┘
           │                      │
           ▼                      ▼
    HomeScreen              NotificationHistoryScreen
    (ref.watch badge)       (ref.watch + actions)
           │
           ▼
    NotificationDialog
    (fixed settings navigation)
```

### Files to Create

#### 1. `lib/providers/notification_provider.dart` — NEW

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_history_model.dart';
import '../services/hive_service.dart';
import '../services/admin_notification_sync_service.dart';

class NotificationState {
  final int unreadCount;
  final List<NotificationHistoryItem> notifications;
  final bool isLoading;
  final int? newSyncCount; // count of newly synced admin notifications

  const NotificationState({
    this.unreadCount = 0,
    this.notifications = const [],
    this.isLoading = false,
    this.newSyncCount,
  });

  NotificationState copyWith({...});
}

class NotificationStateNotifier extends StateNotifier<NotificationState> {
  NotificationStateNotifier() : super(const NotificationState()) {
    _load();
  }

  Future<void> _load() async { ... }
  Future<void> refresh() async { ... }
  Future<void> markAsRead(String id) async { ... }
  Future<void> markAllAsRead() async { ... }
  Future<void> deleteNotification(String id) async { ... }
  Future<void> clearAll() async { ... }
}

final notificationStateProvider = StateNotifierProvider<NotificationStateNotifier, NotificationState>((ref) {
  return NotificationStateNotifier();
});
```

#### 2. `lib/features/home/widgets/notification_router.dart` — NEW

Centralized navigation handler for notification tap:

```dart
class NotificationRouter {
  static void navigate(BuildContext context, NotificationHistoryItem item) {
    // Map actionType to route
    switch (item.actionType) {
      case 'vocabulary':
        // Navigate to ChapterWordsScreen with chapter number from actionPayload
      case 'grammar':
        // Navigate to GrammarDetailScreen with chapter number
      case 'settings':
        // Navigate to SettingsScreen
      case 'homework':
        // Navigate to HomeworkScreen
      case 'game':
        // Navigate to GameHomeScreen
      case 'admin':
        // Navigate to default (usually settings or home)
      default:
        // Just mark as read, no navigation
    }
  }
}
```

### Files to Modify

#### 3. `lib/models/notification_history_model.dart` — MODIFY

Add two new fields:
- `actionType` (String?): 'vocabulary', 'grammar', 'settings', 'homework', 'game', 'admin'
- `actionPayload` (String?): e.g. '3' for chapter 3

Update: `toJson()`, `fromJson()`, `copyWith()`

#### 4. `lib/services/notification_service.dart` — MODIFY

In `_onNotificationTap`:
- After marking as read, call `NotificationRouter.navigate()`
- Update payloads of scheduled notifications to include action type
- For admin notifications, pass through the actionUrl/actionType from Firestore

#### 5. `lib/services/admin_notification_sync_service.dart` — MODIFY

- Return detailed sync result (how many added, how many removed)
- Pass through `actionType` and `actionPayload` from Firestore if present

#### 6. `lib/features/home/screens/home_screen.dart` — MODIFY

- Replace `int _unreadNotificationCount` with `ref.watch(notificationStateProvider)`
- Remove manual `_updateNotificationCount()` method
- Pass `onNavigateToSettings` callback to NotificationDialog
- Home screen's notification icon badge gets reactive updates

#### 7. `lib/features/home/widgets/notification_dialog.dart` — MODIFY

- Add `onNavigateToSettings` callback parameter
- Fix "Go to Settings" button to actually navigate
- Pass `onNavigateToSettings` when called from home screen

#### 8. `lib/features/home/widgets/notification_history_screen.dart` — MODIFY

- Replace local `_loadNotifications()` with `ref.watch(notificationStateProvider)`
- Add `RefreshIndicator` for pull-to-refresh
- Add date grouping: Today, Yesterday, This Week, Earlier
- Use `NotificationRouter` for tap navigation
- Remove manual `_syncAdminNotifications()` from initState (handled by provider)

## Data Flow Summary

### When notification is tapped (from system tray):
1. OS delivers tap → `_onNotificationTap()` callback
2. Notification marked as read in Hive
3. `NotificationRouter.navigate()` opens relevant screen
4. Next time HomeScreen builds, `NotificationProvider` reflects updated count

### When user returns to HomeScreen:
1. No need for manual `_updateNotificationCount()` — provider already has latest
2. Badge count updates reactively via `ref.watch`

### When user pulls to refresh in HistoryScreen:
1. `NotificationProvider.refresh()` called
2. Admin notification sync runs
3. Hive history reloaded
4. UI updates with new data and grouped dates

## Implementation Order

1. Update model (`notification_history_model.dart`) — add fields
2. Create provider (`notification_provider.dart`)
3. Create router (`notification_router.dart`)
4. Update notification service (`notification_service.dart`) — navigation on tap
5. Update admin sync service (`admin_notification_sync_service.dart`) — pass action fields
6. Update home screen (`home_screen.dart`) — use provider
7. Update notification dialog (`notification_dialog.dart`) — fix settings navigation
8. Update notification history screen (`notification_history_screen.dart`) — date groups + pull-to-refresh

## Test Plan

1. Verify unread badge updates live when notification is tapped
2. Verify "Go to Settings" in dialog navigates to Settings screen
3. Verify tapping notification history items navigates to correct screen
4. Verify pull-to-refresh syncs admin notifications
5. Verify date grouping works correctly
6. Verify provider state is consistent with Hive data
