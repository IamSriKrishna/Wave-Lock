import 'package:flutter_test/flutter_test.dart';
import 'package:wakelock/features/events/data/models/event_model.dart';

void main() {
  test('reads old stored events without a started flag', () {
    final event = EventModel.fromMap({
      'id': 'event-1',
      'title': 'Focus block',
      'event_date': DateTime(2026, 11, 19).millisecondsSinceEpoch,
      'created_at': DateTime(2026, 11, 1).millisecondsSinceEpoch,
    });

    expect(event.isStarted, isFalse);
    expect(event.isCompleted, isFalse);
  });

  test('persists whether the event has started', () {
    final event = EventModel.fromMap({
      'id': 'event-1',
      'title': 'Focus block',
      'event_date': DateTime(2026, 11, 19).millisecondsSinceEpoch,
      'created_at': DateTime(2026, 11, 1).millisecondsSinceEpoch,
      'is_started': true,
    });

    expect(event.toMap()['is_started'], isTrue);
  });
}
