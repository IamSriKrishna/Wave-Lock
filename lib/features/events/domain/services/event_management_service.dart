import 'package:uuid/uuid.dart';

import '../entities/event_entity.dart';

class EventManagementService {
  final Uuid _uuid = const Uuid();

  EventEntity createEvent({
    required String title,
    String description = '',
    required DateTime eventDate,
    int? startTimeMinutes,
    int? endTimeMinutes,
    EventRecurrence recurrence = EventRecurrence.none,
    DateTime? recurrenceEndDate,
    int? reminderMinutesBefore,
  }) {
    final cleanTitle = title.trim();

    if (cleanTitle.isEmpty) {
      throw ArgumentError('Event title cannot be empty.');
    }

    if (startTimeMinutes != null &&
        (startTimeMinutes < 0 || startTimeMinutes >= 1440)) {
      throw ArgumentError('Invalid event start time.');
    }

    if (endTimeMinutes != null &&
        (endTimeMinutes < 0 || endTimeMinutes >= 1440)) {
      throw ArgumentError('Invalid event end time.');
    }

    if (startTimeMinutes != null &&
        endTimeMinutes != null &&
        endTimeMinutes <= startTimeMinutes) {
      throw ArgumentError('End time must be after start time.');
    }

    if (reminderMinutesBefore != null && reminderMinutesBefore < 0) {
      throw ArgumentError('Reminder duration cannot be negative.');
    }

    if (recurrenceEndDate != null && recurrenceEndDate.isBefore(eventDate)) {
      throw ArgumentError('Recurrence end date cannot be before event date.');
    }

    return EventEntity(
      id: _uuid.v4(),
      title: cleanTitle,
      description: description.trim(),
      eventDate: DateTime(eventDate.year, eventDate.month, eventDate.day),
      startTimeMinutes: startTimeMinutes,
      endTimeMinutes: endTimeMinutes,
      recurrence: recurrence,
      recurrenceEndDate: recurrenceEndDate,
      reminderMinutesBefore: reminderMinutesBefore,
      createdAt: DateTime.now(),
    );
  }

  EventEntity toggleCompletion(EventEntity event) {
    return event.copyWith(isCompleted: !event.isCompleted);
  }
}
