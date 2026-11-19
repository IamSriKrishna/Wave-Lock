import 'package:equatable/equatable.dart';

enum EventRecurrence { none, daily, weekly, monthly }

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final int? startTimeMinutes;
  final int? endTimeMinutes;

  final EventRecurrence recurrence;
  final DateTime? recurrenceEndDate;

  final int? reminderMinutesBefore;

  final bool isCompleted;
  final bool isStarted;
  final DateTime createdAt;

  const EventEntity({
    required this.id,
    required this.title,
    this.description = '',
    required this.eventDate,
    this.startTimeMinutes,
    this.endTimeMinutes,
    this.recurrence = EventRecurrence.none,
    this.recurrenceEndDate,
    this.reminderMinutesBefore,
    this.isCompleted = false,
    this.isStarted = false,
    required this.createdAt,
  });

  bool get hasTime => startTimeMinutes != null;

  bool get hasReminder => reminderMinutesBefore != null;

  EventEntity copyWith({
    String? title,
    String? description,
    DateTime? eventDate,
    int? startTimeMinutes,
    int? endTimeMinutes,
    EventRecurrence? recurrence,
    DateTime? recurrenceEndDate,
    int? reminderMinutesBefore,
    bool? isCompleted,
    bool? isStarted,
    bool clearStartTime = false,
    bool clearEndTime = false,
    bool clearRecurrenceEndDate = false,
    bool clearReminder = false,
  }) {
    return EventEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      startTimeMinutes: clearStartTime
          ? null
          : startTimeMinutes ?? this.startTimeMinutes,
      endTimeMinutes: clearEndTime
          ? null
          : endTimeMinutes ?? this.endTimeMinutes,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEndDate: clearRecurrenceEndDate
          ? null
          : recurrenceEndDate ?? this.recurrenceEndDate,
      reminderMinutesBefore: clearReminder
          ? null
          : reminderMinutesBefore ?? this.reminderMinutesBefore,
      isCompleted: isCompleted ?? this.isCompleted,
      isStarted: isStarted ?? this.isStarted,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    eventDate,
    startTimeMinutes,
    endTimeMinutes,
    recurrence,
    recurrenceEndDate,
    reminderMinutesBefore,
    isCompleted,
    isStarted,
    createdAt,
  ];
}
