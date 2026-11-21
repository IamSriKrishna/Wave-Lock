import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock/core/services/notification_service.dart';
import 'package:wakelock/core/services/strict_mode_service.dart';
import 'package:wakelock/core/theme/app_theme_controller.dart';
import 'package:wakelock/features/events/domain/services/event_occurrence_engine.dart';
import 'package:wakelock/features/app_usage/data/repositories/daily_growth_progress_repository.dart';
import 'package:wakelock/features/app_usage/domain/services/app_usage_service.dart';
import 'package:wakelock/features/app_usage/domain/services/daily_growth_plan_generator.dart';
import 'package:wakelock/features/motivational_quotes/data/datasources/motivational_quote_remote_data_source.dart';
import 'package:wakelock/features/motivational_quotes/data/repositories/motivational_quote_repository_impl.dart';
import 'package:wakelock/features/motivational_quotes/domain/repositories/motivational_quote_repository.dart';
import 'package:wakelock/features/strict_mode/data/repositories/strict_mode_repository_impl.dart';
import 'package:wakelock/features/strict_mode/domain/repositories/strict_mode_repository.dart';
import 'package:wakelock/features/strict_mode/domain/services/app_selection_service.dart';
import 'package:wakelock/features/strict_mode/domain/services/strict_mode_management_service.dart';
import 'package:wakelock/features/strict_mode/presentation/bloc/strict_mode_bloc.dart';

import 'core/database/app_database.dart';

import 'features/onboarding/data/repositories/user_repository_impl.dart';
import 'features/onboarding/domain/repositories/user_repository.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';

import 'features/daily_missions/data/repositories/mission_repository_impl.dart';
import 'features/daily_missions/domain/repositories/mission_repository.dart';
import 'features/daily_missions/domain/services/mission_recommendation_engine.dart';
import 'features/daily_missions/presentation/bloc/mission_bloc.dart';

import 'features/gamification/data/repositories/progress_repository_impl.dart';
import 'features/gamification/domain/repositories/progress_repository.dart';
import 'features/gamification/domain/services/progress_reward_engine.dart';
import 'features/gamification/domain/services/achievement_engine.dart';
import 'features/gamification/presentation/bloc/gamification_bloc.dart';

import 'features/events/data/repositories/event_repository_impl.dart';
import 'features/events/domain/repositories/event_repository.dart';
import 'features/events/domain/services/event_reminder_scheduler.dart';
import 'features/events/domain/services/event_management_service.dart';
import 'features/events/presentation/bloc/event_bloc.dart';

import 'features/habits/data/repositories/habit_repository_impl.dart';
import 'features/habits/domain/repositories/habit_repository.dart';
import 'features/habits/domain/services/habit_analytics_engine.dart';
import 'features/habits/domain/services/habit_streak_engine.dart';
import 'features/habits/domain/services/habit_management_service.dart';
import 'features/habits/domain/services/habit_reminder_scheduler.dart';
import 'features/habits/domain/services/habit_reward_engine.dart';
import 'features/habits/presentation/bloc/habit_bloc.dart';

