import 'package:sembast/sembast.dart';

class DatabaseStores {
  DatabaseStores._();

  static final user = stringMapStoreFactory.store('user_store');

  static final goals = stringMapStoreFactory.store('goals_store');

  static final alarms = stringMapStoreFactory.store('alarm_store');

  static final events = stringMapStoreFactory.store('events_store');

  static final dailyTasks = stringMapStoreFactory.store('daily_tasks_store');

  static final strictMode = stringMapStoreFactory.store('strict_mode_store');

  static final pomodoro = stringMapStoreFactory.store('pomodoro_store');

  static final habits = stringMapStoreFactory.store('habits_store');

  static final settings = stringMapStoreFactory.store('settings_store');
  
  static final gamification = stringMapStoreFactory.store('gamification_store');
}
