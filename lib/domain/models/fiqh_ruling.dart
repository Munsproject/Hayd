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

  @override
  String toString() {
    return 'FiqhRuling(type: $bleedingType, state: $purityState, '
           'salah: ${salahProhibited ? "prohibited" : "required"}, '
           'fasting: ${fastingProhibited ? "prohibited" : "valid"})';
  }
}