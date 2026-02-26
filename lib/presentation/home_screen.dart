import 'package:flutter/material.dart';
import 'package:hayd_kalender/domain/services/episode_service.dart';
import 'package:hayd_kalender/domain/services/fiqh_calculator_service.dart';
import 'package:hayd_kalender/domain/models/fiqh_ruling.dart';
import 'package:hayd_kalender/core/db/app_database.dart';
import 'package:hayd_kalender/domain/repositories/episode_repository.dart';
import 'package:hayd_kalender/presentation/widgets/status_card.dart';
import 'package:hayd_kalender/presentation/history_screen.dart';
import 'package:hayd_kalender/presentation/calendar_screen.dart';
import 'package:hayd_kalender/presentation/fiqh_rulings_screen.dart';
import 'package:hayd_kalender/presentation/debug_test_screen.dart';
import 'package:hayd_kalender/presentation/app_theme.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppDatabase db;
  late final EpisodeService service;
  late final FiqhCalculatorService fiqhCalculator;

  // User's norm (habit) — in a full implementation these would be persisted
  int normHaydDays = 6;
  int normTuhrDays = 25;

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    service = EpisodeService(EpisodeRepository(db));
    fiqhCalculator = FiqhCalculatorService();
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  Future<void> startBleeding() async {
    await service.startBleeding(DateTime.now());
  }

  Future<void> stopBleeding() async {
    await service.stopBleeding(DateTime.now());
  }

  Future<FiqhRuling?> _getCurrentRuling(List<Episode> episodes) async {
    if (episodes.isEmpty) return null;

    final activeEpisodes = episodes.where((e) => e.end == null).toList();

    if (activeEpisodes.isEmpty) {
      final lastEpisode = episodes.last;
      if (lastEpisode.end != null) {
        return fiqhCalculator.getTuhrRuling(
          lastBleedingEnd: lastEpisode.end!,
        );
      }
      return null;
    }

    final current = activeEpisodes.last;
    final previousCompleted = episodes
        .where((e) => e.end != null && e.start.isBefore(current.start))
        .toList();

    return fiqhCalculator.calculateCurrentRuling(
      bleedingStart: current.start,
      previousHaydEnd:
          previousCompleted.isNotEmpty ? previousCompleted.last.end : null,
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Episode>>(
      stream: service.watchEpisodes(),
      builder: (context, snapshot) {
        final episodes = snapshot.data ?? [];
        final active = episodes.where((e) => e.end == null).toList();
        final current = active.isNotEmpty ? active.last : null;

        return Scaffold(
          backgroundColor: AppTheme.ivory,
          appBar: AppBar(
            title: const Text('Hayd Kalender'),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CalendarScreen())),
                tooltip: 'Kalender',
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FiqhRulingsScreen())),
                tooltip: 'Islamiske regler',
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen())),
                tooltip: 'Se historik',
              ),
              IconButton(
                icon: const Icon(Icons.science_outlined),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DebugTestScreen())),
                tooltip: 'Test scenarier',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Status card with fiqh ruling
                FutureBuilder<FiqhRuling?>(
                  future: _getCurrentRuling(episodes),
                  builder: (context, rulingSnapshot) {
                    return StatusCard(
                      ruling: rulingSnapshot.data,
                      currentBleedingStart: current?.start,
                      normHaydDays: normHaydDays,
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Norm info card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.lavLight,
                    borderRadius: BorderRadius.circular(14),
                    border: const Border(
                      left: BorderSide(color: AppTheme.lavender, width: 4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _NormTile(
                          label: 'Norm Hayd',
                          value: normHaydDays,
                          color: AppTheme.rose,
                        ),
                      ),
                      Expanded(
                        child: _NormTile(
                          label: 'Norm Tuhr',
                          value: normTuhrDays,
                          color: AppTheme.mint,
                        ),
                      ),
                      Expanded(
                        child: _NormTile(
                          label: 'Total',
                          value: normHaydDays + normTuhrDays,
                          color: AppTheme.plum,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: current == null ? startBleeding : null,
                        icon: const Icon(Icons.water_drop),
                        label: const Text('Jeg har set blod'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppTheme.rose,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.roseLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: current != null ? stopBleeding : null,
                        icon: const Icon(Icons.stop_circle),
                        label: const Text('Blodet er stoppet'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppTheme.mint,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.mintLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Seneste episoder',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkPlum,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: episodes.isEmpty
                      ? const Center(
                          child: Text(
                            'Ingen episoder endnu.\nTryk på "Jeg har set blod" for at starte.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: AppTheme.warmGray),
                          ),
                        )
                      : ListView.builder(
                          itemCount: episodes.length > 5 ? 5 : episodes.length,
                          itemBuilder: (context, i) {
                            final e = episodes[episodes.length - 1 - i];

                            return FutureBuilder<FiqhRuling?>(
                              future: e.end != null
                                  ? Future.value(
                                      fiqhCalculator.calculateCompletedEpisodeRuling(
                                        bleedingStart: e.start,
                                        bleedingEnd: e.end!,
                                        previousHaydEnd: i < episodes.length - 1
                                            ? episodes[episodes.length - 2 - i].end
                                            : null,
                                      ),
                                    )
                                  : _getCurrentRuling(episodes),
                              builder: (context, rulingSnapshot) {
                                final ruling = rulingSnapshot.data;
                                final isHayd = ruling?.isValidHayd ?? false;
                                final typeColor = isHayd ? AppTheme.rose : AppTheme.gold;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: typeColor.withOpacity(0.4)),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      isHayd ? Icons.water_drop : Icons.warning,
                                      color: typeColor,
                                    ),
                                    title: Text(
                                      'Start: ${formatDate(e.start)}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.end == null
                                              ? 'Aktiv (ikke stoppet endnu)'
                                              : 'Stop: ${formatDate(e.end!)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        if (ruling != null)
                                          Text(
                                            isHayd ? 'Hayd' : 'Istihada',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: typeColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: e.end == null
                                        ? const Icon(Icons.circle, color: AppTheme.rose, size: 10)
                                        : null,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

                if (episodes.length > 5)
                  TextButton(
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen())),
                    child: const Text('Se alle episoder →'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NormTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _NormTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.warmGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
