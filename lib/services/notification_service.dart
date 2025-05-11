// lib/services/notification_service.dart
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) {
      print('NotificationService already initialized');
      return;
    }

    try {
      print('Initializing AwesomeNotifications');
      await AwesomeNotifications().initialize(
        null, // Default icon (uses app icon)
        [
          NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic Notifications',
            channelDescription: 'Notification channel for motivational quotes',
            defaultColor: Colors.blue,
            ledColor: Colors.white,
            importance: NotificationImportance.High,
            playSound: true,
          ),
          NotificationChannel(
            channelKey: 'pill_reminder_channel',
            channelName: 'Pill Reminders',
            channelDescription: 'Notifications for medication reminders',
            defaultColor: const Color(0xFF199A8E),
            ledColor: Colors.white,
            importance: NotificationImportance.High,
            playSound: true,
          ),
        ],
        debug: true, // Enable debug logs
      );

      print('Requesting notification permissions');
      bool isAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications();
      print('Notification permissions ${isAllowed ? 'granted' : 'denied'}');

      // Wait briefly to ensure channels are registered
      await Future.delayed(Duration(milliseconds: 500));

      _isInitialized = true;
      print('AwesomeNotifications initialized successfully');
    } catch (e) {
      print('Error initializing AwesomeNotifications: $e');
      rethrow;
    }
  }

  Future<bool> isNotificationAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  Future<void> showNotification(String title, String body) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          channelKey: 'basic_channel',
          title: title,
          body: body,
        ),
      );
      print('Notification shown: $title');
    } catch (e) {
      print('Error showing notification: $e');
      rethrow;
    }
  }

  Future<void> showQuoteNotification() async {
    // Note: This requires ApiService, which you may have in your app
    try {
      // If ApiService is not needed, replace with a static quote for testing
      const quote = 'Stay healthy and strong!';
      await showNotification('Daily Motivation', quote);
      print('Quote notification shown');
    } catch (e) {
      print('Error showing quote notification: $e');
    }
  }

  Future<void> schedulePillReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (!_isInitialized) {
      print('NotificationService not initialized, initializing now');
      await init();
    }

    try {
      print(
          'Scheduling pill reminder: id=$id, title=$title, time=$scheduledTime');
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'pill_reminder_channel',
          title: title,
          body: body,
          wakeUpScreen: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledTime,
          allowWhileIdle: true, // Allow notification even in Doze mode
          preciseAlarm: true, // Use exact alarm on Android 12+
        ),
      );
      print('Pill reminder scheduled successfully for $scheduledTime');
    } catch (e) {
      print('Error scheduling pill reminder: $e');
      rethrow;
    }
  }

  Future<void> cancelPillReminder(int id) async {
    try {
      await AwesomeNotifications().cancel(id);
      print('Pill reminder cancelled: id=$id');
    } catch (e) {
      print('Error cancelling pill reminder: $e');
    }
  }
}
