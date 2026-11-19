import '../entities/app_usage_day.dart';
import '../entities/app_usage_snapshot.dart';
import '../entities/daily_growth_step.dart';
import '../../../onboarding/domain/entities/user_entity.dart';

class DailyGrowthPlanGenerator {
  const DailyGrowthPlanGenerator();

  List<DailyGrowthStep> generate({
    required UserEntity user,
    required AppUsageSnapshot? usage,
  }) {
    final today = _todayUsage(usage);
    final topApp = today?.apps.isEmpty ?? true
        ? null
        : (today!.apps.toList()..sort(
                (first, second) => second.duration.compareTo(first.duration),
              ))
              .first;
    final availableMinutes = user.dailyAvailableMinutes;
    final steps = <DailyGrowthStep>[
      DailyGrowthStep(
        id: 'notice-usage',
        title: topApp == null
            ? 'Set your focus boundary'
            : 'Reclaim 15 minutes',
        description: topApp == null
            ? 'Choose one app-free period today. Put your phone out of reach and use that time for a personal goal.'
            : 'You used ${topApp.appName} for ${_formatDuration(topApp.duration)} today. Set a 15-minute limit for it, then use that time for one of your goals.',
        goal: 'Mindful screen time',
        estimatedMinutes: 2,
      ),
    ];

    final chosenGoals = user.goals.take(2).toList();
    for (final goal in chosenGoals) {
      final action = _goalAction(goal);
      steps.add(
        DailyGrowthStep(
          id: 'goal-${_slug(goal)}',
          title: action.title,
          description: action.description,
          goal: goal,
          estimatedMinutes: _goalMinutes(availableMinutes, chosenGoals.length),
        ),
      );
    }

    steps.add(
      DailyGrowthStep(
        id: 'reflect',
        title: 'Review your progress',
        description: 'Take two minutes tonight to notice what helped you focus, what pulled you away, and one small change to try tomorrow.',
        goal: 'Build a sustainable routine',
        estimatedMinutes: 2,
      ),
    );

    return steps;
  }

  static AppUsageDay? _todayUsage(AppUsageSnapshot? snapshot) {
    if (snapshot == null || !snapshot.hasAccess || snapshot.days.isEmpty) {
      return null;
    }
    final now = DateTime.now();
    for (final day in snapshot.days) {
      if (day.date.year == now.year &&
          day.date.month == now.month &&
          day.date.day == now.day) {
        return day;
      }
    }
    return null;
  }

  static int _goalMinutes(int availableMinutes, int goalCount) {
    final minutes = availableMinutes ~/ (goalCount + 2);
    return minutes.clamp(10, 25);
  }

  static String _slug(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  static String _formatDuration(Duration duration) {
    final hours = duration.inMinutes ~/ 60;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) return '$minutes minutes';
    if (minutes == 0) return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    return '$hours h $minutes min';
  }

  static ({String title, String description}) _goalAction(String goal) {
    switch (goal) {
      case 'Coding & Programming':
        return (
          title: 'Build something small',
          description: 'Spend one focused block coding a tiny feature or solving one programming problem. Stop when the block ends and note your next step.',
        );
      case 'Learning':
        return (
          title: 'Learn, then recall',
          description: 'Study one small lesson without switching apps. Close it afterward and write down three things you remember.',
        );
      case 'Professional Work':
        return (
          title: 'Move one important task forward',
          description: 'Choose the highest-impact work task, silence non-essential notifications, and make a visible first increment of progress.',
        );
      case 'College & Academics':
        return (
          title: 'Study with active recall',
          description: 'Review one topic, then test yourself from memory instead of rereading. Mark one question to revisit.',
        );
      case 'Business':
        return (
          title: 'Take one business-building action',
          description: 'Complete one concrete action for a customer or your business: follow up, improve an offer, or validate an idea.',
        );
      case 'Reading':
        return (
          title: 'Read a few pages',
          description: 'Read a book or saved article away from distracting apps. Capture one idea you want to remember.',
        );
      case 'Fitness':
        return (
          title: 'Move your body',
          description: 'Do a comfortable walk, mobility routine, or workout that suits your current ability. Start gently and stop if you feel pain.',
        );
      case 'Personal Development':
        return (
          title: 'Invest in yourself',
          description: 'Spend a short, distraction-free block journaling, practicing a useful skill, or reflecting on a personal value.',
        );
      default:
        return (
          title: 'Make progress on $goal',
          description:
              'Choose one small, specific action related to $goal and give it a focused block without switching to distracting apps.',
        );
    }
  }
}
