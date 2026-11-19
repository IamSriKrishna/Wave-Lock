import 'package:flutter_test/flutter_test.dart';
import 'package:wakelock/features/habits/presentation/bloc/habit_state.dart';

void main() {
  group('HabitState', () {
    final selectedDate = DateTime(2026, 11, 18);

    test('defaults newly unlocked achievements to an empty list', () {
      final state = HabitState(selectedDate: selectedDate);

      expect(state.newlyUnlockedAchievements, isEmpty);
      expect(
        state.copyWith(status: HabitStatus.loading).newlyUnlockedAchievements,
        isEmpty,
      );
    });

    test('preserves newly unlocked achievements when copying', () {
      const achievementIds = ['first_habit'];
      final state = HabitState(
        selectedDate: selectedDate,
        newlyUnlockedAchievements: achievementIds,
      );

      expect(state.copyWith(status: HabitStatus.loading).newlyUnlockedAchievements,
          achievementIds);
    });
  });
}
