import 'package:hayd_kalender/core/db/app_database.dart';
import 'package:hayd_kalender/core/enums/bleeding_type.dart';

/// Represents a complete menstrual cycle
/// A cycle includes the bleeding period (Hayd or Istihada) and the following Tuhr
class Cycle {
  /// The bleeding episode
  final Episode bleedingEpisode;

  /// Type of bleeding (Hayd or Istihada)
  final BleedingType bleedingType;

  /// Duration of bleeding in hours
  final int bleedingDurationHours;

  /// Duration of following Tuhr (purity) in hours
  /// Null if this is the current/latest cycle
  final int? tuhrDurationHours;

  /// When the Tuhr period ended (start of next bleeding)
  /// Null if this is the current/latest cycle
  final DateTime? tuhrEndDate;

  Cycle({
    required this.bleedingEpisode,
    required this.bleedingType,
    required this.bleedingDurationHours,
    this.tuhrDurationHours,
    this.tuhrEndDate,
  });

  /// Get the start date of bleeding
  DateTime get bleedingStart => bleedingEpisode.start;

  /// Get the end date of bleeding
  DateTime? get bleedingEnd => bleedingEpisode.end;

  /// Check if bleeding was valid Hayd
  bool get isValidHayd => bleedingType == BleedingType.hayd;

  /// Check if this cycle is complete (has both bleeding and tuhr ended)
  bool get isComplete => bleedingEnd != null && tuhrEndDate != null;

  /// Get total cycle length (bleeding + tuhr) in hours
  /// Returns null if cycle is not complete
  int? get totalCycleLengthHours {
    if (tuhrDurationHours == null) return null;
    return bleedingDurationHours + tuhrDurationHours!;
  }

  /// Get total cycle length in days
  double? get totalCycleLengthDays {
    final hours = totalCycleLengthHours;
    if (hours == null) return null;
    return hours / 24.0;
  }

  @override
  String toString() {
    return 'Cycle(type: $bleedingType, '
           'bleeding: ${bleedingDurationHours}h, '
           'tuhr: ${tuhrDurationHours ?? "ongoing"}h)';
  }
}