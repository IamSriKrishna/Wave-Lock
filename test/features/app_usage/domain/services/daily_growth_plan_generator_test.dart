import 'package:flutter_test/flutter_test.dart';
import 'package:wakelock/features/app_usage/domain/entities/app_usage_day.dart';
import 'package:wakelock/features/app_usage/domain/entities/app_usage_entry.dart';
import 'package:wakelock/features/app_usage/domain/entities/app_usage_snapshot.dart';
import 'package:wakelock/features/app_usage/domain/services/daily_growth_plan_generator.dart';
import 'package:wakelock/features/onboarding/domain/entities/user_entity.dart';

void main() {
  const generator = DailyGrowthPlanGenerator();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final user = UserEntity(
    id: 'user-id',
    name: 'Alex',
    goals: const ['Coding & Programming', 'Fitness'],
    experienceLevel: 'beginner',
    dailyAvailableMinutes: 60,
    preferredStartTime: '09:00',
    preferredEndTime: '18:00',
    createdAt: today,
  );

  test('generates stages for selected goals and today’s most-used app', () {
    final usage = AppUsageSnapshot(
      isSupported: true,
      hasAccess: true,
      days: [
        AppUsageDay(
          date: today,
          apps: const [
            AppUsageEntry(
              packageName: 'com.example.video',
              appName: 'Video',
              duration: Duration(hours: 2, minutes: 30),
            ),
            AppUsageEntry(
              packageName: 'com.example.reader',
              appName: 'Reader',
              duration: Duration(minutes: 35),
            ),
          ],
        ),
      ],
    );

    final plan = generator.generate(user: user, usage: usage);

    expect(plan.map((step) => step.goal), contains('Coding & Programming'));
    expect(plan.map((step) => step.goal), contains('Fitness'));
    expect(plan.first.description, contains('Video'));
    expect(plan.first.description, contains('2 h 30 min'));
    expect(plan.last.title, 'Review your progress');
  });

  test('generates goal stages when usage access is unavailable', () {
    final plan = generator.generate(
      user: user,
      usage: const AppUsageSnapshot(
        isSupported: true,
        hasAccess: false,
        days: [],
      ),
    );

    expect(plan.first.title, 'Set your focus boundary');
    expect(plan.any((step) => step.title == 'Build something small'), isTrue);
    expect(plan.any((step) => step.title == 'Move your body'), isTrue);
  });
}
