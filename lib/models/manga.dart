import 'dart:convert';

class Manga {
  final String id;
  String title;
  String author;
  String artist;
  String coverImage;
  String url;
  int currentChapter;
  int totalChapters;
  String status;
  List<String> tags;
  String notes;
  int rating;
  bool isBookmarked;
  DateTime lastUpdated;
  DateTime? startDate;
  DateTime? finishDate;
  List<Map<String, dynamic>> history;
  String? sourceUrl;
  String? description;
  int? year;
  String? publisher;
  String? language;
  bool isCompleted;

  Manga({
    required this.id,
    required this.title,
    this.author = '',
    this.artist = '',
    this.coverImage = '',
    this.url = '',
    this.currentChapter = 0,
    this.totalChapters = 0,
    this.status = 'Reading',
    this.tags = const [],
    this.notes = '',
    this.rating = 0,
    this.isBookmarked = false,
    required this.lastUpdated,
    this.startDate,
    this.finishDate,
    this.history = const [],
    this.sourceUrl,
    this.description,
    this.year,
    this.publisher,
    this.language,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'artist': artist,
      'coverImage': coverImage,
      'url': url,
      'currentChapter': currentChapter,
      'totalChapters': totalChapters,
      'status': status,
      'tags': tags,
      'notes': notes,
      'rating': rating,
      'isBookmarked': isBookmarked,
      'lastUpdated': lastUpdated.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'finishDate': finishDate?.toIso8601String(),
      'history': history,
      'sourceUrl': sourceUrl,
      'description': description,
      'year': year,
      'publisher': publisher,
      'language': language,
      'isCompleted': isCompleted,
    };
  }

  factory Manga.fromMap(Map<String, dynamic> map) {
    return Manga(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      artist: map['artist'] ?? '',
      coverImage: map['coverImage'] ?? '',
      url: map['url'] ?? '',
      currentChapter: map['currentChapter'] ?? 0,
      totalChapters: map['totalChapters'] ?? 0,
      status: map['status'] ?? 'Reading',
      tags: List<String>.from(map['tags'] ?? []),
      notes: map['notes'] ?? '',
      rating: map['rating'] ?? 0,
      isBookmarked: map['isBookmarked'] ?? false,
      lastUpdated:
          DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'])
          : null,
      finishDate: map['finishDate'] != null
          ? DateTime.tryParse(map['finishDate'])
          : null,
      history: List<Map<String, dynamic>>.from(map['history'] ?? []),
      sourceUrl: map['sourceUrl'],
      description: map['description'],
      year: map['year'],
      publisher: map['publisher'],
      language: map['language'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Manga.fromJson(String source) => Manga.fromMap(json.decode(source));

  Manga copyWith({
    String? id,
    String? title,
    String? author,
    String? artist,
    String? coverImage,
    String? url,
    int? currentChapter,
    int? totalChapters,
    String? status,
    List<String>? tags,
    String? notes,
    int? rating,
    bool? isBookmarked,
    DateTime? lastUpdated,
    DateTime? startDate,
    DateTime? finishDate,
    List<Map<String, dynamic>>? history,
    String? sourceUrl,
    String? description,
    int? year,
    String? publisher,
    String? language,
    bool? isCompleted,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      artist: artist ?? this.artist,
      coverImage: coverImage ?? this.coverImage,
      url: url ?? this.url,
      currentChapter: currentChapter ?? this.currentChapter,
      totalChapters: totalChapters ?? this.totalChapters,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      history: history ?? this.history,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      description: description ?? this.description,
      year: year ?? this.year,
      publisher: publisher ?? this.publisher,
      language: language ?? this.language,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Helper methods
  double get progressPercentage {
    if (totalChapters <= 0) return 0.0;
    return (currentChapter / totalChapters) * 100;
  }

  bool get isOngoing => status == 'Reading';

  bool get isFinished => status == 'Completed';

  bool get isOnHold => status == 'On-hold';

  bool get isDropped => status == 'Dropped';

  bool get isPlanned => status == 'Plan to Read';

  String get progressText {
    if (totalChapters > 0) {
      return '$currentChapter/$totalChapters';
    }
    return currentChapter > 0 ? '$currentChapter' : '0';
  }

  int get chaptersRemaining {
    if (totalChapters <= 0) return -1;
    return totalChapters - currentChapter;
  }

  String get ratingDisplay {
    if (rating <= 0) return 'Not rated';
    return '★' * rating + '☆' * (5 - rating);
  }

  List<Map<String, dynamic>> get recentHistory {
    final sorted = List<Map<String, dynamic>>.from(history);
    sorted.sort(
      (a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])),
    );
    return sorted.take(5).toList();
  }

  int get totalChaptersRead {
    return history.fold(
      0,
      (sum, entry) => sum + (entry['chapters_read'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Manga && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Manga(id: $id, title: $title, status: $status, currentChapter: $currentChapter)';
  }
}
