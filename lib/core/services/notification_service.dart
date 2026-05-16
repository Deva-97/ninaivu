import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'renewal_reminders';
  static const String _channelName = 'Renewal Reminders';
  static const String _channelDescription =
      'Insurance policy renewal reminder notifications';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    try {
      tz_data.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped. payload=${details.payload}');
        },
      );

      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );

      _isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('NotificationService init failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<bool> requestPermissions() async {
    try {
      if (!_isInitialized) {
        await init();
      }

      final androidGranted =
          await _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          true;

      final iosGranted =
          await _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          true;

      final macosGranted =
          await _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          true;

      return androidGranted && iosGranted && macosGranted;
    } catch (e, stackTrace) {
      debugPrint('Notification permission request failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> scheduleReminder({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        await init();
      }

      if (!scheduledDateTime.isAfter(DateTime.now())) {
        debugPrint(
          'Skipping notification $notificationId because scheduled time is in the past.',
        );
        return;
      }

      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDateTime.toUtc(), tz.UTC),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to schedule reminder $notificationId: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> cancelReminder(int notificationId) async {
    try {
      if (!_isInitialized) {
        await init();
      }
      await _notificationsPlugin.cancel(id: notificationId);
    } catch (e, stackTrace) {
      debugPrint('Failed to cancel reminder $notificationId: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> cancelAll() async {
    try {
      if (!_isInitialized) {
        await init();
      }
      await _notificationsPlugin.cancelAll();
    } catch (e, stackTrace) {
      debugPrint('Failed to cancel all reminders: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
