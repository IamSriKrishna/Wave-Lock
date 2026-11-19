import 'package:sembast/sembast.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_keys.dart';
import '../../../../core/database/database_stores.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final AppDatabase _appDatabase;

  UserRepositoryImpl({required this._appDatabase});

  @override
  Future<void> saveUser(UserEntity user) async {
    final database = await _appDatabase.database;

    final model = UserModel.fromEntity(user);

    await DatabaseStores.user
        .record(DatabaseKeys.currentUser)
        .put(database, model.toMap());
  }

  @override
  Future<UserEntity?> getUser() async {
    final database = await _appDatabase.database;

    final data = await DatabaseStores.user
        .record(DatabaseKeys.currentUser)
        .get(database);

    if (data == null) {
      return null;
    }

    return UserModel.fromMap(data);
  }

  @override
  Future<void> deleteUser() async {
    final database = await _appDatabase.database;

    await DatabaseStores.user.record(DatabaseKeys.currentUser).delete(database);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final database = await _appDatabase.database;

    final data = await DatabaseStores.settings
        .record(DatabaseKeys.onboardingCompleted)
        .get(database);

    return data?['value'] as bool? ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    final database = await _appDatabase.database;

    await DatabaseStores.settings.record(DatabaseKeys.onboardingCompleted).put(
      database,
      {'value': completed},
    );
  }
}
