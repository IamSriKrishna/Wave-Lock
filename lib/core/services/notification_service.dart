import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    final location = tz.getLocation(timezoneInfo.identifier);
    tz.setLocalLocation(location);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings: settings);

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) return false;

    final granted = await android.requestNotificationsPermission();

    return granted ?? false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'wakelock_events',
      'WakeLock Event Reminders',
      channelDescription: 'Notifications for your scheduled events',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() {
    return _notifications.pendingNotificationRequests();
  }

  Future<bool> requestExactAlarmPermission() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) return false;

    final granted = await android.requestExactAlarmsPermission();

    return granted ?? false;
  }

  Future<bool> requestFullScreenIntentPermission() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) return false;

    final granted = await android.requestFullScreenIntentPermission();

    return granted ?? false;
  }

  Future<bool> canScheduleExactAlarms() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) return false;

    return await android.canScheduleExactNotifications() ?? false;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    bool isEventAlarm = false,
    String? payload,
  }) async {
    if (!_initialized) {
      throw StateError('NotificationService is not initialized.');
    }

    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      throw ArgumentError('Notification date must be in the future.');
    }

    final androidDetails = AndroidNotificationDetails(
      isEventAlarm ? 'wakelock_event_alarms' : 'wakelock_events',
      isEventAlarm ? 'WakeLock Event Alarms' : 'WakeLock Event Reminders',
      channelDescription: isEventAlarm
          ? 'Alarms when scheduled events begin'
          : 'Notifications for your scheduled events',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      category: isEventAlarm ? AndroidNotificationCategory.alarm : null,
      fullScreenIntent: isEventAlarm,
    );

    final details = NotificationDetails(android: androidDetails);

    final scheduleMode = await canScheduleExactAlarms()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: scheduleMode,
      payload: payload,
    );
  }
}
