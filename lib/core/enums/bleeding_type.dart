/// Types of bleeding according to Hanafi fiqh
enum BleedingType {
  /// Hayd - Valid menstruation (72-240 hours)
  hayd,

  /// Istihada - Irregular bleeding (outside valid Hayd rules)
  istihada,

  /// Nifas - Postpartum bleeding (up to 40 days)
  nifas,
}

/// Current state of purity/bleeding
enum PurityState {
  /// Tuhr - State of purity (no bleeding)
  tuhr,

  /// In Hayd - Currently menstruating (prayer/fasting prohibited)
  inHayd,

  /// In Istihada - Irregular bleeding (prayer/fasting required with wudu)
  inIstihada,

  /// In Nifas - Postpartum bleeding (prayer/fasting prohibited)
  inNifas,
}

/// Status of religious obligations
enum ObligationStatus {
  /// Salah is required
  salahRequired,

  /// Salah is prohibited
  salahProhibited,

  /// Fasting is valid
  fastingValid,

  /// Fasting is prohibited
  fastingProhibited,
}