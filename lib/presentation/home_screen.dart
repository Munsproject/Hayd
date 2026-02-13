import 'package:flutter/material.dart';
import 'package:hayd_kalender/domain/services/episode_service.dart';
import 'package:hayd_kalender/domain/services/fiqh_calculator_service.dart';
import 'package:hayd_kalender/domain/models/fiqh_ruling.dart';
import 'package:hayd_kalender/core/db/app_database.dart';
import 'package:hayd_kalender/domain/repositories/episode_repository.dart';
import 'package:hayd_kalender/presentation/widgets/status_card.dart';
import 'package:hayd_kalender/presentation/history_screen.dart';
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

  /// Calculate current fiqh ruling based on episodes
  Future<FiqhRuling?> _getCurrentRuling(List<Episode> episodes) async {
    if (episodes.isEmpty) return null;

    final activeEpisodes = episodes.where((e) => e.end == null).toList();

    if (activeEpisodes.isEmpty) {
      // In Tuhr state
      final lastEpisode = episodes.last;
      if (lastEpisode.end != null) {
        return fiqhCalculator.getTuhrRuling(
          lastBleedingEnd: lastEpisode.end!,
        );
      }
      return null;
    }

    // Active bleeding
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
          appBar: AppBar(
            title: const Text("Hayd Kalender"),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
                tooltip: "Se historik",
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
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: current == null ? startBleeding : null,
                        icon: const Icon(Icons.water_drop),
                        label: const Text("Jeg har set blod"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: current != null ? stopBleeding : null,
                        icon: const Icon(Icons.stop_circle),
                        label: const Text("Blodet er stoppet"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent episodes
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Seneste Episoder",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: episodes.isEmpty
                      ? const Center(
                          child: Text(
                            "Ingen episoder endnu.\nTryk på 'Jeg har set blod' for at starte.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
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

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Icon(
                                      isHayd ? Icons.water_drop : Icons.warning,
                                      color: isHayd ? Colors.red : Colors.orange,
                                    ),
                                    title: Text(
                                      "Start: ${formatDate(e.start)}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.end == null
                                              ? "Aktiv (ikke stoppet endnu)"
                                              : "Stop: ${formatDate(e.end!)}",
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        if (ruling != null)
                                          Text(
                                            isHayd ? "Hayd" : "Istihada",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isHayd ? Colors.red : Colors.orange,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: e.end == null
                                        ? const Icon(Icons.circle, color: Colors.red, size: 12)
                                        : null,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

                // View all history button
                if (episodes.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );
                      },
                      child: const Text("Se alle episoder →"),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}