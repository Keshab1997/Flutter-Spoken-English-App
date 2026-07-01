import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_history_model.dart';
import '../services/hive_service.dart';
import '../services/admin_notification_sync_service.dart';

class NotificationState {
  final int unreadCount;
  final List<NotificationHistoryItem> notifications;
  final bool isLoading;
  final int? newSyncCount;

  const NotificationState({
    this.unreadCount = 0,
    this.notifications = const [],
    this.isLoading = false,
    this.newSyncCount,
  });

  NotificationState copyWith({
    int? unreadCount,
    List<NotificationHistoryItem>? notifications,
    bool? isLoading,
    int? newSyncCount,
    bool clearNewSyncCount = false,
  }) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      newSyncCount: clearNewSyncCount ? null : newSyncCount ?? this.newSyncCount,
    );
  }
}

class NotificationStateNotifier extends StateNotifier<NotificationState> {
  NotificationStateNotifier() : super(const NotificationState()) {
    _load();
  }

  void _load() {
    final history = HiveService.getNotificationHistory();
    final items = history.map((json) => NotificationHistoryItem.fromJson(json)).toList();
    final unread = items.where((n) => !n.isRead).length;
    state = NotificationState(unreadCount: unread, notifications: items);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    int? added;
    try {
      added = await AdminNotificationSyncService.syncLatest();
    } catch (_) {}
    _load();
    state = state.copyWith(isLoading: false, newSyncCount: added);
  }

  Future<void> markAsRead(String id) async {
    await HiveService.markNotificationAsRead(id);
    _load();
  }

  Future<void> markAllAsRead() async {
    await HiveService.markAllNotificationsAsRead();
    _load();
  }

  Future<void> deleteNotification(String id) async {
    await HiveService.deleteNotification(id);
    _load();
  }

  Future<void> clearAll() async {
    await HiveService.clearNotificationHistory();
    _load();
  }
}

final notificationStateProvider = StateNotifierProvider<NotificationStateNotifier, NotificationState>((ref) {
  return NotificationStateNotifier();
});
