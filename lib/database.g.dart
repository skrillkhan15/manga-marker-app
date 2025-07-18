// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverImageMeta = const VerificationMeta(
    'coverImage',
  );
  @override
  late final GeneratedColumn<String> coverImage = GeneratedColumn<String>(
    'cover_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chaptersReadMeta = const VerificationMeta(
    'chaptersRead',
  );
  @override
  late final GeneratedColumn<int> chaptersRead = GeneratedColumn<int>(
    'chapters_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalChaptersMeta = const VerificationMeta(
    'totalChapters',
  );
  @override
  late final GeneratedColumn<int> totalChapters = GeneratedColumn<int>(
    'total_chapters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('reading'),
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReadMeta = const VerificationMeta(
    'lastRead',
  );
  @override
  late final GeneratedColumn<DateTime> lastRead = GeneratedColumn<DateTime>(
    'last_read',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    coverImage,
    chaptersRead,
    totalChapters,
    status,
    mood,
    rating,
    notes,
    lastRead,
    dateAdded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_image')) {
      context.handle(
        _coverImageMeta,
        coverImage.isAcceptableOrUnknown(data['cover_image']!, _coverImageMeta),
      );
    }
    if (data.containsKey('chapters_read')) {
      context.handle(
        _chaptersReadMeta,
        chaptersRead.isAcceptableOrUnknown(
          data['chapters_read']!,
          _chaptersReadMeta,
        ),
      );
    }
    if (data.containsKey('total_chapters')) {
      context.handle(
        _totalChaptersMeta,
        totalChapters.isAcceptableOrUnknown(
          data['total_chapters']!,
          _totalChaptersMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('last_read')) {
      context.handle(
        _lastReadMeta,
        lastRead.isAcceptableOrUnknown(data['last_read']!, _lastReadMeta),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      coverImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image'],
      ),
      chaptersRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapters_read'],
      )!,
      totalChapters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_chapters'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      lastRead: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read'],
      ),
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final String title;
  final String? coverImage;
  final int chaptersRead;
  final int totalChapters;
  final String status;
  final String? mood;
  final int? rating;
  final String? notes;
  final DateTime? lastRead;
  final DateTime dateAdded;
  const Bookmark({
    required this.id,
    required this.title,
    this.coverImage,
    required this.chaptersRead,
    required this.totalChapters,
    required this.status,
    this.mood,
    this.rating,
    this.notes,
    this.lastRead,
    required this.dateAdded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || coverImage != null) {
      map['cover_image'] = Variable<String>(coverImage);
    }
    map['chapters_read'] = Variable<int>(chaptersRead);
    map['total_chapters'] = Variable<int>(totalChapters);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || lastRead != null) {
      map['last_read'] = Variable<DateTime>(lastRead);
    }
    map['date_added'] = Variable<DateTime>(dateAdded);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      title: Value(title),
      coverImage: coverImage == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImage),
      chaptersRead: Value(chaptersRead),
      totalChapters: Value(totalChapters),
      status: Value(status),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      lastRead: lastRead == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRead),
      dateAdded: Value(dateAdded),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      coverImage: serializer.fromJson<String?>(json['coverImage']),
      chaptersRead: serializer.fromJson<int>(json['chaptersRead']),
      totalChapters: serializer.fromJson<int>(json['totalChapters']),
      status: serializer.fromJson<String>(json['status']),
      mood: serializer.fromJson<String?>(json['mood']),
      rating: serializer.fromJson<int?>(json['rating']),
      notes: serializer.fromJson<String?>(json['notes']),
      lastRead: serializer.fromJson<DateTime?>(json['lastRead']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'coverImage': serializer.toJson<String?>(coverImage),
      'chaptersRead': serializer.toJson<int>(chaptersRead),
      'totalChapters': serializer.toJson<int>(totalChapters),
      'status': serializer.toJson<String>(status),
      'mood': serializer.toJson<String?>(mood),
      'rating': serializer.toJson<int?>(rating),
      'notes': serializer.toJson<String?>(notes),
      'lastRead': serializer.toJson<DateTime?>(lastRead),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
    };
  }

  Bookmark copyWith({
    int? id,
    String? title,
    Value<String?> coverImage = const Value.absent(),
    int? chaptersRead,
    int? totalChapters,
    String? status,
    Value<String?> mood = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> lastRead = const Value.absent(),
    DateTime? dateAdded,
  }) => Bookmark(
    id: id ?? this.id,
    title: title ?? this.title,
    coverImage: coverImage.present ? coverImage.value : this.coverImage,
    chaptersRead: chaptersRead ?? this.chaptersRead,
    totalChapters: totalChapters ?? this.totalChapters,
    status: status ?? this.status,
    mood: mood.present ? mood.value : this.mood,
    rating: rating.present ? rating.value : this.rating,
    notes: notes.present ? notes.value : this.notes,
    lastRead: lastRead.present ? lastRead.value : this.lastRead,
    dateAdded: dateAdded ?? this.dateAdded,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      coverImage: data.coverImage.present
          ? data.coverImage.value
          : this.coverImage,
      chaptersRead: data.chaptersRead.present
          ? data.chaptersRead.value
          : this.chaptersRead,
      totalChapters: data.totalChapters.present
          ? data.totalChapters.value
          : this.totalChapters,
      status: data.status.present ? data.status.value : this.status,
      mood: data.mood.present ? data.mood.value : this.mood,
      rating: data.rating.present ? data.rating.value : this.rating,
      notes: data.notes.present ? data.notes.value : this.notes,
      lastRead: data.lastRead.present ? data.lastRead.value : this.lastRead,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverImage: $coverImage, ')
          ..write('chaptersRead: $chaptersRead, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('status: $status, ')
          ..write('mood: $mood, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('lastRead: $lastRead, ')
          ..write('dateAdded: $dateAdded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    coverImage,
    chaptersRead,
    totalChapters,
    status,
    mood,
    rating,
    notes,
    lastRead,
    dateAdded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.title == this.title &&
          other.coverImage == this.coverImage &&
          other.chaptersRead == this.chaptersRead &&
          other.totalChapters == this.totalChapters &&
          other.status == this.status &&
          other.mood == this.mood &&
          other.rating == this.rating &&
          other.notes == this.notes &&
          other.lastRead == this.lastRead &&
          other.dateAdded == this.dateAdded);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> coverImage;
  final Value<int> chaptersRead;
  final Value<int> totalChapters;
  final Value<String> status;
  final Value<String?> mood;
  final Value<int?> rating;
  final Value<String?> notes;
  final Value<DateTime?> lastRead;
  final Value<DateTime> dateAdded;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.coverImage = const Value.absent(),
    this.chaptersRead = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.status = const Value.absent(),
    this.mood = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.lastRead = const Value.absent(),
    this.dateAdded = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.coverImage = const Value.absent(),
    this.chaptersRead = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.status = const Value.absent(),
    this.mood = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.lastRead = const Value.absent(),
    this.dateAdded = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? coverImage,
    Expression<int>? chaptersRead,
    Expression<int>? totalChapters,
    Expression<String>? status,
    Expression<String>? mood,
    Expression<int>? rating,
    Expression<String>? notes,
    Expression<DateTime>? lastRead,
    Expression<DateTime>? dateAdded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (coverImage != null) 'cover_image': coverImage,
      if (chaptersRead != null) 'chapters_read': chaptersRead,
      if (totalChapters != null) 'total_chapters': totalChapters,
      if (status != null) 'status': status,
      if (mood != null) 'mood': mood,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
      if (lastRead != null) 'last_read': lastRead,
      if (dateAdded != null) 'date_added': dateAdded,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? coverImage,
    Value<int>? chaptersRead,
    Value<int>? totalChapters,
    Value<String>? status,
    Value<String?>? mood,
    Value<int?>? rating,
    Value<String?>? notes,
    Value<DateTime?>? lastRead,
    Value<DateTime>? dateAdded,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      chaptersRead: chaptersRead ?? this.chaptersRead,
      totalChapters: totalChapters ?? this.totalChapters,
      status: status ?? this.status,
      mood: mood ?? this.mood,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      lastRead: lastRead ?? this.lastRead,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverImage.present) {
      map['cover_image'] = Variable<String>(coverImage.value);
    }
    if (chaptersRead.present) {
      map['chapters_read'] = Variable<int>(chaptersRead.value);
    }
    if (totalChapters.present) {
      map['total_chapters'] = Variable<int>(totalChapters.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (lastRead.present) {
      map['last_read'] = Variable<DateTime>(lastRead.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverImage: $coverImage, ')
          ..write('chaptersRead: $chaptersRead, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('status: $status, ')
          ..write('mood: $mood, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('lastRead: $lastRead, ')
          ..write('dateAdded: $dateAdded')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final int? color;
  const Tag({required this.id, required this.name, this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int?>(color),
    };
  }

  Tag copyWith({
    int? id,
    String? name,
    Value<int?> color = const Value.absent(),
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> color;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? color,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $BookmarkTagsTable extends BookmarkTags
    with TableInfo<$BookmarkTagsTable, BookmarkTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookmarkIdMeta = const VerificationMeta(
    'bookmarkId',
  );
  @override
  late final GeneratedColumn<int> bookmarkId = GeneratedColumn<int>(
    'bookmark_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bookmarks (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [bookmarkId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmark_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bookmark_id')) {
      context.handle(
        _bookmarkIdMeta,
        bookmarkId.isAcceptableOrUnknown(data['bookmark_id']!, _bookmarkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookmarkIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookmarkId, tagId};
  @override
  BookmarkTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkTag(
      bookmarkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bookmark_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $BookmarkTagsTable createAlias(String alias) {
    return $BookmarkTagsTable(attachedDatabase, alias);
  }
}

class BookmarkTag extends DataClass implements Insertable<BookmarkTag> {
  final int bookmarkId;
  final int tagId;
  const BookmarkTag({required this.bookmarkId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bookmark_id'] = Variable<int>(bookmarkId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  BookmarkTagsCompanion toCompanion(bool nullToAbsent) {
    return BookmarkTagsCompanion(
      bookmarkId: Value(bookmarkId),
      tagId: Value(tagId),
    );
  }

  factory BookmarkTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkTag(
      bookmarkId: serializer.fromJson<int>(json['bookmarkId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookmarkId': serializer.toJson<int>(bookmarkId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  BookmarkTag copyWith({int? bookmarkId, int? tagId}) => BookmarkTag(
    bookmarkId: bookmarkId ?? this.bookmarkId,
    tagId: tagId ?? this.tagId,
  );
  BookmarkTag copyWithCompanion(BookmarkTagsCompanion data) {
    return BookmarkTag(
      bookmarkId: data.bookmarkId.present
          ? data.bookmarkId.value
          : this.bookmarkId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkTag(')
          ..write('bookmarkId: $bookmarkId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookmarkId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkTag &&
          other.bookmarkId == this.bookmarkId &&
          other.tagId == this.tagId);
}

class BookmarkTagsCompanion extends UpdateCompanion<BookmarkTag> {
  final Value<int> bookmarkId;
  final Value<int> tagId;
  final Value<int> rowid;
  const BookmarkTagsCompanion({
    this.bookmarkId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarkTagsCompanion.insert({
    required int bookmarkId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : bookmarkId = Value(bookmarkId),
       tagId = Value(tagId);
  static Insertable<BookmarkTag> custom({
    Expression<int>? bookmarkId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookmarkId != null) 'bookmark_id': bookmarkId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarkTagsCompanion copyWith({
    Value<int>? bookmarkId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return BookmarkTagsCompanion(
      bookmarkId: bookmarkId ?? this.bookmarkId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookmarkId.present) {
      map['bookmark_id'] = Variable<int>(bookmarkId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkTagsCompanion(')
          ..write('bookmarkId: $bookmarkId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $BookmarkTagsTable bookmarkTags = $BookmarkTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookmarks,
    tags,
    bookmarkTags,
  ];
}

typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> coverImage,
      Value<int> chaptersRead,
      Value<int> totalChapters,
      Value<String> status,
      Value<String?> mood,
      Value<int?> rating,
      Value<String?> notes,
      Value<DateTime?> lastRead,
      Value<DateTime> dateAdded,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> coverImage,
      Value<int> chaptersRead,
      Value<int> totalChapters,
      Value<String> status,
      Value<String?> mood,
      Value<int?> rating,
      Value<String?> notes,
      Value<DateTime?> lastRead,
      Value<DateTime> dateAdded,
    });

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookmarkTagsTable, List<BookmarkTag>>
  _bookmarkTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarkTags,
    aliasName: $_aliasNameGenerator(
      db.bookmarks.id,
      db.bookmarkTags.bookmarkId,
    ),
  );

  $$BookmarkTagsTableProcessedTableManager get bookmarkTagsRefs {
    final manager = $$BookmarkTagsTableTableManager(
      $_db,
      $_db.bookmarkTags,
    ).filter((f) => f.bookmarkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarkTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImage => $composableBuilder(
    column: $table.coverImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chaptersRead => $composableBuilder(
    column: $table.chaptersRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalChapters => $composableBuilder(
    column: $table.totalChapters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookmarkTagsRefs(
    Expression<bool> Function($$BookmarkTagsTableFilterComposer f) f,
  ) {
    final $$BookmarkTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarkTags,
      getReferencedColumn: (t) => t.bookmarkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkTagsTableFilterComposer(
            $db: $db,
            $table: $db.bookmarkTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImage => $composableBuilder(
    column: $table.coverImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chaptersRead => $composableBuilder(
    column: $table.chaptersRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalChapters => $composableBuilder(
    column: $table.totalChapters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get coverImage => $composableBuilder(
    column: $table.coverImage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chaptersRead => $composableBuilder(
    column: $table.chaptersRead,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalChapters => $composableBuilder(
    column: $table.totalChapters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRead =>
      $composableBuilder(column: $table.lastRead, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  Expression<T> bookmarkTagsRefs<T extends Object>(
    Expression<T> Function($$BookmarkTagsTableAnnotationComposer a) f,
  ) {
    final $$BookmarkTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarkTags,
      getReferencedColumn: (t) => t.bookmarkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarkTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, $$BookmarksTableReferences),
          Bookmark,
          PrefetchHooks Function({bool bookmarkTagsRefs})
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> coverImage = const Value.absent(),
                Value<int> chaptersRead = const Value.absent(),
                Value<int> totalChapters = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> lastRead = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                title: title,
                coverImage: coverImage,
                chaptersRead: chaptersRead,
                totalChapters: totalChapters,
                status: status,
                mood: mood,
                rating: rating,
                notes: notes,
                lastRead: lastRead,
                dateAdded: dateAdded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> coverImage = const Value.absent(),
                Value<int> chaptersRead = const Value.absent(),
                Value<int> totalChapters = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> lastRead = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
              }) => BookmarksCompanion.insert(
                id: id,
                title: title,
                coverImage: coverImage,
                chaptersRead: chaptersRead,
                totalChapters: totalChapters,
                status: status,
                mood: mood,
                rating: rating,
                notes: notes,
                lastRead: lastRead,
                dateAdded: dateAdded,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookmarkTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookmarkTagsRefs) db.bookmarkTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookmarkTagsRefs)
                    await $_getPrefetchedData<
                      Bookmark,
                      $BookmarksTable,
                      BookmarkTag
                    >(
                      currentTable: table,
                      referencedTable: $$BookmarksTableReferences
                          ._bookmarkTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BookmarksTableReferences(
                            db,
                            table,
                            p0,
                          ).bookmarkTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookmarkId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, $$BookmarksTableReferences),
      Bookmark,
      PrefetchHooks Function({bool bookmarkTagsRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> color,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> color,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookmarkTagsTable, List<BookmarkTag>>
  _bookmarkTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarkTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.bookmarkTags.tagId),
  );

  $$BookmarkTagsTableProcessedTableManager get bookmarkTagsRefs {
    final manager = $$BookmarkTagsTableTableManager(
      $_db,
      $_db.bookmarkTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarkTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookmarkTagsRefs(
    Expression<bool> Function($$BookmarkTagsTableFilterComposer f) f,
  ) {
    final $$BookmarkTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarkTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkTagsTableFilterComposer(
            $db: $db,
            $table: $db.bookmarkTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> bookmarkTagsRefs<T extends Object>(
    Expression<T> Function($$BookmarkTagsTableAnnotationComposer a) f,
  ) {
    final $$BookmarkTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarkTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarkTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarkTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool bookmarkTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> color = const Value.absent(),
              }) => TagsCompanion(id: id, name: name, color: color),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> color = const Value.absent(),
              }) => TagsCompanion.insert(id: id, name: name, color: color),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({bookmarkTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookmarkTagsRefs) db.bookmarkTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookmarkTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, BookmarkTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._bookmarkTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).bookmarkTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool bookmarkTagsRefs})
    >;
typedef $$BookmarkTagsTableCreateCompanionBuilder =
    BookmarkTagsCompanion Function({
      required int bookmarkId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$BookmarkTagsTableUpdateCompanionBuilder =
    BookmarkTagsCompanion Function({
      Value<int> bookmarkId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$BookmarkTagsTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarkTagsTable, BookmarkTag> {
  $$BookmarkTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BookmarksTable _bookmarkIdTable(_$AppDatabase db) =>
      db.bookmarks.createAlias(
        $_aliasNameGenerator(db.bookmarkTags.bookmarkId, db.bookmarks.id),
      );

  $$BookmarksTableProcessedTableManager get bookmarkId {
    final $_column = $_itemColumn<int>('bookmark_id')!;

    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookmarkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags.createAlias(
    $_aliasNameGenerator(db.bookmarkTags.tagId, db.tags.id),
  );

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarkTagsTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarkTagsTable> {
  $$BookmarkTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BookmarksTableFilterComposer get bookmarkId {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookmarkId,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarkTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarkTagsTable> {
  $$BookmarkTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BookmarksTableOrderingComposer get bookmarkId {
    final $$BookmarksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookmarkId,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableOrderingComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarkTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarkTagsTable> {
  $$BookmarkTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BookmarksTableAnnotationComposer get bookmarkId {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookmarkId,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarkTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarkTagsTable,
          BookmarkTag,
          $$BookmarkTagsTableFilterComposer,
          $$BookmarkTagsTableOrderingComposer,
          $$BookmarkTagsTableAnnotationComposer,
          $$BookmarkTagsTableCreateCompanionBuilder,
          $$BookmarkTagsTableUpdateCompanionBuilder,
          (BookmarkTag, $$BookmarkTagsTableReferences),
          BookmarkTag,
          PrefetchHooks Function({bool bookmarkId, bool tagId})
        > {
  $$BookmarkTagsTableTableManager(_$AppDatabase db, $BookmarkTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookmarkId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarkTagsCompanion(
                bookmarkId: bookmarkId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int bookmarkId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => BookmarkTagsCompanion.insert(
                bookmarkId: bookmarkId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookmarkTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookmarkId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookmarkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookmarkId,
                                referencedTable: $$BookmarkTagsTableReferences
                                    ._bookmarkIdTable(db),
                                referencedColumn: $$BookmarkTagsTableReferences
                                    ._bookmarkIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$BookmarkTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$BookmarkTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookmarkTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarkTagsTable,
      BookmarkTag,
      $$BookmarkTagsTableFilterComposer,
      $$BookmarkTagsTableOrderingComposer,
      $$BookmarkTagsTableAnnotationComposer,
      $$BookmarkTagsTableCreateCompanionBuilder,
      $$BookmarkTagsTableUpdateCompanionBuilder,
      (BookmarkTag, $$BookmarkTagsTableReferences),
      BookmarkTag,
      PrefetchHooks Function({bool bookmarkId, bool tagId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$BookmarkTagsTableTableManager get bookmarkTags =>
      $$BookmarkTagsTableTableManager(_db, _db.bookmarkTags);
}
