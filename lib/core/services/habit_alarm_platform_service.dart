import 'package:flutter/services.dart';

class HabitAlarmPlatformService {
  HabitAlarmPlatformService._();

  static const MethodChannel _channel = MethodChannel(
    'com.wakelock/habit_alarm_overlay',
  );

  static void initialize({
    required void Function(Map<String, dynamic> alarm) onAlarmLaunched,
  }) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'alarmLaunched' &&
          call.arguments is Map<Object?, Object?>) {
        onAlarmLaunched(
          Map<String, dynamic>.from(call.arguments as Map<Object?, Object?>),
        );
      }
    });
  }

  static Future<bool> canDrawOverlays() async {
    return await _channel.invokeMethod<bool>('canDrawOverlays') ?? false;
  }

  static Future<void> requestOverlayPermission() {
    return _channel.invokeMethod<void>('requestOverlayPermission');
  }

  static Future<Map<String, dynamic>?> consumeLaunchAlarm() async {
    final alarm = await _channel.invokeMapMethod<Object?, Object?>(
      'consumeLaunchAlarm',
    );
    return alarm == null ? null : Map<String, dynamic>.from(alarm);
  }

  static Future<void> scheduleHabitAlarm({
    required int alarmId,
    required String title,
    required String body,
    required String payload,
    required int weekday,
    required int timeMinutes,
  }) {
    return _channel.invokeMethod<void>('scheduleHabitAlarm', {
      'alarmId': alarmId,
      'title': title,
      'body': body,
      'payload': payload,
      'weekday': weekday,
      'timeMinutes': timeMinutes,
    });
  }

  static Future<void> cancelHabitAlarm(int alarmId) {
    return _channel.invokeMethod<void>('cancelHabitAlarm', {
      'alarmId': alarmId,
    });
  }

  static Future<void> snoozeHabitAlarm({
    required int alarmId,
    required String title,
    required String body,
    required String payload,
  }) {
    return _channel.invokeMethod<void>('snoozeHabitAlarm', {
      'alarmId': alarmId,
      'title': title,
      'body': body,
      'payload': payload,
    });
  }

  static Future<void> stopAlarmSound() {
    return _channel.invokeMethod<void>('stopAlarmSound');
  }
}
