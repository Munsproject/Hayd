import 'package:hayd_kalender/core/constants/fiqh_constants.dart';
import 'package:hayd_kalender/domain/models/habit.dart';
import 'package:hayd_kalender/domain/models/habit_change.dart';

/// Hanafi Fiqh rulings for menstrual habits (ʿĀdah)
class HabitRules {
  /// ESTABLISHMENT OF HABIT
  /// A menstrual habit is established by having a valid menstrual period
  /// and/or a valid tuhr once.
  static bool isHabitEstablished({
    required bool hasValidHayd,
    required bool hasValidTuhr,
  }) {
    return hasValidHayd || hasValidTuhr;
  }

  /// Only valid blood and valid tuhr can be used as the habit
  static bool canBeUsedAsHabit({
    required int haydDurationHours,
    required int tuhrDurationHours,
  }) {
    final validHayd =
        haydDurationHours >= FiqhConstants.haydMinimumHours &&
        haydDurationHours <= FiqhConstants.haydMaximumHours;

    final validTuhr = tuhrDurationHours >= FiqhConstants.tuhrMinimumHours;

    return validHayd && validTuhr;
  }

  /// The habit is used when there is an occurrence of invalid blood and/or invalid tuhr
  static bool shouldUseHabit({
    required int currentBleedingHours,
    required int currentTuhrHours,
  }) {
    final invalidHayd = currentBleedingHours > FiqhConstants.haydMaximumHours;
    final invalidTuhr =
        currentTuhrHours > 0 &&
        currentTuhrHours < FiqhConstants.tuhrMinimumHours;

    return invalidHayd || invalidTuhr;
  }

  /// CHANGE IN HABITUAL PLACE (TUHR HABIT)
  ///
  /// Scenario 1: Woman does not see menses at expected time
  /// Example: 5-day hayd habit, 25-day tuhr habit
  /// After 30 days of tuhr → 5 days of menses
  /// Result: Tuhr habit changed to 30 days
  static HabitChange? detectPlaceChangeDelayed({
    required Habit currentHabit,
    required int actualTuhrHours,
    required int actualHaydHours,
    required DateTime changeDate,
  }) {
    // Check if menses came later than expected
    if (actualTuhrHours > currentHabit.tuhrDurationHours) {
      // Check if the hayd that followed is valid and matches habit
      if (actualHaydHours >= FiqhConstants.haydMinimumHours &&
          actualHaydHours <= FiqhConstants.haydMaximumHours) {
        final newHabit = currentHabit.copyWith(
          tuhrDurationHours: actualTuhrHours,
          cycleCount: currentHabit.cycleCount + 1,
        );

        return HabitChange(
          changeType: HabitChangeType.placeChange,
          oldHabit: currentHabit,
          newHabit: newHabit,
          changeDetectedDate: changeDate,
          explanation:
              'Menses occurred after ${(actualTuhrHours / 24).round()} days '
              'of tuhr (expected ${currentHabit.tuhrDays} days). '
              'Tuhr habit changed from ${currentHabit.tuhrDays} to ${newHabit.tuhrDays} days.',
        );
      }
    }
    return null;
  }

