import 'app_usage_day.dart';

class AppUsageSnapshot {
  const AppUsageSnapshot({
    required this.isSupported,
    required this.hasAccess,
    required this.days,
  });

  const AppUsageSnapshot.unsupported()
    : isSupported = false,
      hasAccess = false,
      days = const [];

  final bool isSupported;
  final bool hasAccess;
  final List<AppUsageDay> days;
}
