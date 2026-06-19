import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return HiveService.isDarkMode() ? ThemeMode.dark : ThemeMode.light;
});
