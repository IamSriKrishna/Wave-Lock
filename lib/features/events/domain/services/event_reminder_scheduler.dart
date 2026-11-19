import 'package:timezone/timezone.dart' as tz;

import '../../../../core/services/notification_service.dart';
import '../entities/event_entity.dart';
import 'event_occurrence_engine.dart';

class EventReminderScheduler {
  final NotificationService _notificationService;
  final EventOccurrenceEngine _occurrenceEngine;

  EventReminderScheduler(this._notificationService, this._occurrenceEngine);

  Future<void> scheduleEvent(EventEntity event) async {
    await cancelEvent(event);

    if (event.isCompleted || event.startTimeMinutes == null) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);

    final occurrences = _occurrenceEngine.generateOccurrences(
      event: event,
      from: now,
      to: now.add(const Duration(days: 30)),
    );

    for (final occurrence in occurrences) {
      final eventDateTime = DateTime(
        occurrence.year,
        occurrence.month,
        occurrence.day,
      ).add(Duration(minutes: event.startTimeMinutes!));

      if (eventDateTime.isAfter(now)) {
        await _notificationService.scheduleNotification(
          id: _notificationId('${event.id}-start', occurrence),
          title: 'Starting now: ${event.title}',
          body: event.description.isEmpty
              ? 'Your event is starting now.'
              : event.description,
          scheduledDate: tz.TZDateTime.from(eventDateTime, tz.local),
          isEventAlarm: true,
        );
      }

      final reminderMinutesBefore = event.reminderMinutesBefore;
      if (reminderMinutesBefore == null) continue;

      final reminderDateTime = eventDateTime.subtract(
        Duration(minutes: reminderMinutesBefore),
      );
      if (!reminderDateTime.isAfter(now)) continue;

      await _notificationService.scheduleNotification(
        id: _notificationId(event.id, occurrence),
        title: 'Upcoming: ${event.title}',
        body: event.description.isEmpty
            ? 'Your event is starting soon.'
            : event.description,
        scheduledDate: tz.TZDateTime.from(reminderDateTime, tz.local),
      );
    }
  }

  Future<void> cancelEvent(EventEntity event) async {
    final now = tz.TZDateTime.now(tz.local);

    final occurrences = _occurrenceEngine.generateOccurrences(
      event: event,
      from: now,
      to: now.add(const Duration(days: 30)),
    );

    for (final occurrence in occurrences) {
      await _notificationService.cancelNotification(
        _notificationId(event.id, occurrence),
      );
      await _notificationService.cancelNotification(
        _notificationId('${event.id}-start', occurrence),
      );
    }
  }

  int _notificationId(String eventId, DateTime occurrence) {
    // Stable FNV-1a hash: same event/date always produces the same ID.
    var hash = 0x811c9dc5;

    final value =
        '$eventId-${occurrence.year}-${occurrence.month}-${occurrence.day}';

    for (final byte in value.codeUnits) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }

    return hash;
  }
}
