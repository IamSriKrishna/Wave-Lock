import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'app_database.dart';
import 'database_stores.dart';

Future<void> testDatabasePersistence() async {
  final database = await AppDatabase.instance.database;

  const testKey = 'lesson_2_test_record';

  try {
    // CREATE
    await DatabaseStores.user.record(testKey).put(database, {
      'name': 'WakeLock Test',
      'status': 'working',
    });

    // READ
    final result = await DatabaseStores.user.record(testKey).get(database);

    assert(result != null);
    assert(result!['name'] == 'WakeLock Test');

    debugPrint('CREATE: SUCCESS');
    debugPrint('READ: SUCCESS');
    debugPrint('DATA: $result');

    // UPDATE
    await DatabaseStores.user.record(testKey).put(database, {
      'name': 'WakeLock Updated',
      'status': 'working',
    });

    final updated = await DatabaseStores.user.record(testKey).get(database);

    assert(updated?['name'] == 'WakeLock Updated');

    debugPrint('UPDATE: SUCCESS');

    // DELETE
    await DatabaseStores.user.record(testKey).delete(database);

    final deleted = await DatabaseStores.user.record(testKey).get(database);

    assert(deleted == null);

    debugPrint('DELETE: SUCCESS');
    debugPrint('DATABASE TEST PASSED');
  } finally {
    // Ensure temporary test data is removed.
    await DatabaseStores.user.record(testKey).delete(database);
  }
}
