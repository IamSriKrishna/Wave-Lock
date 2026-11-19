import 'package:uuid/uuid.dart';

import '../../../onboarding/domain/entities/user_entity.dart';
import '../entities/mission_entity.dart';

class MissionTemplate {
  final String title;
  final String description;
  final String goal;
  final int baseDuration;

  const MissionTemplate({
    required this.title,
    required this.description,
    required this.goal,
    required this.baseDuration,
  });
}

class MissionRecommendationEngine {
  final Uuid _uuid = const Uuid();

  final Map<String, List<MissionTemplate>> _rules = {
    'Coding & Programming': [
      MissionTemplate(
        title: 'Complete a coding exercise',
        description:
            'Solve one programming problem and understand its solution.',
        goal: 'Coding & Programming',
        baseDuration: 25,
      ),
      MissionTemplate(
        title: 'Build a small feature',
        description:
            'Implement one small feature in your current coding project.',
        goal: 'Coding & Programming',
        baseDuration: 35,
      ),
      MissionTemplate(
        title: 'Review your code',
        description: 'Review existing code and improve its readability.',
        goal: 'Coding & Programming',
        baseDuration: 20,
      ),
    ],
    'Learning': [
      MissionTemplate(
        title: 'Learn one new concept',
        description:
            'Study one new concept and write down the important points.',
        goal: 'Learning',
        baseDuration: 25,
      ),
      MissionTemplate(
        title: 'Revise what you learned',
        description: 'Review your notes and recall the important concepts.',
        goal: 'Learning',
        baseDuration: 20,
      ),
      MissionTemplate(
        title: 'Practice your knowledge',
        description: 'Answer questions or complete a small practical exercise.',
        goal: 'Learning',
        baseDuration: 30,
      ),
    ],
    'Professional Work': [
      MissionTemplate(
        title: 'Complete a priority task',
        description:
            'Choose one important work task and make meaningful progress.',
        goal: 'Professional Work',
        baseDuration: 30,
      ),
      MissionTemplate(
        title: 'Plan your work',
        description: 'Organize your tasks and identify your next priority.',
        goal: 'Professional Work',
        baseDuration: 15,
      ),
    ],
    'College & Academics': [
      MissionTemplate(
        title: 'Study one topic',
        description:
            'Focus on one academic topic and create short revision notes.',
        goal: 'College & Academics',
        baseDuration: 30,
      ),
      MissionTemplate(
        title: 'Practice exam questions',
        description: 'Answer questions from a topic you have already studied.',
        goal: 'College & Academics',
        baseDuration: 25,
      ),
    ],
    'Business': [
      MissionTemplate(
        title: 'Move one business task forward',
        description: 'Complete one action that helps your business progress.',
        goal: 'Business',
        baseDuration: 30,
      ),
      MissionTemplate(
        title: 'Review business priorities',
        description:
            'Review your current priorities and decide the next action.',
        goal: 'Business',
        baseDuration: 20,
      ),
    ],
    'Reading': [
      MissionTemplate(
        title: 'Read a few pages',
        description: 'Read a focused section of a book without distractions.',
        goal: 'Reading',
        baseDuration: 20,
      ),
      MissionTemplate(
        title: 'Write reading notes',
        description: 'Write down the most useful ideas from your reading.',
        goal: 'Reading',
        baseDuration: 15,
      ),
    ],
    'Fitness': [
      MissionTemplate(
        title: 'Complete a short workout',
        description: 'Do a simple workout appropriate for your fitness level.',
        goal: 'Fitness',
        baseDuration: 25,
      ),
      MissionTemplate(
        title: 'Take a movement break',
        description: 'Take a walk or do light stretching.',
        goal: 'Fitness',
        baseDuration: 15,
      ),
    ],
    'Personal Development': [
      MissionTemplate(
        title: 'Reflect on your progress',
        description: 'Review what went well and identify one improvement.',
        goal: 'Personal Development',
        baseDuration: 15,
      ),
      MissionTemplate(
        title: 'Set a personal improvement goal',
        description: 'Choose one small action to improve yourself today.',
        goal: 'Personal Development',
        baseDuration: 20,
      ),
    ],
  };

  List<MissionEntity> generate(UserEntity user) {
    final availableMinutes = user.dailyAvailableMinutes;

    if (availableMinutes <= 0 || user.goals.isEmpty) {
      return [];
    }

    final templates = <MissionTemplate>[];

    for (final goal in user.goals) {
      templates.addAll(_rules[goal] ?? []);
    }

    // Avoid generating the same title twice.
    final uniqueTemplates = <MissionTemplate>[];
    final seenTitles = <String>{};

    for (final template in templates) {
      if (seenTitles.add(template.title)) {
        uniqueTemplates.add(template);
      }
    }

    final recommendations = <MissionEntity>[];
    var remainingMinutes = availableMinutes;

    for (final template in uniqueTemplates) {
      if (recommendations.length >= 3) break;

      final duration = _durationFor(
        template.baseDuration,
        user.experienceLevel,
      );

      if (duration > remainingMinutes) continue;

      recommendations.add(
        MissionEntity(
          id: _uuid.v4(),
          title: template.title,
          description: template.description,
          goal: template.goal,
          durationMinutes: duration,
          difficulty: _difficultyFor(user.experienceLevel),
        ),
      );

      remainingMinutes -= duration;
    }

    // Fallback for an onboarding goal without a matching rule.
    if (recommendations.isEmpty && availableMinutes >= 15) {
      recommendations.add(
        MissionEntity(
          id: _uuid.v4(),
          title: 'Make progress on your goal',
          description: 'Spend focused time taking one meaningful step towards your selected goal.',
          goal: user.goals.first,
          durationMinutes: 15,
          difficulty: _difficultyFor(user.experienceLevel),
        ),
      );
    }

    return recommendations;
  }

  int _durationFor(int base, String experience) {
    switch (experience.toLowerCase()) {
      case 'beginner':
        return base;
      case 'intermediate':
        return (base * 1.2).round();
      case 'advanced':
        return (base * 1.4).round();
      default:
        return base;
    }
  }

  String _difficultyFor(String experience) {
    switch (experience.toLowerCase()) {
      case 'beginner':
        return 'Easy';
      case 'intermediate':
        return 'Medium';
      case 'advanced':
        return 'Hard';
      default:
        return 'Easy';
    }
  }
}
