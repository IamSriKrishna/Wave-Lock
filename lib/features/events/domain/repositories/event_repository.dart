import '../entities/event_entity.dart';

abstract class EventRepository {
  Future<List<EventEntity>> getEvents();

  Future<EventEntity?> getEventById(String id);

  Future<void> saveEvent(EventEntity event);

  Future<void> deleteEvent(String id);

  Future<void> saveEvents(List<EventEntity> events);
}
