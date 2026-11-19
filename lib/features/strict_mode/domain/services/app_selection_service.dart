
import 'package:flutter/services.dart';

import '../entities/installed_app_entity.dart';

class AppSelectionService {
  static const MethodChannel _channel =
      MethodChannel('com.wakelock/app_selection');

  Future<List<InstalledAppEntity>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getInstalledApps',
      );

      if (result == null) return [];

      return result.map((item) {
        final app = Map<String, dynamic>.from(item as Map);

        return InstalledAppEntity(
          packageName: app['packageName'] as String,
          appName: app['appName'] as String,
          isSystemApp: app['isSystemApp'] as bool? ?? false,
        );
      }).toList();
    } on PlatformException catch (error) {
      throw Exception(
        'Unable to retrieve installed apps: ${error.message}',
      );
    }
  }
}
