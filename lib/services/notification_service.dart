import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service de notifications locales pour les rappels de streak.
/// Local notification service for streak reminders.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initialise le plugin de notifications / Initialize notification plugin
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  /// Demande les permissions de notification / Request notification permissions
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true; // iOS demande automatiquement / iOS asks automatically
  }

  /// Programme un rappel quotidien pour protéger le streak.
  /// Schedule a daily reminder to protect the streak.
  static Future<void> scheduleDailyReminder({
    int hour = 20,
    int minute = 0,
    String title = 'Kana SRS',
    String body = 'Votre streak est en danger ! Révisez maintenant.',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'streak_reminder',
      'Rappel de streak',
      channelDescription: 'Rappel quotidien pour maintenir votre streak',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Notification quotidienne à l'heure spécifiée
    // Daily notification at specified time
    await _plugin.periodicallyShow(
      0,
      title,
      body,
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Annule toutes les notifications programmées / Cancel all scheduled notifications
  static Future<void> cancelAll() => _plugin.cancelAll();

  /// Affiche une notification immédiate / Show an immediate notification
  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 1,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'Général',
      channelDescription: 'Notifications générales',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }
}