  /// Scenario 2: Woman sees menses before expected time but after complete tuhr
  /// Example: 5-day hayd habit, 25-day tuhr habit
  /// After 20 days of tuhr → 5 days of menses
  /// At day 25 (habitual place) → no blood
  /// Result: Tuhr habit changed to 20 days
  static HabitChange? detectPlaceChangeEarly({
    required Habit currentHabit,
    required int actualTuhrHours,
    required int actualHaydHours,
    required DateTime changeDate,
  }) {
    // Check if menses came earlier than expected but after valid tuhr
    if (actualTuhrHours >= FiqhConstants.tuhrMinimumHours &&
        actualTuhrHours < currentHabit.tuhrDurationHours) {
      // Check if the hayd is valid
      if (actualHaydHours >= FiqhConstants.haydMinimumHours &&
          actualHaydHours <= FiqhConstants.haydMaximumHours) {
        final newHabit = currentHabit.copyWith(
          tuhrDurationHours: actualTuhrHours,
          cycleCount: currentHabit.cycleCount + 1,
        );

        return HabitChange(
          changeType: HabitChangeType.placeChange,
          oldHabit: currentHabit,
          newHabit: newHabit,
          changeDetectedDate: changeDate,
          explanation:
              'Menses occurred after ${(actualTuhrHours / 24).round()} days '
              'of tuhr (expected ${currentHabit.tuhrDays} days). '
              'No blood seen at habitual place (day ${currentHabit.tuhrDays}). '
              'Tuhr habit changed from ${currentHabit.tuhrDays} to ${newHabit.tuhrDays} days.',
        );
      }
    }
    return null;
  }

  /// CHANGE IN HABITUAL NUMBER (HAYD HABIT)
  ///
  /// Scenario 1: Woman sees different number of days that are valid blood
  /// Example: 5-day hayd habit → sees 9 days of valid bleeding
  /// Result: Hayd habit changed to 9 days
  static HabitChange? detectNumberChangeSimple({
    required Habit currentHabit,
    required int actualHaydHours,
    required int actualTuhrHours,
    required DateTime changeDate,
  }) {
    // Check if bleeding duration is different but still valid
    if (actualHaydHours != currentHabit.haydDurationHours &&
        actualHaydHours >= FiqhConstants.haydMinimumHours &&
        actualHaydHours <= FiqhConstants.haydMaximumHours) {
      // Must be followed by valid tuhr to confirm
      if (actualTuhrHours >= FiqhConstants.tuhrMinimumHours) {
        final newHabit = currentHabit.copyWith(
          haydDurationHours: actualHaydHours,
          cycleCount: currentHabit.cycleCount + 1,
        );

        return HabitChange(
          changeType: HabitChangeType.numberChange,
          oldHabit: currentHabit,
          newHabit: newHabit,
          changeDetectedDate: changeDate,
          explanation:
              'Valid bleeding duration changed from ${currentHabit.haydDays} days '
              'to ${newHabit.haydDays} days. Hayd habit updated.',
        );
      }
    }
    return null;
  }

  /// Scenario 2: Blood exceeds 10 days with minimum in habitual place
  /// Example: 5-day hayd habit, 25-day tuhr habit
  /// After 18 days of tuhr → 11 days of blood → valid tuhr
  /// Analysis:
  /// - Days 19-23 (before habitual place): 5 days → Istihada (7 days total before + 2 in place)
  /// - Days 24-27 (in habitual place): 4 days → Hayd
  /// - Day 28-29 (after habitual place): Istihada
  /// Result: Hayd habit changed from 5 days to 4 days
  static HabitChange? detectNumberChangeExceeded({
    required Habit currentHabit,
    required int tuhrBeforeBleedingHours,
    required int totalBleedingHours,
    required int tuhrAfterBleedingHours,
    required DateTime changeDate,
  }) {
    // Blood must exceed maximum hayd
    if (totalBleedingHours <= FiqhConstants.haydMaximumHours) {
      return null;
    }

    // Must be followed by valid tuhr
    if (tuhrAfterBleedingHours < FiqhConstants.tuhrMinimumHours) {
      return null;
    }

    // Calculate when habitual place begins
    final habitualPlaceStartHours = currentHabit.tuhrDurationHours;

    // Calculate how much bleeding occurred before habitual place
    final hoursBeforeHabitualPlace =
        habitualPlaceStartHours - tuhrBeforeBleedingHours;

    if (hoursBeforeHabitualPlace < 0) {
      // Bleeding started after habitual place
      return null;
    }

    // Calculate bleeding that falls in habitual place (up to habit duration)
    final maxHoursInHabitualPlace = currentHabit.haydDurationHours;
    final bleedingAfterHabitStart =
        totalBleedingHours - hoursBeforeHabitualPlace;

    final hoursInHabitualPlace =
        bleedingAfterHabitStart < maxHoursInHabitualPlace
        ? bleedingAfterHabitStart
        : maxHoursInHabitualPlace;

    // Must have minimum hayd in habitual place
    if (hoursInHabitualPlace < FiqhConstants.haydMinimumHours) {
      return null;
    }

    // The bleeding in habitual place becomes the new habit
    final newHaydHours = hoursInHabitualPlace;
    final daysBeforePlace = (hoursBeforeHabitualPlace / 24).round();
    final daysInPlace = (hoursInHabitualPlace / 24).round();
    final daysAfterPlace =
        ((totalBleedingHours -
                    hoursBeforeHabitualPlace -
                    hoursInHabitualPlace) /
                24)
            .round();

    final newHabit = currentHabit.copyWith(
      haydDurationHours: newHaydHours,
      cycleCount: currentHabit.cycleCount + 1,
    );

    return HabitChange(
      changeType: HabitChangeType.numberChange,
      oldHabit: currentHabit,
      newHabit: newHabit,
      changeDetectedDate: changeDate,
      explanation:
          'Bleeding exceeded 10 days (${(totalBleedingHours / 24).round()} days total). '
          'Analysis: '
          '${daysBeforePlace > 0 ? "$daysBeforePlace days before habitual place (istihada), " : ""}'
          '$daysInPlace days in habitual place (hayd), '
          '${daysAfterPlace > 0 ? "$daysAfterPlace days after (istihada). " : ""}'
          'Hayd habit changed from ${currentHabit.haydDays} to $daysInPlace days.',
    );
  }

