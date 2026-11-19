import 'package:get_it/get_it.dart';
import 'package:wakelock/core/services/notification_service.dart';
import 'package:wakelock/core/services/strict_mode_service.dart';
import 'package:wakelock/features/events/domain/services/event_occurrence_engine.dart';

import 'core/database/app_database.dart';

import 'features/onboarding/data/repositories/user_repository_impl.dart';
import 'features/onboarding/domain/repositories/user_repository.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/daily_missions/data/repositories/mission_repository_impl.dart';
import 'features/daily_missions/domain/repositories/mission_repository.dart';
import 'features/daily_missions/domain/services/mission_recommendation_engine.dart';
import 'features/gamification/domain/services/progress_reward_engine.dart';
import 'features/daily_missions/presentation/bloc/mission_bloc.dart';
import 'features/events/domain/services/event_reminder_scheduler.dart';
import 'features/habits/domain/services/habit_analytics_engine.dart';
import 'features/gamification/data/repositories/progress_repository_impl.dart';
import 'features/events/domain/services/event_management_service.dart';
import 'features/gamification/domain/repositories/progress_repository.dart';
import 'features/gamification/presentation/bloc/gamification_bloc.dart';
import 'features/events/presentation/bloc/event_bloc.dart';
import 'features/pomodoro/data/repositories/pomodoro_repository_impl.dart';
import 'features/events/domain/repositories/event_repository.dart';
import 'features/events/data/repositories/event_repository_impl.dart';
import 'features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'features/pomodoro/domain/services/pomodoro_timer_engine.dart';
import 'features/pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'features/gamification/domain/services/achievement_engine.dart';
import 'features/pomodoro/data/repositories/pomodoro_settings_repository_impl.dart';
import 'features/pomodoro/domain/repositories/pomodoro_settings_repository.dart';
import 'features/habits/domain/repositories/habit_repository.dart';
import 'features/habits/data/repositories/habit_repository_impl.dart';
import 'features/habits/domain/services/habit_streak_engine.dart';
import 'features/habits/presentation/bloc/habit_bloc.dart';
import 'features/habits/domain/services/habit_management_service.dart';
import 'features/habits/domain/services/habit_reward_engine.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  getIt.registerLazySingleton<StrictModeService>(() => StrictModeService());

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(appDatabase: getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<MissionRecommendationEngine>(
    () => MissionRecommendationEngine(),
  );

  getIt.registerLazySingleton<HabitRewardEngine>(() => HabitRewardEngine());

  getIt.registerLazySingleton<EventOccurrenceEngine>(
    () => EventOccurrenceEngine(),
  );

  getIt.registerLazySingleton<HabitAnalyticsEngine>(
    () => HabitAnalyticsEngine(),
  );

  getIt.registerLazySingleton<EventReminderScheduler>(
    () => EventReminderScheduler(
      NotificationService.instance,
      getIt<EventOccurrenceEngine>(),
    ),
  );

  getIt.registerFactory(
    () => GamificationBloc(progressRepository: getIt<ProgressRepository>()),
  );

  getIt.registerLazySingleton<HabitStreakEngine>(() => HabitStreakEngine());

  getIt.registerLazySingleton<EventManagementService>(
    () => EventManagementService(),
  );

  getIt.registerLazySingleton<HabitManagementService>(
    () => HabitManagementService(),
  );

  getIt.registerFactory(
    () => EventBloc(
      eventRepository: getIt<EventRepository>(),
      eventManagementService: getIt<EventManagementService>(),
      reminderScheduler: getIt<EventReminderScheduler>(),
    ),
  );

  getIt.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PomodoroTimerEngine>(() => PomodoroTimerEngine());

  getIt.registerFactory<PomodoroBloc>(
    () => PomodoroBloc(
      repository: getIt<PomodoroRepository>(),
      settingsRepository: getIt<PomodoroSettingsRepository>(),
      timerEngine: getIt<PomodoroTimerEngine>(),
      strictModeService: getIt<StrictModeService>(),
    ),
  );

  getIt.registerLazySingleton<PomodoroSettingsRepository>(
    () => PomodoroSettingsRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PomodoroRepository>(
    () => PomodoroRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<MissionRepository>(
    () => MissionRepositoryImpl(appDatabase: getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerFactory<HabitBloc>(
    () => HabitBloc(
      habitRepository: getIt<HabitRepository>(),
      managementService: getIt<HabitManagementService>(),
      streakEngine: getIt<HabitStreakEngine>(),
      rewardEngine: getIt<HabitRewardEngine>(),
      progressRepository: getIt<ProgressRepository>(),
      achievementEngine: getIt<AchievementEngine>(),
    ),
  );

  getIt.registerLazySingleton<AchievementEngine>(() => AchievementEngine());

  getIt.registerFactory<MissionBloc>(
    () => MissionBloc(
      userRepository: getIt<UserRepository>(),
      missionRepository: getIt<MissionRepository>(),
      recommendationEngine: getIt<MissionRecommendationEngine>(),
      progressRepository: getIt<ProgressRepository>(),
      rewardEngine: getIt<ProgressRewardEngine>(),
      achievementEngine: getIt<AchievementEngine>(),
    ),
  );

  getIt.registerLazySingleton<ProgressRewardEngine>(
    () => ProgressRewardEngine(),
  );

  getIt.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(repository: getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(getIt<AppDatabase>()),
  );
}
