import 'package:hayd_kalender/core/db/app_database.dart';
import 'package:hayd_kalender/domain/repositories/episode_repository.dart';

class EpisodeService {
  final EpisodeRepository repo;

  EpisodeService(this.repo);

  Stream<List<Episode>> watchEpisodes() => repo.watchEpisodes();

  Future<void> startBleeding(DateTime startTime) =>
      repo.startEpisode(startTime);

  Future<void> stopBleeding(DateTime endTime) =>
      repo.stopActiveEpisode(endTime);
}