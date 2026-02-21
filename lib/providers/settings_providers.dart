import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/database_service.dart';

/// Notifier pour le mode sombre / Dark mode notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier()
      : super(
          DatabaseService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        );

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    await DatabaseService.setDarkMode(!isDark);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await DatabaseService.setDarkMode(mode == ThemeMode.dark);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Provider pour la clé API Gemini / Gemini API key provider
class GeminiKeyNotifier extends StateNotifier<String?> {
  GeminiKeyNotifier() : super(DatabaseService.geminiApiKey);

  Future<void> setKey(String key) async {
    await DatabaseService.setGeminiApiKey(key);
    state = key;
  }
}

final geminiKeyProvider =
    StateNotifierProvider<GeminiKeyNotifier, String?>((ref) {
  return GeminiKeyNotifier();
});
