import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakelock/features/habits/presentation/pages/habit_alarm_page.dart';

void main() {
  testWidgets('shows the alarm screen and swipe-to-stop/snooze controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HabitAlarmPage(
          notificationId: 1,
          title: 'Read 20 pages',
          description: 'Read before bed',
          payload: '{"type":"habit_alarm"}',
        ),
      ),
    );

    expect(find.text('Read 20 pages'), findsOneWidget);
    expect(find.text('Read before bed'), findsOneWidget);
    expect(find.text('Snooze 5 minutes'), findsOneWidget);
    expect(find.text('SWIPE UP TO STOP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
