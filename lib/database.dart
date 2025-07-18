import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get coverImage => text().nullable()();
  IntColumn get chaptersRead => integer().withDefault(const Constant(0))();
  IntColumn get totalChapters => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('reading'))();
  TextColumn get mood => text().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get lastRead => dateTime().nullable()();
  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique().withLength(min: 1, max: 50)();
  IntColumn get color => integer().nullable()();
}

class BookmarkTags extends Table {
  IntColumn get bookmarkId => integer().references(Bookmarks, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {bookmarkId, tagId};
}

@DriftDatabase(tables: [Bookmarks, Tags, BookmarkTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}