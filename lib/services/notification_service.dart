// lib/services/notification_service.dart

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _reminderEnabledKey = 'meal_reminders_enabled';

  Future<void> init() async {
    try {
      // Initialize local notifications
      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(initSettings);

      // Request FCM permissions (iOS)
      if (Platform.isIOS) {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Set up foreground message handling
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } catch (e, stack) {
      FirebaseCrashlytics.instance
          .recordError(e, stack, reason: 'Notification init failed');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nutrilens_general',
            'General',
            channelDescription: 'General notifications',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> requestPermission() async {
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    // Android 13+ notification permission
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> enableMealReminders() async {
    await requestPermission();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, true);
    await _scheduleMealReminders();
  }

  Future<void> disableMealReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, false);
    await _localNotifications.cancelAll();
  }

  Future<bool> areMealRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? false;
  }

  Future<void> _scheduleMealReminders() async {
    // Cancel existing reminders
    await _localNotifications.cancelAll();

    // Schedule breakfast reminder (8:00 AM)
    await _scheduleDaily(
      id: 1,
      title: 'Good morning!',
      body: 'Don\'t forget to log your breakfast.',
      hour: 8,
      minute: 0,
    );

    // Schedule lunch reminder (12:30 PM)
    await _scheduleDaily(
      id: 2,
      title: 'Lunchtime!',
      body: 'Remember to track your lunch.',
      hour: 12,
      minute: 30,
    );

    // Schedule dinner reminder (7:00 PM)
    await _scheduleDaily(
      id: 3,
      title: 'Dinner time!',
      body: 'Log your dinner to stay on track.',
      hour: 19,
      minute: 0,
    );

    // Schedule water reminder (3:00 PM)
    await _scheduleDaily(
      id: 4,
      title: 'Stay hydrated!',
      body: 'Have you been drinking enough water today?',
      hour: 15,
      minute: 0,
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      await _localNotifications.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.daily,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nutrilens_reminders',
            'Meal Reminders',
            channelDescription: 'Daily meal tracking reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e, stack) {
      FirebaseCrashlytics.instance
          .recordError(e, stack, reason: 'Failed to schedule notification $id');
    }
  }
}
