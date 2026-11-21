import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wakelock/core/services/notification_service.dart';

void main() {
  setUpAll(tz.initializeTimeZones);

  test('normalizes the Android legacy India timezone identifier', () {
    final identifier = NotificationService.normalizeTimeZoneIdentifier(
      'Asia/Calcutta',
    );

    expect(identifier, 'Asia/Kolkata');
    expect(tz.getLocation(identifier).name, 'Asia/Kolkata');
  });

  test('keeps timezone identifiers that are already supported', () {
    expect(
      NotificationService.normalizeTimeZoneIdentifier('Europe/London'),
      'Europe/London',
    );
  });
}
