import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class StrictModeService {
  static const _channel = MethodChannel('com.wakelock/strict_mode');

  bool get isSupported => defaultTargetPlatform == TargetPlatform.android;

  Future<bool> isAccessibilityEnabled() async {
    if (!isSupported) return true;

    return await _channel.invokeMethod<bool>('isAccessibilityServiceEnabled') ??
        false;
  }

  Future<void> openAccessibilitySettings() async {
    if (!isSupported) return;

    await _channel.invokeMethod<void>('openAccessibilitySettings');
  }

  Future<void> setActive({required bool active, DateTime? endTime}) async {
    if (!isSupported) return;

    await _channel.invokeMethod<void>('setStrictModeActive', {
      'active': active,
      'endTimeMillis': endTime?.millisecondsSinceEpoch,
    });
  }
}
