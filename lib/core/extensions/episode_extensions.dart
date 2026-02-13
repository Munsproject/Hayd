import 'package:hayd_kalender/core/db/app_database.dart';

/// Extension methods for Episode class
extension EpisodeExtensions on Episode {
  /// Check if this episode is currently active (bleeding hasn't stopped)
  bool get isActive => end == null;

  /// Get the duration of this episode in hours
  int get durationInHours {
    final endTime = end ?? DateTime.now();
    return endTime.difference(start).inHours;
  }

  /// Get the duration in days (decimal)
  double get durationInDays {
    return durationInHours / 24.0;
  }
}