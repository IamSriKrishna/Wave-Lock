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

    final goalStages = [
      for (final goal in user.goals)
        for (final entry in _goalActions(goal).indexed)
          (goal: goal, action: entry.$2, stageNumber: entry.$1 + 1),
    ];
    for (final entry in goalStages.indexed) {
      final goal = entry.$2.goal;
      final action = entry.$2.action;
      steps.add(
        DailyGrowthStep(
          id: entry.$2.stageNumber == 1
              ? 'goal-${_slug(goal)}'
              : 'goal-${_slug(goal)}-${entry.$2.stageNumber}',
          title: action.title,
          description: action.description,
          goal: goal,
          estimatedMinutes: _goalStageMinutes(
            availableMinutes,
            goalStages.length,
            entry.$1,
          ),
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

  static int _goalStageMinutes(
    int availableMinutes,
    int stageCount,
    int stageIndex,
  ) {
    final goalTime = (availableMinutes - 4).clamp(
      0,
      availableMinutes < 0 ? 0 : availableMinutes,
    );
    final minutes = goalTime ~/ stageCount;
    final remainder = goalTime % stageCount;
    return (minutes + (stageIndex < remainder ? 1 : 0)).clamp(1, 25);
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

  static List<({String title, String description})> _goalActions(String goal) {
    switch (goal) {
      case 'Coding & Programming':
        return [
          (
            title: 'Choose a small coding target',
            description: 'Pick one tiny feature or programming problem and define what finished looks like.',
          ),
          (
            title: 'Build one small thing',
            description: 'Work on your chosen coding target without switching tasks. Keep the scope small enough to finish.',
          ),
          (
            title: 'Test and note your next step',
            description: 'Run your work or check your solution, then write down one improvement or next coding task.',
          ),
        ];
      case 'Learning':
        return [
          (
            title: 'Choose one learning topic',
            description: 'Select one small lesson or concept and decide what you want to understand by the end.',
          ),
          (
            title: 'Study with focus',
            description: 'Work through the lesson without switching apps. Pause to explain the main idea in your own words.',
          ),
          (
            title: 'Recall what you learned',
            description: 'Close your material and write down three things you remember plus one question to explore next.',
          ),
        ];
      case 'Professional Work':
        return [
          (
            title: 'Pick your highest-impact task',
            description: 'Choose one important work task and define the smallest useful result you can deliver.',
          ),
          (
            title: 'Make focused progress',
            description: 'Silence non-essential notifications and work on the task until you have a visible first result.',
          ),
          (
            title: 'Review and plan the follow-up',
            description: 'Check what changed, capture any blocker, and identify the next action for this task.',
          ),
        ];
      case 'College & Academics':
        return [
          (
            title: 'Choose one study topic',
            description: 'Pick a topic or assignment and identify one question you want to answer.',
          ),
          (
            title: 'Study and explain',
            description: 'Review the material, then explain the main idea aloud or in your own notes.',
          ),
          (
            title: 'Test your understanding',
            description: 'Answer a question from memory and mark anything you need to review again.',
          ),
        ];
      case 'Business':
        return [
          (
            title: 'Choose a business priority',
            description: 'Identify one useful action for a customer, offer, or business idea.',
          ),
          (
            title: 'Take the concrete action',
            description: 'Follow up with a customer, improve an offer, or test one small part of your idea.',
          ),
          (
            title: 'Capture the result',
            description: 'Note what happened and choose one practical follow-up based on what you learned.',
          ),
        ];
      case 'Reading':
        return [
          (
            title: 'Choose what to read',
            description: 'Pick a book or saved article and decide how much you want to read today.',
          ),
          (
            title: 'Read without distractions',
            description: 'Read your chosen material away from distracting apps and pause when your focus slips.',
          ),
          (
            title: 'Save one takeaway',
            description: 'Write down one idea, passage, or question you want to remember.',
          ),
        ];
      case 'Fitness':
        return [
          (
            title: 'Choose comfortable movement',
            description: 'Pick a walk, mobility routine, or workout that suits your current ability.',
          ),
          (
            title: 'Get moving safely',
            description: 'Start gently and do your chosen movement at a comfortable pace. Stop if you feel pain.',
          ),
          (
            title: 'Cool down and reflect',
            description: 'Take a moment to recover and note how the movement felt so you can adjust next time.',
          ),
        ];
      case 'Personal Development':
        return [
          (
            title: 'Choose an area to develop',
            description: 'Pick one personal value or useful skill you want to give attention today.',
          ),
          (
            title: 'Practice with intention',
            description: 'Journal, practice your chosen skill, or reflect without distractions.',
          ),
          (
            title: 'Record one insight',
            description: 'Write down what you noticed and one small way to apply it tomorrow.',
          ),
        ];
      default:
        return [
          (
            title: 'Choose a step for $goal',
            description:
                'Define one small, specific result you would like to reach for $goal.',
          ),
          (
            title: 'Make focused progress on $goal',
            description:
                'Work on your chosen action for $goal without switching to distracting apps.',
          ),
          (
            title: 'Review your progress on $goal',
            description:
                'Notice what you accomplished for $goal and choose one small next step.',
          ),
        ];
    }
  }
}