import 'features/pomodoro/data/repositories/pomodoro_repository_impl.dart';
import 'features/pomodoro/data/repositories/pomodoro_settings_repository_impl.dart';
import 'features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'features/pomodoro/domain/repositories/pomodoro_settings_repository.dart';
import 'features/pomodoro/domain/services/pomodoro_timer_engine.dart';
import 'features/pomodoro/presentation/bloc/pomodoro_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  getIt.registerLazySingleton<Uuid>(() => const Uuid());

  getIt.registerLazySingleton<StrictModeService>(() => StrictModeService());
  getIt.registerLazySingleton<AppThemeController>(
    () => AppThemeController(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<AppUsageService>(() => const AppUsageService());
  getIt.registerLazySingleton<DailyGrowthPlanGenerator>(
    () => const DailyGrowthPlanGenerator(),
  );
  getIt.registerLazySingleton<DailyGrowthProgressRepository>(
    () => DailyGrowthProgressRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://dummyjson.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    ),
  );

  getIt.registerLazySingleton<MotivationalQuoteRemoteDataSource>(
    () => MotivationalQuoteRemoteDataSource(getIt<Dio>()),
  );

  getIt.registerLazySingleton<MotivationalQuoteRepository>(
    () => MotivationalQuoteRepositoryImpl(
      getIt<MotivationalQuoteRemoteDataSource>(),
    ),
  );

  // Onboarding
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(appDatabase: getIt<AppDatabase>()),
  );

  getIt.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(repository: getIt<UserRepository>()),
  );

  // Daily Missions
  getIt.registerLazySingleton<MissionRecommendationEngine>(
    () => MissionRecommendationEngine(),
  );

  getIt.registerLazySingleton<MissionRepository>(
    () => MissionRepositoryImpl(appDatabase: getIt<AppDatabase>()),
  );

  // Gamification
  getIt.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ProgressRewardEngine>(
    () => ProgressRewardEngine(),
  );

  getIt.registerLazySingleton<AchievementEngine>(() => AchievementEngine());

  getIt.registerFactory<GamificationBloc>(
    () => GamificationBloc(progressRepository: getIt<ProgressRepository>()),
  );

  // Events
  getIt.registerLazySingleton<EventOccurrenceEngine>(
    () => EventOccurrenceEngine(),
  );

  getIt.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<EventManagementService>(
    () => EventManagementService(),
  );

  getIt.registerLazySingleton<EventReminderScheduler>(
    () => EventReminderScheduler(
      NotificationService.instance,
      getIt<EventOccurrenceEngine>(),
    ),
  );

  getIt.registerFactory<EventBloc>(
    () => EventBloc(
      eventRepository: getIt<EventRepository>(),
      eventManagementService: getIt<EventManagementService>(),
      reminderScheduler: getIt<EventReminderScheduler>(),
    ),
  );

  // Habits
  getIt.registerLazySingleton<HabitRewardEngine>(() => HabitRewardEngine());

  getIt.registerLazySingleton<HabitAnalyticsEngine>(
    () => HabitAnalyticsEngine(),
  );

  getIt.registerLazySingleton<HabitStreakEngine>(() => HabitStreakEngine());

  getIt.registerLazySingleton<HabitManagementService>(
    () => HabitManagementService(),
  );

  getIt.registerLazySingleton<HabitReminderScheduler>(
    () => HabitReminderScheduler(NotificationService.instance),
  );

  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerFactory<HabitBloc>(
    () => HabitBloc(
      habitRepository: getIt<HabitRepository>(),
      managementService: getIt<HabitManagementService>(),
      reminderScheduler: getIt<HabitReminderScheduler>(),
      streakEngine: getIt<HabitStreakEngine>(),
      rewardEngine: getIt<HabitRewardEngine>(),
      progressRepository: getIt<ProgressRepository>(),
      achievementEngine: getIt<AchievementEngine>(),
    ),
  );

  // Pomodoro
  getIt.registerLazySingleton<PomodoroTimerEngine>(() => PomodoroTimerEngine());

  getIt.registerLazySingleton<PomodoroSettingsRepository>(
    () => PomodoroSettingsRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PomodoroRepository>(
    () => PomodoroRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerFactory<PomodoroBloc>(
    () => PomodoroBloc(
      repository: getIt<PomodoroRepository>(),
      settingsRepository: getIt<PomodoroSettingsRepository>(),
      timerEngine: getIt<PomodoroTimerEngine>(),
      strictModeService: getIt<StrictModeService>(),
    ),
  );

  // Daily Mission BLoC
  getIt.registerFactory<MissionBloc>(
    () => MissionBloc(
      userRepository: getIt<UserRepository>(),
      missionRepository: getIt<MissionRepository>(),
      recommendationEngine: getIt<MissionRecommendationEngine>(),
      progressRepository: getIt<ProgressRepository>(),
      rewardEngine: getIt<ProgressRewardEngine>(),
      achievementEngine: getIt<AchievementEngine>(),
      strictModeRepository: getIt<StrictModeRepository>(),
      strictModeManagementService: getIt<StrictModeManagementService>(),
      strictModeService: getIt<StrictModeService>(),
    ),
  );

  // Strict Mode
  getIt.registerLazySingleton<StrictModeRepository>(
    () => StrictModeRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<AppSelectionService>(() => AppSelectionService());

  getIt.registerLazySingleton<StrictModeManagementService>(
    () => StrictModeManagementService(
      getIt<StrictModeRepository>(),
      getIt<Uuid>(),
    ),
  );

  getIt.registerFactory<StrictModeBloc>(
    () => StrictModeBloc(
      managementService: getIt<StrictModeManagementService>(),
      strictModeService: getIt<StrictModeService>(),
    ),
  );
}
