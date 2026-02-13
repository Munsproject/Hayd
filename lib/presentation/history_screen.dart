import 'package:flutter/material.dart';
import 'package:hayd_kalender/core/db/app_database.dart';
import 'package:hayd_kalender/domain/repositories/episode_repository.dart';
import 'package:hayd_kalender/domain/services/cycle_analyzer_service.dart';
import 'package:hayd_kalender/domain/services/fiqh_calculator_service.dart';
import 'package:hayd_kalender/presentation/widgets/cycle_timeline.dart';

/// Screen to display detailed history of cycles and episodes
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final AppDatabase db;
  late final EpisodeRepository repo;
  late final CycleAnalyzerService analyzer;

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    repo = EpisodeRepository(db);
    analyzer = CycleAnalyzerService(FiqhCalculatorService());
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historik"),
        elevation: 0,
      ),
      body: StreamBuilder<List<Episode>>(
        stream: repo.watchEpisodes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final episodes = snapshot.data ?? [];

          if (episodes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  "Ingen historik endnu.\nStart med at registrere din første blødning.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          // Analyze cycles
          final cycles = analyzer.analyzeCycles(episodes);

          // Calculate statistics
          final avgCycleLength = analyzer.calculateAverageCycleLength(episodes);
          final avgHaydDuration = analyzer.calculateAverageHaydDuration(episodes);
          final nextPrediction = analyzer.predictNextHaydStart(episodes);
          final validHaydCount = cycles.where((c) => c.isValidHayd).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Statistik",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _StatRow(
                          icon: Icons.water_drop,
                          label: "Totalt antal episoder",
                          value: episodes.length.toString(),
                        ),

                        _StatRow(
                          icon: Icons.check_circle,
                          label: "Valide Hayd cyklusser",
                          value: validHaydCount.toString(),
                        ),

                        if (avgHaydDuration != null)
                          _StatRow(
                            icon: Icons.calendar_today,
                            label: "Gennemsnitlig Hayd varighed",
                            value: "${avgHaydDuration.toStringAsFixed(1)} dage",
                          ),

                        if (avgCycleLength != null)
                          _StatRow(
                            icon: Icons.repeat,
                            label: "Gennemsnitlig cyklus længde",
                            value: "${avgCycleLength.toStringAsFixed(1)} dage",
                          ),

                        if (nextPrediction != null) ...[
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          _StatRow(
                            icon: Icons.event,
                            label: "Forventet næste Hayd",
                            value: _formatDate(nextPrediction),
                            valueColor: Colors.blue,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Cycle timeline
                const Text(
                  "Cyklus Historik",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                CycleTimeline(cycles: cycles),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}

/// Widget to display a single statistic row
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}