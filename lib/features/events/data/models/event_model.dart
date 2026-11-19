import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    super.description,
    required super.eventDate,
    super.startTimeMinutes,
    super.endTimeMinutes,
    super.recurrence,
    super.recurrenceEndDate,
    super.reminderMinutesBefore,
    super.isCompleted,
    super.isStarted,
    required super.createdAt,
  });

  factory EventModel.fromEntity(EventEntity entity) {
    return EventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      eventDate: entity.eventDate,
      startTimeMinutes: entity.startTimeMinutes,
      endTimeMinutes: entity.endTimeMinutes,
      recurrence: entity.recurrence,
      recurrenceEndDate: entity.recurrenceEndDate,
      reminderMinutesBefore: entity.reminderMinutesBefore,
      isCompleted: entity.isCompleted,
      isStarted: entity.isStarted,
      createdAt: entity.createdAt,
    );
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      eventDate: DateTime.fromMillisecondsSinceEpoch(map['event_date'] as int),
      startTimeMinutes: map['start_time_minutes'] as int?,
      endTimeMinutes: map['end_time_minutes'] as int?,
      recurrence: EventRecurrence.values.firstWhere(
        (value) => value.name == map['recurrence'],
        orElse: () => EventRecurrence.none,
      ),
      recurrenceEndDate: map['recurrence_end_date'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['recurrence_end_date'] as int,
            ),
      reminderMinutesBefore: map['reminder_minutes_before'] as int?,
      isCompleted: map['is_completed'] as bool? ?? false,
      isStarted: map['is_started'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate.millisecondsSinceEpoch,
      'start_time_minutes': startTimeMinutes,
      'end_time_minutes': endTimeMinutes,
      'recurrence': recurrence.name,
      'recurrence_end_date': recurrenceEndDate?.millisecondsSinceEpoch,
      'reminder_minutes_before': reminderMinutesBefore,
      'is_completed': isCompleted,
      'is_started': isStarted,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
