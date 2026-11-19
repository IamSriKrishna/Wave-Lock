import 'app_usage_entry.dart';

class AppUsageDay {
  const AppUsageDay({required this.date, required this.apps});

  final DateTime date;
  final List<AppUsageEntry> apps;

  Duration get totalUsage =>
      apps.fold(Duration.zero, (total, app) => total + app.duration);
}
