import 'package:drift/drift.dart';
import 'core/db/app_database.dart';

class EpisodeRepository {
  final AppDatabase db;

  EpisodeRepository(this.db);

  Stream<List<Episode>> watchEpisodes() => db.watchAllEpisodes();

  Future<void> startEpisode(DateTime start) async {
    await db.insertEpisode(EpisodesCompanion.insert(start: start));
  }

  Future<void> stopActiveEpisode(DateTime endTime) async {
    final all = await db.getAllEpisodes();
    final active = all.where((e) => e.end == null).toList();
    if (active.isEmpty) return;

    final latestActive = active.last;
    await db.updateEpisode(latestActive.copyWith(end: Value(endTime)));
  }
}
