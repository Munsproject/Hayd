import 'package:hayd_kalender/domain/models/habit.dart';

/// Types of changes that can occur to a woman's menstrual habit
enum HabitChangeType {
  /// No change in habit
  noChange,

  /// Change in the habitual place (tuhr duration changed)
  /// - Menses came later than expected (after longer tuhr)
  /// - Menses came earlier than expected (but after valid tuhr)
  placeChange,

  /// Change in the habitual number (hayd duration changed)
  /// - Different number of valid bleeding days observed
  /// - Blood exceeded 10 days with minimum in habitual place
  numberChange,

  /// Both place and number changed
  bothChanged,
}

/// Represents a detected change in menstrual habit
class HabitChange {
  /// Type of change detected
  final HabitChangeType changeType;

  /// Previous habit
  final Habit oldHabit;

  /// New habit after change
  final Habit newHabit;

  /// When the change was detected
  final DateTime changeDetectedDate;

  /// Explanation of the change
  final String explanation;

  const HabitChange({
    required this.changeType,
    required this.oldHabit,
    required this.newHabit,
    required this.changeDetectedDate,
    required this.explanation,
  });

  /// Check if hayd duration changed
  bool get haydChanged =>
      oldHabit.haydDurationHours != newHabit.haydDurationHours;

  /// Check if tuhr duration changed
  bool get tuhrChanged =>
      oldHabit.tuhrDurationHours != newHabit.tuhrDurationHours;

  /// Get the difference in hayd days
  int get haydDaysDifference => newHabit.haydDays - oldHabit.haydDays;

  /// Get the difference in tuhr days
  int get tuhrDaysDifference => newHabit.tuhrDays - oldHabit.tuhrDays;

  @override
  String toString() {
    return 'HabitChange($changeType: ${oldHabit.haydDays}d/${oldHabit.tuhrDays}d → ${newHabit.haydDays}d/${newHabit.tuhrDays}d)';
  }
}
