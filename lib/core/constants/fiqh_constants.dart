/// Hanafi Fiqh constants for menstruation calculations
/// All durations are in hours for precise calculation
class FiqhConstants {
  // Hayd (Menstruation) limits
  /// Minimum duration for valid Hayd: 72 hours (3 days)
  static const int haydMinimumHours = 72;

  /// Maximum duration for valid Hayd: 240 hours (10 days)
  static const int haydMaximumHours = 240;

  // Tuhr (Purity) limits
  /// Minimum duration between two valid Hayds: 360 hours (15 days)
  static const int tuhrMinimumHours = 360;

  // Nifas (Postpartum bleeding) limits
  /// Maximum duration for Nifas: 960 hours (40 days)
  static const int nifasMaximumHours = 960;

  // Minimum age for Hayd
  /// Minimum age for Hayd: 9 Hijri (Islamic calendar) years — Hanafi Madhab
  static const int haydMinimumAgeHijriYears = 9;

  /// Approximate days equivalent of 9 Hijri years
  static const int haydMinimumAgeDaysApprox = 3285;

  // Helper getters for readability
  static Duration get haydMinimum => Duration(hours: haydMinimumHours);
  static Duration get haydMaximum => Duration(hours: haydMaximumHours);
  static Duration get tuhrMinimum => Duration(hours: tuhrMinimumHours);
  static Duration get nifasMaximum => Duration(hours: nifasMaximumHours);

  // Days equivalents (for display purposes)
  static const int haydMinimumDays = 3;
  static const int haydMaximumDays = 10;
  static const int tuhrMinimumDays = 15;
  static const int nifasMaximumDays = 40;
}
