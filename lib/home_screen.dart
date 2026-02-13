import 'package:flutter/material.dart';
import 'episode_service.dart';
import 'package:intl/intl.dart';
import 'core/db/app_database.dart';
import 'episode_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppDatabase db;
  late final EpisodeService service;

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    service = EpisodeService(EpisodeRepository(db));
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
          appBar: AppBar(title: const Text("Hayd Kalender")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Status kort
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current == null
                              ? "Status: Tuhr"
                              : "Status: Blødning registreret",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (current != null)
                          Text("Start: ${formatDate(current.start)}"),
                        if (current == null && episodes.isNotEmpty)
                          Text(
                            "Seneste stop: ${episodes.last.end != null ? formatDate(episodes.last.end!) : '-'}",
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Knapper
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: startBleeding,
                        child: const Text("Jeg har set blod"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: stopBleeding,
                        child: const Text("Blodet er stoppet"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Historik
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Historik",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: episodes.isEmpty
                      ? const Center(child: Text("Ingen episoder endnu."))
                      : ListView.builder(
                          itemCount: episodes.length,
                          itemBuilder: (context, i) {
                            final e =
                                episodes[episodes.length -
                                    1 -
                                    i]; // nyeste øverst
                            return ListTile(
                              title: Text("Start: ${formatDate(e.start)}"),
                              subtitle: Text(
                                e.end == null
                                    ? "Aktiv (ikke stoppet endnu)"
                                    : "Stop: ${formatDate(e.end!)}",
                              ),
                            );
                          },
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
