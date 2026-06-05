// lib/services/notification_service.dart

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
      // Initialize timezone data
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(_resolveLocalTimezone()));

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

  /// Resolve the device's local timezone name.
  /// Falls back to UTC if detection fails.
  String _resolveLocalTimezone() {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      // Try to find a timezone matching the device offset
      // This is a best-effort approach; the timezone name from the device
      // isn't directly available without a platform channel.
      // We use the offset to pick a representative timezone.
      final hours = offset.inHours;
      final minutes = offset.inMinutes % 60;

      // Common timezone mappings by offset
      final Map<String, String> offsetToTimezone = {
        '0:0': 'UTC',
        '1:0': 'Africa/Lagos',
        '2:0': 'Africa/Cairo',
        '3:0': 'Africa/Nairobi',
        '3:30': 'Asia/Tehran',
        '4:0': 'Asia/Dubai',
        '5:0': 'Asia/Karachi',
        '5:30': 'Asia/Kolkata',
        '5:45': 'Asia/Kathmandu',
        '6:0': 'Asia/Dhaka',
        '7:0': 'Asia/Bangkok',
        '8:0': 'Asia/Singapore',
        '9:0': 'Asia/Tokyo',
        '9:30': 'Australia/Darwin',
        '10:0': 'Australia/Sydney',
        '11:0': 'Pacific/Noumea',
        '12:0': 'Pacific/Auckland',
        '-1:0': 'Atlantic/Azores',
        '-2:0': 'America/Noronha',
        '-3:0': 'America/Sao_Paulo',
        '-4:0': 'America/New_York',
        '-5:0': 'America/Chicago',
        '-6:0': 'America/Denver',
        '-7:0': 'America/Los_Angeles',
        '-8:0': 'America/Anchorage',
        '-9:0': 'America/Adak',
        '-10:0': 'Pacific/Honolulu',
      };

      final key = '$hours:${minutes.abs()}';
      return offsetToTimezone[key] ?? 'UTC';
    } catch (_) {
      return 'UTC';
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

  /// Compute the next occurrence of [hour]:[minute] in the device's local timezone.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, stack) {
      FirebaseCrashlytics.instance
          .recordError(e, stack, reason: 'Failed to schedule notification $id');
    }
  }
}
