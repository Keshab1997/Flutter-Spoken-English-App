import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
  }

  Future<void> showDailyWordNotification(String word, String meaning) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_word',
      'Word of the Day',
      channelDescription: 'Daily vocabulary word notification',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Word of the Day: $word',
      meaning,
      details,
    );
  }

  Future<void> showPracticeReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'practice_reminder',
      'Practice Reminder',
      channelDescription: 'Reminder to practice English daily',
      importance: Importance.defaultImportance,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      1001,
      'Time to Practice! 🎯',
      'Don\'t break your streak! Practice English for 5 minutes.',
      details,
    );
  }

  Future<void> showStreakReminder(int streak) async {
    const androidDetails = AndroidNotificationDetails(
      'streak_reminder',
      'Streak Reminder',
      channelDescription: 'Daily streak notification',
      importance: Importance.defaultImportance,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      1002,
      '🔥 $streak Day Streak!',
      'Amazing! Keep up your daily practice to maintain your streak.',
      details,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
