import 'package:flutter/material.dart';
import 'package:wakelock/core/services/notification_service.dart';

import 'core/router/app_start_gate.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  await NotificationService.instance.initialize();

  runApp(const WakeLockApp());
}

class WakeLockApp extends StatelessWidget {
  const WakeLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WakeLock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppStartGate(),
    );
  }
}
