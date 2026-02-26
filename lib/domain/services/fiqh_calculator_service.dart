import 'package:hayd_kalender/core/enums/bleeding_type.dart';
import 'package:hayd_kalender/core/constants/fiqh_constants.dart';
import 'package:hayd_kalender/domain/models/fiqh_ruling.dart';

/// Service to calculate fiqh rulings based on Hanafi madhab
class FiqhCalculatorService {
  final DateTime Function() _now;

  FiqhCalculatorService({DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

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
    final now = _now();
    final endTime = bleedingEnd ?? now;
    final duration = endTime.difference(bleedingStart);

    if (duration.inHours < FiqhConstants.haydMinimumHours) {
      if (bleedingEnd == null) return false;
      return false;
    }

    if (duration.inHours > FiqhConstants.haydMaximumHours) return false;

    if (previousHaydEnd != null) {
      final tuhrDuration = bleedingStart.difference(previousHaydEnd);
      if (tuhrDuration.inHours < FiqhConstants.tuhrMinimumHours) return false;
    }

    return true;
  }

  /// Calculate the current ruling for an active bleeding episode
  FiqhRuling calculateCurrentRuling({
    required DateTime bleedingStart,
    DateTime? previousHaydEnd,
  }) {
    final now = _now();
    final currentDuration = now.difference(bleedingStart);
    final hours = currentDuration.inHours;

    bool sufficientTuhr = true;
    if (previousHaydEnd != null) {
      final tuhrDuration = bleedingStart.difference(previousHaydEnd);
      sufficientTuhr = tuhrDuration.inHours >= FiqhConstants.tuhrMinimumHours;
    }

    // Case 1: Bleeding less than 72 hours — treated as potential Hayd
    if (hours < FiqhConstants.haydMinimumHours) {
      return FiqhRuling(
        bleedingType: BleedingType.hayd,
        purityState: PurityState.inHayd,
        salahProhibited: true,
        fastingProhibited: true,
        quranRecitationProhibited: true,
        duaRecitationAllowed: true,
        intimacyForbiddenUntilNorm: true,
        explanation: 'Blødning under 72 timer — behandles som Hayd indtil videre. '
                    'Koranlæsning er forbudt. Recitation med intention om duʿā er tilladt '
                    '(fx Āyat ul-Kursī og Quls). '
                    'Intimitet er forbudt til norm-perioden er udløbet. '
                    'Hvis blødning stopper før 72 timer omklassificeres til Istihada.',
        stateStartTime: bleedingStart,
        durationHours: hours,
      );
    }

    // Case 2: Valid Hayd (72–240 hours, sufficient tuhr)
    if (hours <= FiqhConstants.haydMaximumHours && sufficientTuhr) {
      return FiqhRuling(
        bleedingType: BleedingType.hayd,
        purityState: PurityState.inHayd,
        salahProhibited: true,
        fastingProhibited: true,
        quranRecitationProhibited: true,
        duaRecitationAllowed: true,
        intimacyForbiddenUntilNorm: true,
        explanation: 'Gyldig Hayd (menstruation). Salah skyldes ikke. Faste skyldes. '
                    'Koranlæsning er forbudt. Recitation med intention om duʿā er tilladt. '
                    'Intimitet er forbudt til norm-perioden er fuldt udløbet.',
        stateStartTime: bleedingStart,
        durationHours: hours,
      );
    }

    // Case 3: Istihada — bleeding exceeds 240 hours OR insufficient tuhr
    String reason = '';
    if (hours > FiqhConstants.haydMaximumHours) {
      reason = 'Blødning har overskredet 240 timer (10 dage)';
    } else if (!sufficientTuhr) {
      reason = 'Ikke nok tuhr (renhed) siden sidste Hayd';
    }

    return FiqhRuling(
      bleedingType: BleedingType.istihada,
      purityState: PurityState.inIstihada,
      salahProhibited: false,
      fastingProhibited: false,
      quranRecitationProhibited: false,
      duaRecitationAllowed: true,
      intimacyForbiddenUntilNorm: false,
      explanation: 'Istihada (uregelmæssig blødning). $reason. '
                  'Salah skyldes — wudu fornyes ved hver bøn. Faste skyldes. '
                  'Koranlæsning, tawaf og intimitet er tilladt.',
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

    bool sufficientTuhr = true;
    if (previousHaydEnd != null) {
      final tuhrDuration = bleedingStart.difference(previousHaydEnd);
      sufficientTuhr = tuhrDuration.inHours >= FiqhConstants.tuhrMinimumHours;
    }

    final wasValidHayd = hours >= FiqhConstants.haydMinimumHours &&
                         hours <= FiqhConstants.haydMaximumHours &&
                         sufficientTuhr;

    if (wasValidHayd) {
      return FiqhRuling(
        bleedingType: BleedingType.hayd,
        purityState: PurityState.tuhr,
        salahProhibited: false,
        fastingProhibited: false,
        quranRecitationProhibited: false,
        duaRecitationAllowed: true,
        intimacyForbiddenUntilNorm: false,
        explanation: 'Afsluttet Hayd (${hours} timer / ${(hours / 24).toStringAsFixed(1)} dage). '
                    'Nu i Tuhr — salah skyldes, faste skyldes.',
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
        reason = 'utilstrækkelig tuhr før blødning';
      }

      return FiqhRuling(
        bleedingType: BleedingType.istihada,
        purityState: PurityState.tuhr,
        salahProhibited: false,
        fastingProhibited: false,
        quranRecitationProhibited: false,
        duaRecitationAllowed: true,
        intimacyForbiddenUntilNorm: false,
        explanation: 'Afsluttet Istihada ($reason). '
                    'Nu i Tuhr — salah skyldes, faste skyldes.',
        stateStartTime: bleedingEnd,
        durationHours: hours,
      );
    }
  }

  /// Get ruling for Tuhr (purity) state
  FiqhRuling getTuhrRuling({
    required DateTime lastBleedingEnd,
  }) {
    final now = _now();
    final tuhrDuration = now.difference(lastBleedingEnd);

    return FiqhRuling(
      bleedingType: BleedingType.hayd,
      purityState: PurityState.tuhr,
      salahProhibited: false,
      fastingProhibited: false,
      quranRecitationProhibited: false,
      duaRecitationAllowed: true,
      intimacyForbiddenUntilNorm: false,
      explanation: 'I Tuhr (renhed) i ${tuhrDuration.inHours} timer '
                  '(${(tuhrDuration.inHours / 24).toStringAsFixed(1)} dage). '
                  'Salah og faste skyldes.',
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
