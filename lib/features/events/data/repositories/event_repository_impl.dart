import 'package:sembast/sembast.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_stores.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final AppDatabase appDatabase;

  EventRepositoryImpl(this.appDatabase);

  @override
  Future<List<EventEntity>> getEvents() async {
    final database = await appDatabase.database;

    final records = await DatabaseStores.events.find(database);

    return records.map((record) => EventModel.fromMap(record.value)).toList();
  }

  @override
  Future<EventEntity?> getEventById(String id) async {
    final database = await appDatabase.database;

    final data = await DatabaseStores.events.record(id).get(database);

    if (data == null) return null;

    return EventModel.fromMap(data);
  }

  @override
  Future<void> saveEvent(EventEntity event) async {
    final database = await appDatabase.database;

    final model = EventModel.fromEntity(event);

    await DatabaseStores.events.record(event.id).put(database, model.toMap());
  }

  @override
  Future<void> deleteEvent(String id) async {
    final database = await appDatabase.database;

    await DatabaseStores.events.record(id).delete(database);
  }

  @override
  Future<void> saveEvents(List<EventEntity> events) async {
    final database = await appDatabase.database;

    await database.transaction((transaction) async {
      await DatabaseStores.events.delete(transaction);

      for (final event in events) {
        final model = EventModel.fromEntity(event);

        await DatabaseStores.events
            .record(event.id)
            .put(transaction, model.toMap());
      }
    });
  }
}
