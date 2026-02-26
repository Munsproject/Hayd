import 'package:flutter/material.dart';
import 'package:hayd_kalender/core/db/app_database.dart';
import 'package:hayd_kalender/domain/repositories/episode_repository.dart';
import 'package:hayd_kalender/domain/services/cycle_analyzer_service.dart';
import 'package:hayd_kalender/domain/services/fiqh_calculator_service.dart';
import 'package:hayd_kalender/presentation/widgets/cycle_timeline.dart';
import 'package:hayd_kalender/presentation/app_theme.dart';

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
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        title: const Text('Historik'),
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
                  'Ingen historik endnu.\nStart med at registrere din første blødning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppTheme.warmGray),
                ),
              ),
            );
          }

          final cycles = analyzer.analyzeCycles(episodes);
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.plum.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistik',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkPlum,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _StatRow(
                        icon: Icons.water_drop,
                        label: 'Totalt antal episoder',
                        value: episodes.length.toString(),
                        color: AppTheme.rose,
                      ),
                      _StatRow(
                        icon: Icons.check_circle,
                        label: 'Gyldige Hayd-cyklusser',
                        value: validHaydCount.toString(),
                        color: AppTheme.mint,
                      ),
                      if (avgHaydDuration != null)
                        _StatRow(
                          icon: Icons.calendar_today,
                          label: 'Gennemsnitlig Hayd varighed',
                          value: '${avgHaydDuration.toStringAsFixed(1)} dage',
                          color: AppTheme.rose,
                        ),
                      if (avgCycleLength != null)
                        _StatRow(
                          icon: Icons.repeat,
                          label: 'Gennemsnitlig cykluslængde',
                          value: '${avgCycleLength.toStringAsFixed(1)} dage',
                          color: AppTheme.plum,
                        ),
                      if (nextPrediction != null) ...[
                        const SizedBox(height: 6),
                        const Divider(),
                        const SizedBox(height: 6),
                        _StatRow(
                          icon: Icons.event,
                          label: 'Forventet næste Hayd',
                          value: _formatDate(nextPrediction),
                          color: AppTheme.plum,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Cyklus Historik',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkPlum,
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
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
