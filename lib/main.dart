import 'package:flutter/material.dart';
import 'package:wakelock/core/services/notification_service.dart';
import 'package:wakelock/features/events/domain/repositories/event_repository.dart';
import 'package:wakelock/features/events/domain/services/event_reminder_scheduler.dart';

import 'core/router/app_start_gate.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_controller.dart';
import 'injection_container.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();
  await getIt<AppThemeController>().load();

  await NotificationService.instance.initialize();
  await _restoreEventReminders();

  runApp(const WakeLockApp());
}

class WakeLockApp extends StatelessWidget {
  const WakeLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = getIt<AppThemeController>();
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: 'WakeLock',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppStartGate(),
      ),
    );
  }
}
