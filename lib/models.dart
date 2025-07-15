import 'dart:convert';

// ------------------ BOOKMARK ------------------
class Bookmark {
  String id;
  String title;
  String url;
  String coverImage;
  int currentChapter;
  int totalChapters;
  String status;
  List<String> tags;
  String notes;
  int rating;
  String mood;
  String collectionId;
  String? parentId; // New field for nested collections
  DateTime lastUpdated;
  List<Map<String, dynamic>> history;

  Bookmark({
    required this.id,
    required this.title,
    required this.url,
    this.coverImage = '',
    this.currentChapter = 0,
    this.totalChapters = 0,
    this.status = 'Reading',
    this.tags = const [],
    this.notes = '',
    this.rating = 0,
    this.mood = '',
    this.collectionId = '',
    this.parentId, // Initialize new field
    required this.lastUpdated,
    this.history = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'coverImage': coverImage,
      'currentChapter': currentChapter,
      'totalChapters': totalChapters,
      'status': status,
      'tags': tags,
      'notes': notes,
      'rating': rating,
      'mood': mood,
      'collectionId': collectionId,
      'parentId': parentId, // Include in map
      'lastUpdated': lastUpdated.toIso8601String(),
      'history': history,
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      coverImage: map['coverImage'] ?? '',
      currentChapter: map['currentChapter'] ?? 0,
      totalChapters: map['totalChapters'] ?? 0,
      status: map['status'] ?? 'Reading',
      tags: List<String>.from(map['tags'] ?? []),
      notes: map['notes'] ?? '',
      rating: map['rating'] ?? 0,
      mood: map['mood'] ?? '',
      collectionId: map['collectionId'] ?? '',
      parentId: map['parentId'], // Retrieve from map
      lastUpdated:
          DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
      history: List<Map<String, dynamic>>.from(map['history'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());
  factory Bookmark.fromJson(String source) =>
      Bookmark.fromMap(json.decode(source));
}

// ------------------ TAG ------------------
class Tag {
  String id;
  String name;
  int? color;

  Tag({required this.id, required this.name, this.color});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'color': color};

  factory Tag.fromMap(Map<String, dynamic> map) =>
      Tag(id: map['id'] ?? '', name: map['name'] ?? '', color: map['color']);

  String toJson() => json.encode(toMap());
  factory Tag.fromJson(String source) => Tag.fromMap(json.decode(source));
}

// ------------------ READING STATUS ------------------
class ReadingStatus {
  String id;
  String name;

  ReadingStatus({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory ReadingStatus.fromMap(Map<String, dynamic> map) =>
      ReadingStatus(id: map['id'] ?? '', name: map['name'] ?? '');

  String toJson() => json.encode(toMap());
  factory ReadingStatus.fromJson(String source) =>
      ReadingStatus.fromMap(json.decode(source));
}

// ------------------ READING GOAL ------------------
class ReadingGoal {
  String id;
  String title;
  int targetValue;
  int currentValue;
  String type;
  DateTime startDate;
  DateTime endDate;

  ReadingGoal({
    required this.id,
    required this.title,
    required this.targetValue,
    this.currentValue = 0,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'targetValue': targetValue,
    'currentValue': currentValue,
    'type': type,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  };

  factory ReadingGoal.fromMap(Map<String, dynamic> map) => ReadingGoal(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    targetValue: map['targetValue'] ?? 0,
    currentValue: map['currentValue'] ?? 0,
    type: map['type'] ?? '',
    startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
    endDate: DateTime.tryParse(map['endDate'] ?? '') ?? DateTime.now(),
  );

  String toJson() => json.encode(toMap());
  factory ReadingGoal.fromJson(String source) =>
      ReadingGoal.fromMap(json.decode(source));
}

// ------------------ VIEW PRESET ------------------
class ViewPreset {
  String name;
  bool isGridView;
  BookmarkFilter filter;

  ViewPreset({
    required this.name,
    required this.isGridView,
    required this.filter,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'isGridView': isGridView,
    'filter': filter.toMap(),
  };

  factory ViewPreset.fromMap(Map<String, dynamic> map) => ViewPreset(
    name: map['name'] ?? '',
    isGridView: map['isGridView'] ?? true,
    filter: BookmarkFilter.fromMap(map['filter']),
  );

  String toJson() => json.encode(toMap());
  factory ViewPreset.fromJson(String source) =>
      ViewPreset.fromMap(json.decode(source));
}

// ------------------ BOOKMARK FILTER ------------------
class BookmarkFilter {
  String? status;
  String? tag;
  String? collection;
  String? notesKeyword; // New field for searching notes

  BookmarkFilter({this.status, this.tag, this.collection, this.notesKeyword});

  bool get isActive => status != null || tag != null || collection != null || notesKeyword != null;

  BookmarkFilter copyWith({String? status, String? tag, String? collection, String? notesKeyword}) {
    return BookmarkFilter(
      status: status ?? this.status,
      tag: tag ?? this.tag,
      collection: collection ?? this.collection,
      notesKeyword: notesKeyword ?? this.notesKeyword,
    );
  }

  Map<String, dynamic> toMap() => {
    'status': status,
    'tag': tag,
    'collection': collection,
    'notesKeyword': notesKeyword,
  };

  factory BookmarkFilter.fromMap(Map<String, dynamic> map) => BookmarkFilter(
    status: map['status'],
    tag: map['tag'],
    collection: map['collection'],
    notesKeyword: map['notesKeyword'],
  );

  @override
  String toString() {
    final filters = <String>[];
    if (status != null) filters.add('Status: $status');
    if (tag != null) filters.add('Tag: $tag');
    if (collection != null) filters.add('Collection: $collection');
    return filters.isEmpty ? 'No Filters' : filters.join(', ');
  }
}

// ------------------ ACTIVITY LOG ENTRY ------------------
class ActivityLogEntry {
  String id;
  String type;
  String description;
  DateTime timestamp;

  ActivityLogEntry({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ActivityLogEntry.fromMap(Map<String, dynamic> map) =>
      ActivityLogEntry(
        id: map['id'] ?? '',
        type: map['type'] ?? '',
        description: map['description'] ?? '',
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      );

  String toJson() => json.encode(toMap());
  factory ActivityLogEntry.fromJson(String source) =>
      ActivityLogEntry.fromMap(json.decode(source));
}
