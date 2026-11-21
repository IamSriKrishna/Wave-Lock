import 'package:flutter/foundation.dart';

import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/services/habit_alarm_platform_service.dart';
import '../../../../core/services/notification_service.dart';
import '../entities/habit_entity.dart';

class HabitReminderScheduler {
  final NotificationService _notificationService;

  HabitReminderScheduler(this._notificationService);

  Future<void> scheduleHabit(HabitEntity habit) async {
    await cancelHabit(habit);

    final timeMinutes = habit.scheduledTimeMinutes;
    if (!habit.isActive || timeMinutes == null) return;

    final now = tz.TZDateTime.now(tz.local);
    final weekdays =
        habit.scheduledWeekdays.isEmpty
              ? List<int>.generate(7, (index) => index + 1)
              : habit.scheduledWeekdays.toSet().toList()
          ..sort();

    for (final weekday in weekdays) {
      final id = _notificationId(habit.id, weekday);
      final payload = jsonEncode({
        'type': 'habit_alarm',
        'title': habit.title,
        'body': habit.description,
      });
      final body = habit.description.isEmpty
          ? 'It is time to work on your habit.'
          : habit.description;

      if (defaultTargetPlatform == TargetPlatform.android) {
        await HabitAlarmPlatformService.scheduleHabitAlarm(
          alarmId: id,
          title: 'Time for your habit: ${habit.title}',
          body: body,
          payload: payload,
          weekday: weekday,
          timeMinutes: timeMinutes,
        );
      } else {
        await _notificationService.scheduleNotification(
          id: id,
          title: 'Time for your habit: ${habit.title}',
          body: body,
          scheduledDate: _nextOccurrence(weekday, timeMinutes, now),
          isEventAlarm: true,
          payload: payload,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  Future<void> cancelHabit(HabitEntity habit) async {
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final alarmId = _notificationId(habit.id, weekday);
      if (defaultTargetPlatform == TargetPlatform.android) {
        await HabitAlarmPlatformService.cancelHabitAlarm(alarmId);
      }
      await _notificationService.cancelNotification(alarmId);
    }
  }

  tz.TZDateTime _nextOccurrence(
    int weekday,
    int timeMinutes,
    tz.TZDateTime now,
  ) {
    final hour = timeMinutes ~/ 60;
    final minute = timeMinutes % 60;

    for (var dayOffset = 0; dayOffset <= 7; dayOffset++) {
      final date = DateTime(now.year, now.month, now.day + dayOffset);
      final occurrence = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );

      if (occurrence.weekday == weekday && occurrence.isAfter(now)) {
        return occurrence;
      }
    }

    throw StateError(
      'Could not find the next occurrence for weekday $weekday.',
    );
  }

  int _notificationId(String habitId, int weekday) {
    var hash = 0x811c9dc5;

    for (final byte in '$habitId-$weekday'.codeUnits) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }

    return hash;
  }
}
