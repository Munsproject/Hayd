import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

class Episodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get start => dateTime()();
  DateTimeColumn get end => dateTime().nullable()();
}

@DriftDatabase(tables: [Episodes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertEpisode(EpisodesCompanion entry) =>
      into(episodes).insert(entry);

  Future<List<Episode>> getAllEpisodes() => select(episodes).get();

  Stream<List<Episode>> watchAllEpisodes() => select(episodes).watch();

  Future<void> updateEpisode(Episode row) => update(episodes).replace(row);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hayd.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
