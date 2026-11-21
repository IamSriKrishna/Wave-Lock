import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakelock/core/services/habit_alarm_platform_service.dart';
import 'package:wakelock/core/services/notification_service.dart';
import 'package:wakelock/features/events/domain/repositories/event_repository.dart';
import 'package:wakelock/features/events/domain/services/event_reminder_scheduler.dart';
import 'package:wakelock/features/habits/domain/repositories/habit_repository.dart';
import 'package:wakelock/features/habits/domain/services/habit_reminder_scheduler.dart';
import 'package:wakelock/features/habits/presentation/pages/habit_alarm_page.dart';

import 'core/router/app_start_gate.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_controller.dart';
import 'injection_container.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
Map<String, dynamic>? _pendingAlarmResponse;

void _openHabitAlarmData(Map<String, dynamic> data) {
  final title = data['title'];
  final body = data['body'];
  final payload = data['payload'];
  final alarmId = data['alarmId'];
  if (title is! String ||
      body is! String ||
      payload is! String ||
      alarmId is! num) {
    return;
  }

  if (payload.isNotEmpty) {
    late final Map<String, dynamic> payloadData;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic> ||
          decoded['type'] != 'habit_alarm') {
        return;
      }
      payloadData = decoded;
    } on FormatException catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'habit alarm payload',
        ),
      );
      return;
    }
    if (payloadData['title'] is! String || payloadData['body'] is! String) {
      return;
    }
  }

  final navigator = _navigatorKey.currentState;
  if (navigator == null) {
    _pendingAlarmResponse = data;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingAlarm = _pendingAlarmResponse;
      if (pendingAlarm != null && _navigatorKey.currentState != null) {
        _pendingAlarmResponse = null;
        _openHabitAlarmData(pendingAlarm);
      }
    });
    return;
  }

  navigator.push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => HabitAlarmPage(
        notificationId: alarmId.toInt(),
        title: title,
        description: body,
        payload: payload,
      ),
    ),
  );
}

void _openHabitAlarm(NotificationResponse response) {
  final payload = response.payload;
  if (payload == null) return;

  late final Map<String, dynamic> data;
  try {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic> ||
        decoded['type'] != 'habit_alarm' ||
        decoded['title'] is! String ||
        decoded['body'] is! String) {
      return;
    }
    data = decoded;
  } on FormatException catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'habit alarm notification',
        context: ErrorDescription('while reading the alarm payload'),
      ),
    );
    return;
  }

  _openHabitAlarmData({
    'alarmId': response.id ?? 0,
    'title': data['title'] as String,
    'body': data['body'] as String,
    'payload': payload,
  });
}

Future<void> _restoreEventReminders() async {
  final events = await getIt<EventRepository>().getEvents();
  final scheduler = getIt<EventReminderScheduler>();

  for (final event in events) {
    try {
      await scheduler.scheduleEvent(event);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'event reminder restoration',
          context: ErrorDescription('while restoring "${event.title}"'),
        ),
      );
    }
  }
}

Future<void> _restoreHabitReminders() async {
  final habits = await getIt<HabitRepository>().getHabits();
  final scheduler = getIt<HabitReminderScheduler>();

  for (final habit in habits) {
    try {
      await scheduler.scheduleHabit(habit);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'habit alarm restoration',
          context: ErrorDescription('while restoring "${habit.title}"'),
        ),
      );
    }
  }
}

Future<void> _initializeServicesAfterLaunch() async {
  try {
    await getIt<AppThemeController>().load();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app theme startup',
        context: ErrorDescription('while loading the saved app theme'),
      ),
    );
  }

  try {
    HabitAlarmPlatformService.initialize(onAlarmLaunched: _openHabitAlarmData);
    final launchAlarm = await HabitAlarmPlatformService.consumeLaunchAlarm();
    if (launchAlarm != null) {
      _openHabitAlarmData(launchAlarm);
    }

    await NotificationService.instance.initialize(
      onNotificationResponse: _openHabitAlarm,
    );
    await _restoreEventReminders();
    await _restoreHabitReminders();
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'notification startup',
        context: ErrorDescription(
          'while initializing notifications and restoring reminders',
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const WakeLockApp());
  unawaited(_initializeServicesAfterLaunch());
}

class WakeLockApp extends StatefulWidget {
  const WakeLockApp({super.key});

  @override
  State<WakeLockApp> createState() => _WakeLockAppState();
}

class _WakeLockAppState extends State<WakeLockApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final response = _pendingAlarmResponse;
      _pendingAlarmResponse = null;
      if (response != null) {
        _openHabitAlarmData(response);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = getIt<AppThemeController>();
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'WakeLock',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppStartGate(),
      ),
    );
  }
}
