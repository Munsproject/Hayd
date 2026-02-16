/// Represents a woman's menstrual habit (ʿĀdah)
/// A habit is established after one complete valid cycle (hayd + tuhr)
class Habit {
  /// Duration of habitual menstruation in hours
  final int haydDurationHours;

  /// Duration of habitual purity (tuhr) in hours
  final int tuhrDurationHours;

  /// When this habit was established
  final DateTime establishedDate;

  /// Number of cycles this habit has been observed
  final int cycleCount;

  const Habit({
    required this.haydDurationHours,
    required this.tuhrDurationHours,
    required this.establishedDate,
    this.cycleCount = 1,
  });

  /// Create a habit from days (convenience constructor)
  factory Habit.fromDays({
    required int haydDays,
    required int tuhrDays,
    required DateTime establishedDate,
    int cycleCount = 1,
  }) {
    return Habit(
      haydDurationHours: haydDays * 24,
      tuhrDurationHours: tuhrDays * 24,
      establishedDate: establishedDate,
      cycleCount: cycleCount,
    );
  }

  /// Get hayd duration in days
  int get haydDays => (haydDurationHours / 24).round();

  /// Get tuhr duration in days
  int get tuhrDays => (tuhrDurationHours / 24).round();

  /// Total cycle length in hours
  int get cycleLengthHours => haydDurationHours + tuhrDurationHours;

  /// Total cycle length in days
  int get cycleLengthDays => (cycleLengthHours / 24).round();

  /// Check if this habit is established (at least one complete cycle)
  bool get isEstablished => cycleCount >= 1;

  /// Create a new habit with updated values (for habit changes)
  Habit copyWith({
    int? haydDurationHours,
    int? tuhrDurationHours,
    DateTime? establishedDate,
    int? cycleCount,
  }) {
    return Habit(
      haydDurationHours: haydDurationHours ?? this.haydDurationHours,
      tuhrDurationHours: tuhrDurationHours ?? this.tuhrDurationHours,
      establishedDate: establishedDate ?? this.establishedDate,
      cycleCount: cycleCount ?? this.cycleCount,
    );
  }

  @override
  String toString() {
    return 'Habit(hayd: ${haydDays}d, tuhr: ${tuhrDays}d, cycles: $cycleCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.haydDurationHours == haydDurationHours &&
        other.tuhrDurationHours == tuhrDurationHours;
  }

  @override
  int get hashCode => haydDurationHours.hashCode ^ tuhrDurationHours.hashCode;
}
