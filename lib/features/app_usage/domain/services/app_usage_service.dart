import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../entities/app_usage_day.dart';
import '../entities/app_usage_entry.dart';
import '../entities/app_usage_snapshot.dart';

class AppUsageService {
  const AppUsageService();

  static const MethodChannel _channel = MethodChannel('com.wakelock/app_usage');

  Future<AppUsageSnapshot> getWeeklyUsage() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const AppUsageSnapshot.unsupported();
    }

    final result = await _channel.invokeMapMethod<String, dynamic>(
      'getWeeklyUsage',
    );
    if (result == null) {
      throw const FormatException('The Android app usage response was empty.');
    }

    final rawDays = result['days'];
    if (rawDays is! List) {
      throw const FormatException('The Android app usage response is invalid.');
    }

    return AppUsageSnapshot(
      isSupported: true,
      hasAccess: result['hasAccess'] == true,
      days: rawDays.map((rawDay) {
        if (rawDay is! Map) {
          throw const FormatException('An app usage day was invalid.');
        }
        final day = Map<String, dynamic>.from(rawDay);
        final dayStart = day['dayStartMillis'];
        final rawApps = day['apps'];
        if (dayStart is! num || rawApps is! List) {
          throw const FormatException('An app usage day was incomplete.');
        }

        final apps = rawApps.map((rawApp) {
          if (rawApp is! Map) {
            throw const FormatException('An app usage entry was invalid.');
          }
          final app = Map<String, dynamic>.from(rawApp);
          final packageName = app['packageName'];
          final appName = app['appName'];
          final durationMillis = app['durationMillis'];
          if (packageName is! String ||
              appName is! String ||
              durationMillis is! num) {
            throw const FormatException('An app usage entry was incomplete.');
          }

          return AppUsageEntry(
            packageName: packageName,
            appName: appName,
            duration: Duration(milliseconds: durationMillis.toInt()),
          );
        }).toList();

        return AppUsageDay(
          date: DateTime.fromMillisecondsSinceEpoch(dayStart.toInt()),
          apps: apps,
        );
      }).toList(),
    );
  }

  Future<void> openUsageAccessSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    await _channel.invokeMethod<void>('openUsageAccessSettings');
  }
}
