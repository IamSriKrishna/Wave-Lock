class AppUsageEntry {
  const AppUsageEntry({
    required this.packageName,
    required this.appName,
    required this.duration,
  });

  final String packageName;
  final String appName;
  final Duration duration;
}