  /// Complete cycle example from the ruling
  /// Habit: 6 days hayd, 20 days tuhr
  /// Next cycle: 6 days hayd, 17 days tuhr, 9 days hayd
  /// Result: New habit is 9 days hayd, 17 days tuhr
  static HabitChange? detectHabitChangeFromCompleteCycle({
    required Habit currentHabit,
    required int firstHaydHours,
    required int tuhrHours,
    required int secondHaydHours,
    required DateTime changeDate,
  }) {
    // First hayd should match habit
    if (firstHaydHours != currentHabit.haydDurationHours) {
      return null;
    }

    // Check if tuhr is valid but different from habit
    if (tuhrHours < FiqhConstants.tuhrMinimumHours) {
      return null;
    }

    // Second hayd must be valid
    if (secondHaydHours < FiqhConstants.haydMinimumHours ||
        secondHaydHours > FiqhConstants.haydMaximumHours) {
      return null;
    }

    // Determine change type
    final haydChanged = secondHaydHours != currentHabit.haydDurationHours;
    final tuhrChanged = tuhrHours != currentHabit.tuhrDurationHours;

    HabitChangeType changeType;
    if (haydChanged && tuhrChanged) {
      changeType = HabitChangeType.bothChanged;
    } else if (haydChanged) {
      changeType = HabitChangeType.numberChange;
    } else if (tuhrChanged) {
      changeType = HabitChangeType.placeChange;
    } else {
      return null; // No change
    }

    final newHabit = Habit(
      haydDurationHours: secondHaydHours,
      tuhrDurationHours: tuhrHours,
      establishedDate: changeDate,
      cycleCount: currentHabit.cycleCount + 1,
    );

    return HabitChange(
      changeType: changeType,
      oldHabit: currentHabit,
      newHabit: newHabit,
      changeDetectedDate: changeDate,
      explanation:
          'Complete cycle observed: '
          '${(firstHaydHours / 24).round()} days hayd, '
          '${(tuhrHours / 24).round()} days tuhr, '
          '${(secondHaydHours / 24).round()} days hayd. '
          'Habit changed from ${currentHabit.haydDays}d hayd/${currentHabit.tuhrDays}d tuhr '
          'to ${newHabit.haydDays}d hayd/${newHabit.tuhrDays}d tuhr.',
    );
  }
}
