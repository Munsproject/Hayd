import 'package:hayd_kalender/core/enums/bleeding_type.dart';
import 'package:hayd_kalender/core/constants/fiqh_constants.dart';
import 'package:hayd_kalender/domain/models/fiqh_ruling.dart';

/// Service to calculate fiqh rulings based on Hanafi madhab
class FiqhCalculatorService {

  /// Determines if a bleeding episode qualifies as valid Hayd
  ///
  /// Rules:
  /// - Must be at least 72 hours (3 days)
  /// - Must not exceed 240 hours (10 days)
  /// - Previous Tuhr must be at least 360 hours (15 days)
  bool isValidHayd({
    required DateTime bleedingStart,
    DateTime? bleedingEnd,
    DateTime? previousHaydEnd,
  }) {
    final now = DateTime.now();
    final endTime = bleedingEnd ?? now;
    final duration = endTime.difference(bleedingStart);

    // Check minimum duration (72 hours)
    if (duration.inHours < FiqhConstants.haydMinimumHours) {
      // If bleeding is still active and hasn't reached minimum, it's pending
      if (bleedingEnd == null) {
        return false; // Not yet valid, still ongoing
      }
      return false; // Ended before minimum - Istihada
    }

    // Check maximum duration (240 hours)
    if (duration.inHours > FiqhConstants.haydMaximumHours) {
      return false; // Exceeded maximum - becomes Istihada
    }

    // Check minimum Tuhr (purity) period between Hayds
    if (previousHaydEnd != null) {
      final tuhrDuration = bleedingStart.difference(previousHaydEnd);
      if (tuhrDuration.inHours < FiqhConstants.tuhrMinimumHours) {
        return false; // Not enough Tuhr - Istihada
      }
    }

    return true;
  }

  /// Calculate the current ruling for an active bleeding episode
  FiqhRuling calculateCurrentRuling({
    required DateTime bleedingStart,
    DateTime? previousHaydEnd,
  }) {
    final now = DateTime.now();
    final currentDuration = now.difference(bleedingStart);
    final hours = currentDuration.inHours;

    // Check if there was enough Tuhr before this bleeding
    bool sufficientTuhr = true;
    if (previousHaydEnd != null) {
      final tuhrDuration = bleedingStart.difference(previousHaydEnd);
      sufficientTuhr = tuhrDuration.inHours >= FiqhConstants.tuhrMinimumHours;
    }

    // Case 1: Bleeding less than 72 hours
    if (hours < FiqhConstants.haydMinimumHours) {
      // Could become Hayd if it continues, but treated as potential Hayd
      // Conservative ruling: assume Hayd until proven otherwise
      return FiqhRuling(
        bleedingType: BleedingType.hayd,
        purityState: PurityState.inHayd,
        salahProhibited: true,
        fastingProhibited: true,
        explanation: 'Blødning under 72 timer - behandles som Hayd indtil videre. '
                    'Hvis det stopper før 72 timer, vil det blive omklassificeret som Istihada.',
        stateStartTime: bleedingStart,
        durationHours: hours,
      );
    }

    // Case 2: Bleeding between 72-240 hours with sufficient Tuhr
    if (hours <= FiqhConstants.haydMaximumHours && sufficientTuhr) {
      return FiqhRuling(
        bleedingType: BleedingType.hayd,
        purityState: PurityState.inHayd,
        salahProhibited: true,
        fastingProhibited: true,
        explanation: 'Valid Hayd (menstruation). Salah og faste er forbudt.',
        stateStartTime: bleedingStart,
        durationHours: hours,
      );
    }

    // Case 3: Bleeding exceeds 240 hours OR insufficient Tuhr
    String reason = '';
    if (hours > FiqhConstants.haydMaximumHours) {
      reason = 'Blødning har overskredet 240 timer (10 dage)';
    } else if (!sufficientTuhr) {
      reason = 'Ikke nok Tuhr (renhed) siden sidste Hayd';
    }

    return FiqhRuling(
      bleedingType: BleedingType.istihada,
      purityState: PurityState.inIstihada,
      salahProhibited: false,
      fastingProhibited: false,
      explanation: 'Istihada (irregular blødning). $reason. '
                  'Salah er påkrævet med wudu før hver bøn. Faste er gyldigt.',
      stateStartTime: bleedingStart,
      durationHours: hours,
    );
  }

  /// Calculate ruling for a completed bleeding episode
  FiqhRuling calculateCompletedEpisodeRuling({
    required DateTime bleedingStart,
    required DateTime bleedingEnd,
    DateTime? previousHaydEnd,
  }) {
    final duration = bleedingEnd.difference(bleedingStart);
    final hours = duration.inHours;

    // Check Tuhr requirement
    bool sufficientTuhr = true;
    if (previousHaydEnd != null) {
      final tuhrDuration = bleedingStart.difference(previousHaydEnd);
      sufficientTuhr = tuhrDuration.inHours >= FiqhConstants.tuhrMinimumHours;
    }

    // Determine if it was valid Hayd
    final wasValidHayd = hours >= FiqhConstants.haydMinimumHours &&
                         hours <= FiqhConstants.haydMaximumHours &&
                         sufficientTuhr;

    if (wasValidHayd) {
      return FiqhRuling(
        bleedingType: BleedingType.hayd,
        purityState: PurityState.tuhr,
        salahProhibited: false,
        fastingProhibited: false,
        explanation: 'Afsluttet Hayd (${hours} timer / ${(hours / 24).toStringAsFixed(1)} dage). '
                    'Nu i Tuhr - salah og faste er påkrævet.',
        stateStartTime: bleedingEnd,
        durationHours: hours,
      );
    } else {
      String reason = '';
      if (hours < FiqhConstants.haydMinimumHours) {
        reason = 'mindre end 72 timer';
      } else if (hours > FiqhConstants.haydMaximumHours) {
        reason = 'mere end 240 timer';
      } else if (!sufficientTuhr) {
        reason = 'utilstrækkelig Tuhr før blødning';
      }

      return FiqhRuling(
        bleedingType: BleedingType.istihada,
        purityState: PurityState.tuhr,
        salahProhibited: false,
        fastingProhibited: false,
        explanation: 'Afsluttet Istihada ($reason). '
                    'Nu i Tuhr - salah og faste er påkrævet.',
        stateStartTime: bleedingEnd,
        durationHours: hours,
      );
    }
  }

  /// Get ruling for Tuhr (purity) state
  FiqhRuling getTuhrRuling({
    required DateTime lastBleedingEnd,
  }) {
    final now = DateTime.now();
    final tuhrDuration = now.difference(lastBleedingEnd);

    return FiqhRuling(
      bleedingType: BleedingType.hayd, // Not actively bleeding, but tracking Hayd
      purityState: PurityState.tuhr,
      salahProhibited: false,
      fastingProhibited: false,
      explanation: 'I Tuhr (renhed) i ${tuhrDuration.inHours} timer '
                  '(${(tuhrDuration.inHours / 24).toStringAsFixed(1)} dage). '
                  'Salah og faste er påkrævet.',
      stateStartTime: lastBleedingEnd,
      durationHours: tuhrDuration.inHours,
    );
  }

  /// Calculate duration between two dates in hours
  int calculateDurationInHours(DateTime start, DateTime end) {
    return end.difference(start).inHours;
  }

  /// Format duration for display
  String formatDuration(int hours) {
    final days = hours ~/ 24;
    final remainingHours = hours % 24;

    if (days == 0) {
      return '$hours timer';
    } else if (remainingHours == 0) {
      return '$days dage';
    } else {
      return '$days dage, $remainingHours timer';
    }
  }
}