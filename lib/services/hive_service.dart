import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _favoritesBox = 'favorites';
  static const String _settingsBox = 'settings';
  static const String _historyBox = 'history';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_favoritesBox);
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_historyBox);
  }

  static Box get _favorites => Hive.box(_favoritesBox);
  static Box get _settings => Hive.box(_settingsBox);
  static Box get _history => Hive.box(_historyBox);

  // Favorites
  static Future<void> addFavorite(String wordId) async {
    final favorites = _favorites.get('wordIds', defaultValue: <String>[]) as List<String>;
    if (!favorites.contains(wordId)) {
      favorites.add(wordId);
      await _favorites.put('wordIds', favorites);
    }
  }

  static Future<void> removeFavorite(String wordId) async {
    final favorites = _favorites.get('wordIds', defaultValue: <String>[]) as List<String>;
    favorites.remove(wordId);
    await _favorites.put('wordIds', favorites);
  }

  static List<String> getFavorites() {
    return _favorites.get('wordIds', defaultValue: <String>[]) as List<String>;
  }

  static bool isFavorite(String wordId) {
    return getFavorites().contains(wordId);
  }

  // Settings
  static Future<void> setDarkMode(bool value) async {
    await _settings.put('darkMode', value);
  }

  static bool isDarkMode() {
    return _settings.get('darkMode', defaultValue: false) as bool;
  }

  static Future<void> setNotificationEnabled(bool value) async {
    await _settings.put('notifications', value);
  }

  static bool isNotificationEnabled() {
    return _settings.get('notifications', defaultValue: true) as bool;
  }

  // History
  static Future<void> addToHistory(String lessonId) async {
    final history = _history.get('lessonIds', defaultValue: <String>[]) as List<String>;
    history.remove(lessonId);
    history.insert(0, lessonId);
    if (history.length > 50) history.removeLast();
    await _history.put('lessonIds', history);
  }

  static List<String> getHistory() {
    return _history.get('lessonIds', defaultValue: <String>[]) as List<String>;
  }
}
