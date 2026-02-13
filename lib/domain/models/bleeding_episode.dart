import 'package:hayd_kalender/core/db/app_database.dart';

/// Domain model for a bleeding episode
/// This separates domain logic from database implementation
class BleedingEpisode {
  final int? id;
  final DateTime start;
  final DateTime? end;

  BleedingEpisode({
    this.id,
    required this.start,
    this.end,
  });

  /// Create from database Episode
  factory BleedingEpisode.fromEpisode(Episode episode) {
    return BleedingEpisode(
      id: episode.id,
      start: episode.start,
      end: episode.end,
    );
  }

  /// Convert to database Episode
  Episode toEpisode() {
    return Episode(
      id: id ?? 0,
      start: start,
      end: end,
    );
  }

  BleedingEpisode copyWith({
    int? id,
    DateTime? start,
    DateTime? end,
  }) {
    return BleedingEpisode(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  /// Check if bleeding is currently active
  bool get isActive => end == null;

  /// Get duration in hours
  int get durationInHours {
    final endTime = end ?? DateTime.now();
    return endTime.difference(start).inHours;
  }

  /// Get duration in days
  double get durationInDays => durationInHours / 24.0;

  /// Format duration for display
  String get formattedDuration {
    final days = durationInHours ~/ 24;
    final hours = durationInHours % 24;

    if (days == 0) {
      return '$hours timer';
    } else if (hours == 0) {
      return '$days dage';
    } else {
      return '$days dage, $hours timer';
    }
  }

  @override
  String toString() {
    return 'BleedingEpisode(id: $id, start: $start, end: $end, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BleedingEpisode &&
        other.id == id &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => id.hashCode ^ start.hashCode ^ end.hashCode;
}