import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/manga.dart';
import '../utils/constants.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../providers/settings_provider.dart';

class MangaProvider extends ChangeNotifier {
  List<Manga> _mangaList = [];
  List<Manga> _filteredMangaList = [];
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _sortBy = 'recently_updated';
  bool _isGridView = true;
  bool _isLoading = false;
  String _profileId;

  List<Manga> get mangaList => _mangaList;
  List<Manga> get filteredMangaList => _filteredMangaList;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get sortBy => _sortBy;
  bool get isGridView => _isGridView;
  bool get isLoading => _isLoading;

  MangaProvider(this._profileId) {
    _loadManga();
  }

  Future<void> setProfile(String profileId) async {
    if (_profileId != profileId) {
      _profileId = profileId;
      await _loadManga();
    }
  }

  Future<void> _loadManga() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? mangaJson = prefs.getString('manga_list_' + _profileId);

      // If missing or corrupted, try to restore from local file
      if (mangaJson == null || mangaJson.isEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        final mainFile = File('${dir.path}/manga_data_${_profileId}.json');
        if (await mainFile.exists()) {
          mangaJson = await mainFile.readAsString();
          debugPrint('Restored manga data from local file backup.');
          // Optionally, show user feedback (requires context)
        }
      }

      if (mangaJson != null && mangaJson.isNotEmpty) {
        final List<dynamic> mangaData = json.decode(mangaJson);
        _mangaList = mangaData.map((data) => Manga.fromMap(data)).toList();
      } else {
        _mangaList = [];
      }

