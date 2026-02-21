import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

/// Point d'entrée de l'application Kana SRS.
/// Entry point for Kana SRS application.
///
/// Initialise :
/// 1. Hive (base de données locale)
/// 2. Notifications locales
/// 3. Lance l'app avec Riverpod
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la base de données Hive / Initialize Hive database
  await DatabaseService.init();

  // Initialiser les notifications / Initialize notifications
  await NotificationService.init();

  // Programmer le rappel quotidien si streak actif
  // Schedule daily reminder if streak is active
  final stats = DatabaseService.getUserStats();
  if (stats.currentStreak > 0) {
    await NotificationService.requestPermission();
    await NotificationService.scheduleDailyReminder();
  }

  runApp(
    const ProviderScope(
      child: KanaSrsApp(),
    ),
  );
}
