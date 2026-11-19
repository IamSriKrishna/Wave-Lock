import 'package:equatable/equatable.dart';

import '../../domain/entities/event_entity.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventEvent {
  const LoadEvents();
}

class CreateEvent extends EventEvent {
  final String title;
  final String description;
  final DateTime eventDate;
  final int? startTimeMinutes;
  final int? endTimeMinutes;
  final EventRecurrence recurrence;
  final DateTime? recurrenceEndDate;
  final int? reminderMinutesBefore;

  const CreateEvent({
    required this.title,
    this.description = '',
    required this.eventDate,
    this.startTimeMinutes,
    this.endTimeMinutes,
    this.recurrence = EventRecurrence.none,
    this.recurrenceEndDate,
    this.reminderMinutesBefore,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    eventDate,
    startTimeMinutes,
    endTimeMinutes,
    recurrence,
    recurrenceEndDate,
    reminderMinutesBefore,
  ];
}

class UpdateEvent extends EventEvent {
  final EventEntity event;

  const UpdateEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteEvent extends EventEvent {
  final String eventId;

  const DeleteEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class ToggleEventCompletion extends EventEvent {
  final String eventId;

  const ToggleEventCompletion(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class StartEvent extends EventEvent {
  final String eventId;

  const StartEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
