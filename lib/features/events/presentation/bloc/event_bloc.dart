import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/event_repository.dart';
import '../../domain/services/event_management_service.dart';
import '../../domain/services/event_reminder_scheduler.dart';

import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository eventRepository;
  final EventManagementService eventManagementService;
  final EventReminderScheduler _reminderScheduler;

  EventBloc({
    required this.eventRepository,
    required this.eventManagementService,
    required this._reminderScheduler,
  }) : super(const EventState()) {
    on<LoadEvents>(_onLoadEvents);
    on<CreateEvent>(_onCreateEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<ToggleEventCompletion>(_onToggleCompletion);
    on<StartEvent>(_onStartEvent);
  }

  // LOAD EVENTS
  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    emit(state.copyWith(status: EventStatus.loading, clearError: true));

    try {
      final events = await eventRepository.getEvents();

      emit(state.copyWith(status: EventStatus.loaded, events: events));
    } catch (error) {
      emit(
        state.copyWith(
          status: EventStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // CREATE EVENT
  Future<void> _onCreateEvent(
    CreateEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(state.copyWith(status: EventStatus.saving, clearError: true));

    try {
      final newEvent = eventManagementService.createEvent(
        title: event.title,
        description: event.description,
        eventDate: event.eventDate,
        startTimeMinutes: event.startTimeMinutes,
        endTimeMinutes: event.endTimeMinutes,
        recurrence: event.recurrence,
        recurrenceEndDate: event.recurrenceEndDate,
        reminderMinutesBefore: event.reminderMinutesBefore,
      );

      await eventRepository.saveEvent(newEvent);
      await _reminderScheduler.scheduleEvent(newEvent);

      final updatedEvents = [...state.events, newEvent];

      emit(state.copyWith(status: EventStatus.loaded, events: updatedEvents));
    } catch (error) {
      emit(
        state.copyWith(
          status: EventStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // UPDATE EVENT
  Future<void> _onUpdateEvent(
    UpdateEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(state.copyWith(status: EventStatus.saving, clearError: true));

    try {
      await eventRepository.saveEvent(event.event);
      await _reminderScheduler.scheduleEvent(event.event);

      final updatedEvents = state.events.map((item) {
        return item.id == event.event.id ? event.event : item;
      }).toList();

      emit(state.copyWith(status: EventStatus.loaded, events: updatedEvents));
    } catch (error) {
      emit(
        state.copyWith(
          status: EventStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // DELETE EVENT
  Future<void> _onDeleteEvent(
    DeleteEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(state.copyWith(status: EventStatus.saving, clearError: true));

    try {
      final existingEvent = state.events.firstWhere(
        (item) => item.id == event.eventId,
      );

      await _reminderScheduler.cancelEvent(existingEvent);
      await eventRepository.deleteEvent(event.eventId);

      final updatedEvents = state.events
          .where((item) => item.id != event.eventId)
          .toList();

      emit(state.copyWith(status: EventStatus.loaded, events: updatedEvents));
    } catch (error) {
      emit(
        state.copyWith(
          status: EventStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // TOGGLE EVENT COMPLETION
  Future<void> _onToggleCompletion(
    ToggleEventCompletion event,
    Emitter<EventState> emit,
  ) async {
    try {
      final existingEvent = state.events.firstWhere(
        (item) => item.id == event.eventId,
      );

      final updatedEvent = eventManagementService.toggleCompletion(
        existingEvent,
      );

      await eventRepository.saveEvent(updatedEvent);

      if (updatedEvent.isCompleted) {
        await _reminderScheduler.cancelEvent(updatedEvent);
      } else {
        await _reminderScheduler.scheduleEvent(updatedEvent);
      }

      final updatedEvents = state.events.map((item) {
        return item.id == updatedEvent.id ? updatedEvent : item;
      }).toList();

      emit(state.copyWith(status: EventStatus.loaded, events: updatedEvents));
    } catch (error) {
      emit(
        state.copyWith(
          status: EventStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onStartEvent(StartEvent event, Emitter<EventState> emit) async {
    try {
      final existingEvent = state.events.firstWhere(
        (item) => item.id == event.eventId,
      );
      final startedEvent = eventManagementService.startEvent(existingEvent);

      await eventRepository.saveEvent(startedEvent);

      final updatedEvents = state.events.map((item) {
        return item.id == startedEvent.id ? startedEvent : item;
      }).toList();

      emit(state.copyWith(status: EventStatus.loaded, events: updatedEvents));
    } catch (error) {
      emit(
        state.copyWith(
          status: EventStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
