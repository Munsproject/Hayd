import 'package:hayd_kalender/core/db/app_database.dart';
import 'package:hayd_kalender/domain/models/cycle.dart';
import 'package:hayd_kalender/domain/services/fiqh_calculator_service.dart';
import 'package:hayd_kalender/core/enums/bleeding_type.dart';

/// Service to analyze episodes and create Cycle objects
class CycleAnalyzerService {
  final FiqhCalculatorService fiqhCalculator;

  CycleAnalyzerService(this.fiqhCalculator);

  /// Analyze all episodes and convert them into Cycle objects
  List<Cycle> analyzeCycles(List<Episode> episodes) {
    if (episodes.isEmpty) return [];

    // Sort episodes by start date (oldest first)
    final sortedEpisodes = List<Episode>.from(episodes)
      ..sort((a, b) => a.start.compareTo(b.start));

    final cycles = <Cycle>[];

    for (int i = 0; i < sortedEpisodes.length; i++) {
      final episode = sortedEpisodes[i];

      // Get previous episode's end date for Tuhr calculation
      final previousEpisodeEnd = i > 0 ? sortedEpisodes[i - 1].end : null;

      // Calculate bleeding duration
      final bleedingEnd = episode.end ?? DateTime.now();
      final bleedingDuration = bleedingEnd.difference(episode.start);

      // Determine if it's valid Hayd
      final isValidHayd = fiqhCalculator.isValidHayd(
        bleedingStart: episode.start,
        bleedingEnd: episode.end,
        previousHaydEnd: previousEpisodeEnd,
      );

      final bleedingType = isValidHayd ? BleedingType.hayd : BleedingType.istihada;

      // Calculate Tuhr duration (time until next episode)
      int? tuhrDuration;
      DateTime? tuhrEnd;

      if (episode.end != null && i < sortedEpisodes.length - 1) {
        // There's a next episode
        final nextEpisode = sortedEpisodes[i + 1];
        tuhrEnd = nextEpisode.start;
        tuhrDuration = tuhrEnd.difference(episode.end!).inHours;
      }

      cycles.add(Cycle(
        bleedingEpisode: episode,
        bleedingType: bleedingType,
        bleedingDurationHours: bleedingDuration.inHours,
        tuhrDurationHours: tuhrDuration,
        tuhrEndDate: tuhrEnd,
      ));
    }

    return cycles;
  }

  /// Get only valid Hayd cycles
  List<Cycle> getValidHaydCycles(List<Episode> episodes) {
    final allCycles = analyzeCycles(episodes);
    return allCycles.where((cycle) => cycle.isValidHayd).toList();
  }

  /// Calculate average cycle length from valid Hayd cycles
  /// Returns null if there aren't enough cycles
  double? calculateAverageCycleLength(List<Episode> episodes) {
    final validCycles = getValidHaydCycles(episodes);

    // Need at least 2 complete cycles to calculate average
    final completeCycles = validCycles
        .where((cycle) => cycle.isComplete)
        .toList();

    if (completeCycles.length < 2) return null;

    final totalHours = completeCycles
        .map((cycle) => cycle.totalCycleLengthHours ?? 0)
        .reduce((a, b) => a + b);

    return totalHours / completeCycles.length / 24.0; // Return in days
  }

  /// Calculate average Hayd (bleeding) duration from valid cycles
  double? calculateAverageHaydDuration(List<Episode> episodes) {
    final validCycles = getValidHaydCycles(episodes);

    if (validCycles.isEmpty) return null;

    final totalHours = validCycles
        .map((cycle) => cycle.bleedingDurationHours)
        .reduce((a, b) => a + b);

    return totalHours / validCycles.length / 24.0; // Return in days
  }

  /// Get the most recent cycle
  Cycle? getMostRecentCycle(List<Episode> episodes) {
    final cycles = analyzeCycles(episodes);
    return cycles.isEmpty ? null : cycles.last;
  }

  /// Predict next Hayd start date based on average cycle
  /// Returns null if not enough data
  DateTime? predictNextHaydStart(List<Episode> episodes) {
    final avgCycleLength = calculateAverageCycleLength(episodes);
    if (avgCycleLength == null) return null;

    final mostRecent = getMostRecentCycle(episodes);
    if (mostRecent == null || mostRecent.bleedingEnd == null) return null;

    return mostRecent.bleedingEnd!.add(
      Duration(hours: (avgCycleLength * 24).round()),
    );
  }
}