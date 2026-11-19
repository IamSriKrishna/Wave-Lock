import 'package:flutter/services.dart';

class AppSelectionService {
  static const MethodChannel _channel = MethodChannel(
    'com.wakelock/app_selection',
  );

  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getInstalledApps',
      );

      if (result == null) return [];

      return result.map((app) {
        return Map<String, dynamic>.from(app as Map);
      }).toList();
    } on PlatformException catch (error) {
      throw Exception('Unable to retrieve installed apps: ${error.message}');
    }
  }
}
