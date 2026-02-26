import 'package:hayd_kalender/core/enums/bleeding_type.dart';

/// Represents the fiqh ruling for a bleeding episode or current state
class FiqhRuling {
  /// Type of bleeding (Hayd, Istihada, Nifas)
  final BleedingType bleedingType;

  /// Current purity state
  final PurityState purityState;

  /// Is salah (prayer) prohibited?
  final bool salahProhibited;

  /// Is fasting prohibited?
  final bool fastingProhibited;

  /// Is Quran recitation (tilawah) prohibited?
  /// Hanafi: recitation is forbidden during Hayd.
  final bool quranRecitationProhibited;

  /// Is du'a recitation allowed?
  /// Allowed even during Hayd (e.g. Ayat ul-Kursi, Quls with niyyah of du'a).
  final bool duaRecitationAllowed;

  /// Is intimacy with spouse forbidden until the norm (habit) period has passed?
  final bool intimacyForbiddenUntilNorm;

  /// Explanation of the ruling (helpful for user)
  final String explanation;

  /// Duration of current bleeding/purity in hours
  final int? durationHours;

  /// When the current state started
  final DateTime stateStartTime;

  const FiqhRuling({
    required this.bleedingType,
    required this.purityState,
    required this.salahProhibited,
    required this.fastingProhibited,
    required this.quranRecitationProhibited,
    required this.duaRecitationAllowed,
    required this.intimacyForbiddenUntilNorm,
    required this.explanation,
    required this.stateStartTime,
    this.durationHours,
  });

  /// Check if currently in a state where religious obligations are prohibited
  bool get isInRestrictedState => salahProhibited || fastingProhibited;

  /// Check if in valid Hayd
  bool get isValidHayd => bleedingType == BleedingType.hayd;

  /// Check if in Istihada (requires wudu for each salah)
  bool get isIstihada => bleedingType == BleedingType.istihada;

  /// Quran recitation is forbidden but du'a recitation is allowed
  bool get haydQuranRule => quranRecitationProhibited && duaRecitationAllowed;

  @override
  String toString() {
    return 'FiqhRuling(type: $bleedingType, state: $purityState, '
           'salah: ${salahProhibited ? "forbudt" : "skyldes"}, '
           'fasting: ${fastingProhibited ? "forbudt" : "skyldes"})';
  }
}
