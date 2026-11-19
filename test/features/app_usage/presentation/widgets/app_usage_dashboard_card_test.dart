import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakelock/features/app_usage/domain/entities/app_usage_day.dart';
import 'package:wakelock/features/app_usage/domain/entities/app_usage_entry.dart';
import 'package:wakelock/features/app_usage/domain/entities/app_usage_snapshot.dart';
import 'package:wakelock/features/app_usage/domain/services/app_usage_service.dart';
import 'package:wakelock/features/app_usage/presentation/widgets/app_usage_dashboard_card.dart';

void main() {
  testWidgets('shows daily totals and app usage for the selected day', (
    tester,
  ) async {
    final service = _FakeAppUsageService(
      AppUsageSnapshot(
        isSupported: true,
        hasAccess: true,
        days: [
          AppUsageDay(
            date: DateTime(2026, 11, 18),
            apps: const [
              AppUsageEntry(
                packageName: 'com.example.video',
                appName: 'Video',
                duration: Duration(hours: 2, minutes: 15),
              ),
            ],
          ),
          AppUsageDay(
            date: DateTime(2026, 11, 19),
            apps: const [
              AppUsageEntry(
                packageName: 'com.example.chat',
                appName: 'Chat',
                duration: Duration(hours: 1, minutes: 5),
              ),
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AppUsageDashboardCard(service: service)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App usage'), findsOneWidget);
    expect(find.text('Thursday, Nov 19 · 1h 5m'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);

    await tester.tap(find.text('Wed'));
    await tester.pumpAndSettle();

    expect(find.text('Wednesday, Nov 18 · 2h 15m'), findsOneWidget);
    expect(find.text('Video'), findsOneWidget);
  });

  testWidgets('prompts for Usage Access when permission is missing', (
    tester,
  ) async {
    final service = _FakeAppUsageService(
      const AppUsageSnapshot(isSupported: true, hasAccess: false, days: []),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AppUsageDashboardCard(service: service)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enable Usage Access'), findsOneWidget);
  });
}

class _FakeAppUsageService extends AppUsageService {
  _FakeAppUsageService(this.snapshot);

  final AppUsageSnapshot snapshot;

  @override
  Future<AppUsageSnapshot> getWeeklyUsage() async => snapshot;

  @override
  Future<void> openUsageAccessSettings() async {}
}
