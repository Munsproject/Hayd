import 'package:hayd_kalender/core/enums/bleeding_type.dart';
import 'package:hayd_kalender/domain/models/cycle.dart';

/// A single day during Ramadan where the fast could not be kept due to bleeding.
class MissedFastDay {
  final DateTime date;

  /// The type of bleeding on this day.
  /// Even Istihada days are counted — as soon as blood is seen the fast is
  /// forbidden, so the day must be made up regardless of final classification.
  final BleedingType bleedingType;

  const MissedFastDay({required this.date, required this.bleedingType});
}

/// Calculates Ramadan-related fiqh data such as missed fasting days due to bleeding.
class RamadanService {
  /// Returns every Ramadan day where bleeding was present during the fasting
  /// window [Fajr, Maghreb).
  ///
  /// Rule applied:
  /// - Blood present **before Maghreb** (even by a minute) → fast is invalid → must make up.
  /// - Blood that appears **at or after Maghreb** → the fast was already completed → valid.
  /// - Blood ongoing from a previous night that is still present at Fajr → fast is invalid.
  ///
  /// Both Hayd and Istihada days are included: any visible blood during the
  /// fasting window prohibits the fast, regardless of final classification.
  List<MissedFastDay> missedFastingDays({
    required List<Cycle> cycles,
    required DateTime ramadanStart,
    required int durationDays,
    int fajrHour = 4,
    int fajrMinute = 0,
    int maghrebHour = 20,
    int maghrebMinute = 0,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final missed = <MissedFastDay>[];

    for (int i = 0; i < durationDays; i++) {
      final day = DateTime(
        ramadanStart.year,
        ramadanStart.month,
        ramadanStart.day + i,
      );

      // Fasting window: Fajr → Maghreb on this day
      final fajr = DateTime(day.year, day.month, day.day, fajrHour, fajrMinute);
      final maghreb = DateTime(day.year, day.month, day.day, maghrebHour, maghrebMinute);

      for (final cycle in cycles) {
        final bleedStart = cycle.bleedingStart;
        final bleedEnd = cycle.bleedingEnd ?? effectiveNow;

        // Overlap with fasting window: bleeding started before Maghreb
        // AND bleeding was still ongoing after Fajr.
        if (bleedStart.isBefore(maghreb) && bleedEnd.isAfter(fajr)) {
          missed.add(MissedFastDay(date: day, bleedingType: cycle.bleedingType));
          break;
        }
      }
    }

    return missed;
  }

  /// How many Ramadan days have passed so far (capped at [durationDays]).
  int elapsedDays({
    required DateTime ramadanStart,
    required int durationDays,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final diff = today.difference(ramadanStart).inDays;
    if (diff < 0) return 0;
    if (diff >= durationDays) return durationDays;
    return diff + 1;
  }
}