      _applyFilters();
    } catch (e) {
      debugPrint('Error loading manga: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveManga() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mangaJson = json.encode(
        _mangaList.map((manga) => manga.toMap()).toList(),
      );
      // Save to SharedPreferences as before
      await prefs.setString('manga_list_' + _profileId, mangaJson);
      // Also save to a local file atomically for crash resilience
      final dir = await getApplicationDocumentsDirectory();
      final mainFile = File('${dir.path}/manga_data_${_profileId}.json');
      final tempFile = File('${dir.path}/manga_data_${_profileId}.json.tmp');
      await tempFile.writeAsString(mangaJson, flush: true);
      if (await tempFile.exists()) {
        await tempFile.rename(mainFile.path);
      }
      // Auto-backup logic
      final settingsProvider = SettingsProvider(_profileId);
      await settingsProvider.loadSettings();
      final interval = settingsProvider.autoBackupInterval;
      if (interval != 'off') {
        final lastBackup = prefs.getInt('last_auto_backup') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        final shouldBackup =
            (interval == 'daily' && now - lastBackup > 86400000) ||
            (interval == 'weekly' && now - lastBackup > 604800000);
        if (shouldBackup) {
          final backupFile = File(
            '${dir.path}/mangamarks_autobackup_${now}.json',
          );
          await backupFile.writeAsString(mangaJson, flush: true);
          await prefs.setInt('last_auto_backup', now);
        }
      }
    } catch (e) {
      debugPrint('Error saving manga: $e');
    }
  }

  Future<void> addManga(Manga manga) async {
    _mangaList.add(manga);
    await _saveManga();
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateManga(Manga manga) async {
    final index = _mangaList.indexWhere((m) => m.id == manga.id);
    if (index != -1) {
      _mangaList[index] = manga;
      await _saveManga();
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> deleteManga(String id) async {
    _mangaList.removeWhere((manga) => manga.id == id);
    await _saveManga();
    _applyFilters();
    notifyListeners();
  }

  Future<void> bulkDeleteManga(List<String> ids) async {
    _mangaList.removeWhere((manga) => ids.contains(manga.id));
    await _saveManga();
    _applyFilters();
    notifyListeners();
  }

  // Bulk actions
  Future<void> deleteMangaBulk(List<String> ids) async {
    _mangaList.removeWhere((m) => ids.contains(m.id));
    await _saveManga();
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateMangaStatusBulk(List<String> ids, String status) async {
    for (final manga in _mangaList) {
      if (ids.contains(manga.id)) {
        manga.status = status;
      }
    }
    await _saveManga();
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateMangaTagsBulk(List<String> ids, List<String> tags) async {
    for (final manga in _mangaList) {
      if (ids.contains(manga.id)) {
        manga.tags = List.from(tags);
      }
    }
    await _saveManga();
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateChapter(String id, int newChapter) async {
    final index = _mangaList.indexWhere((m) => m.id == id);
    if (index != -1) {
      final manga = _mangaList[index];
      final oldChapter = manga.currentChapter;

      manga.currentChapter = newChapter;
      manga.lastUpdated = DateTime.now();

      // Add to history
      if (newChapter > oldChapter) {
        manga.history.add({
          'date': DateTime.now().toIso8601String(),
          'chapters_read': newChapter - oldChapter,
          'from_chapter': oldChapter,
          'to_chapter': newChapter,
        });
      }

      await _saveManga();
      _applyFilters();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
    notifyListeners();
  }

  void setGridView(bool isGrid) {
    _isGridView = isGrid;
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMangaList = List.from(_mangaList);

    // Apply status filter
    if (_selectedStatus != 'All') {
      _filteredMangaList = _filteredMangaList
          .where((manga) => manga.status == _selectedStatus)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredMangaList = _filteredMangaList.where((manga) {
        final query = _searchQuery.toLowerCase();
        return manga.title.toLowerCase().contains(query) ||
            manga.author.toLowerCase().contains(query) ||
            manga.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'title':
        _filteredMangaList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'rating':
        _filteredMangaList.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'progress':
        _filteredMangaList.sort(
          (a, b) => b.currentChapter.compareTo(a.currentChapter),
        );
        break;
      case 'recently_updated':
      default:
        _filteredMangaList.sort(
          (a, b) => b.lastUpdated.compareTo(a.lastUpdated),
        );
        break;
    }
  }

  // Statistics methods
  int get totalManga => _mangaList.length;

  int get readingCount => _mangaList.where((m) => m.status == 'Reading').length;

  int get completedCount =>
      _mangaList.where((m) => m.status == 'Completed').length;

  int get totalChaptersRead =>
      _mangaList.fold(0, (sum, manga) => sum + manga.currentChapter);

  double get averageRating {
    final ratedManga = _mangaList.where((m) => m.rating > 0).toList();
    if (ratedManga.isEmpty) return 0.0;
    return ratedManga.map((m) => m.rating).reduce((a, b) => a + b) /
        ratedManga.length;
  }

  Map<String, int> get statusDistribution {
    final distribution = <String, int>{};
    for (final status in AppConstants.mangaStatuses) {
      distribution[status] = _mangaList.where((m) => m.status == status).length;
    }
    return distribution;
  }

  Map<String, int> get tagUsage {
    final usage = <String, int>{};
    for (final manga in _mangaList) {
      for (final tag in manga.tags) {
        usage[tag] = (usage[tag] ?? 0) + 1;
      }
    }
    return usage;
  }

  List<Manga> get bookmarkedManga =>
      _mangaList.where((m) => m.isBookmarked).toList();

  List<Manga> get recentlyUpdatedManga {
    final sorted = List<Manga>.from(_mangaList);
    sorted.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return sorted.take(10).toList();
  }

  List<String> get allTags {
    final tagSet = <String>{};
    for (final manga in _mangaList) {
      tagSet.addAll(manga.tags);
    }
    return tagSet.toList()..sort();
  }

  // Export/Import methods
  Future<Map<String, dynamic>> exportData() async {
    return {
      'metadata': {
        'exportDate': DateTime.now().toIso8601String(),
        'version': AppConstants.appVersion,
        'totalManga': _mangaList.length,
      },
      'manga': _mangaList.map((m) => m.toMap()).toList(),
      'statistics': {
        'totalManga': totalManga,
        'readingCount': readingCount,
        'completedCount': completedCount,
        'totalChaptersRead': totalChaptersRead,
        'averageRating': averageRating,
        'statusDistribution': statusDistribution,
        'tagUsage': tagUsage,
      },
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      final mangaData = data['manga'] as List<dynamic>;
      _mangaList = mangaData.map((data) => Manga.fromMap(data)).toList();
      await _saveManga();
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error importing data: $e');
      rethrow;
    }
  }

  // Tag management methods
  Future<void> createTag(String tagName) async {
    // Tags are stored within manga objects, so we just need to notify listeners
    // The actual tag creation happens when manga are updated
    notifyListeners();
  }

  Future<void> updateTag(String oldTag, String newTag) async {
    bool updated = false;
    for (int i = 0; i < _mangaList.length; i++) {
      if (_mangaList[i].tags.contains(oldTag)) {
        _mangaList[i].tags.remove(oldTag);
        if (!_mangaList[i].tags.contains(newTag)) {
          _mangaList[i].tags.add(newTag);
        }
        updated = true;
      }
    }

    if (updated) {
      await _saveManga();
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> deleteTag(String tagName) async {
    bool deleted = false;
    for (int i = 0; i < _mangaList.length; i++) {
      if (_mangaList[i].tags.contains(tagName)) {
        _mangaList[i].tags.remove(tagName);
        deleted = true;
      }
    }

    if (deleted) {
      await _saveManga();
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> deleteAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('manga_list_' + _profileId);
      _mangaList.clear();
      _filteredMangaList.clear();
      _searchQuery = '';
      _selectedStatus = 'All';
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting all data: $e');
      rethrow;
    }
  }

  // Reading session logging
  Future<void> logReadingSession(
    String mangaId,
    int chaptersRead,
    Duration duration,
  ) async {
    final mangaIndex = _mangaList.indexWhere((m) => m.id == mangaId);
    if (mangaIndex != -1) {
      final session = {
        'date': DateTime.now().toIso8601String(),
        'chaptersRead': chaptersRead,
        'duration': duration.inMinutes,
      };

      _mangaList[mangaIndex].history.add(session);
      _mangaList[mangaIndex].currentChapter += chaptersRead;
      _mangaList[mangaIndex].lastUpdated = DateTime.now();

      await _saveManga();
      _applyFilters();
      notifyListeners();
    }
  }

  // Calculate reading streak
  int get readingStreak {
    final readingDays = <DateTime>{};

    for (final manga in _mangaList) {
      for (final session in manga.history) {
        final sessionDate = DateTime.parse(session['date']);
        readingDays.add(
          DateTime(sessionDate.year, sessionDate.month, sessionDate.day),
        );
      }
    }

    if (readingDays.isEmpty) return 0;

    final sortedDays = readingDays.toList()..sort();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int streak = 0;
    DateTime currentDate = todayDate;

    while (sortedDays.contains(currentDate)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // Get reading statistics for specific periods
  Map<String, int> getReadingStats(DateTime startDate, DateTime endDate) {
    int chaptersRead = 0;
    int readingDays = 0;
    final readingDaysSet = <DateTime>{};

    for (final manga in _mangaList) {
      for (final session in manga.history) {
        final sessionDate = DateTime.parse(session['date']);
        if (sessionDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            sessionDate.isBefore(endDate.add(const Duration(days: 1)))) {
          chaptersRead += session['chaptersRead'] as int;
          readingDaysSet.add(
            DateTime(sessionDate.year, sessionDate.month, sessionDate.day),
          );
        }
      }
    }

    readingDays = readingDaysSet.length;

    return {'chaptersRead': chaptersRead, 'readingDays': readingDays};
  }

  // Get daily reading stats
  int get dailyChaptersRead {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final stats = getReadingStats(startOfDay, endOfDay);
    return stats['chaptersRead'] ?? 0;
  }

  // Get weekly reading stats
  int get weeklyChaptersRead {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final stats = getReadingStats(startOfWeek, endOfWeek);
    return stats['chaptersRead'] ?? 0;
  }

  // Get monthly reading stats
  int get monthlyChaptersRead {
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    final endOfMonth = DateTime(today.year, today.month + 1, 0);

    final stats = getReadingStats(startOfMonth, endOfMonth);
    return stats['chaptersRead'] ?? 0;
  }
}
