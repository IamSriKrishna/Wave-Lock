import 'package:equatable/equatable.dart';

import '../../domain/entities/event_entity.dart';

enum EventStatus { initial, loading, loaded, saving, failure }

class EventState extends Equatable {
  final EventStatus status;
  final List<EventEntity> events;
  final String? errorMessage;

  const EventState({
    this.status = EventStatus.initial,
    this.events = const [],
    this.errorMessage,
  });

  List<EventEntity> get upcomingEvents {
    final now = DateTime.now();

    return events.where((event) {
      return !event.isCompleted &&
          !event.eventDate.isBefore(DateTime(now.year, now.month, now.day));
    }).toList()..sort((a, b) => a.eventDate.compareTo(b.eventDate));
  }

  List<EventEntity> get completedEvents {
    return events.where((event) => event.isCompleted).toList();
  }

  EventState copyWith({
    EventStatus? status,
    List<EventEntity>? events,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EventState(
      status: status ?? this.status,
      events: events ?? this.events,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, events, errorMessage];
}
