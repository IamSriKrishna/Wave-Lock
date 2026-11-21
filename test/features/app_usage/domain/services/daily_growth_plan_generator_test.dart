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
    expect(
      plan.where((step) => step.goal == 'Coding & Programming'),
      hasLength(3),
    );
    expect(plan.where((step) => step.goal == 'Fitness'), hasLength(3));
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
    expect(
      plan.any((step) => step.title == 'Choose a small coding target'),
      isTrue,
    );
    expect(plan.any((step) => step.title == 'Get moving safely'), isTrue);
  });

  test('generates three stages for every selected goal', () {
    const goals = [
      'Coding & Programming',
      'Learning',
      'Professional Work',
      'College & Academics',
      'Business',
      'Reading',
      'Fitness',
      'Personal Development',
    ];
    final allGoalsUser = UserEntity(
      id: user.id,
      name: user.name,
      goals: goals,
      experienceLevel: user.experienceLevel,
      dailyAvailableMinutes: user.dailyAvailableMinutes,
      preferredStartTime: user.preferredStartTime,
      preferredEndTime: user.preferredEndTime,
      createdAt: user.createdAt,
    );

    final plan = generator.generate(user: allGoalsUser, usage: null);
    final goalStages = plan.where((step) => goals.contains(step.goal)).toList();

    expect(plan, hasLength(26));
    expect(goalStages, hasLength(goals.length * 3));
    for (final goal in goals) {
      expect(goalStages.where((step) => step.goal == goal), hasLength(3));
    }
    expect(plan.map((step) => step.id).toSet(), hasLength(plan.length));
    expect(
      plan.fold<int>(0, (total, step) => total + step.estimatedMinutes),
      lessThanOrEqualTo(user.dailyAvailableMinutes),
    );
  });
}
