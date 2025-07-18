import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'models.dart';

class DatabaseHelper {
  static const String _bookmarksKey = 'bookmarks';
  static const String _tagsKey = 'tags';
  static const String _readingStatusKey = 'readingStatus';
  static const String _readingGoalsKey = 'readingGoals';
  static const String _viewPresetsKey = 'viewPresets';
  static const String _activityLogKey = 'activityLog';
  static const String _devModeKey = 'devMode';
  static const String _sessionDataKey = 'sessionData';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // --- Bookmarks ---
  Future<List<Bookmark>> getBookmarks() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_bookmarksKey) ?? [];
    return list.map((e) => Bookmark.fromMap(json.decode(e))).toList();
  }

  Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    final prefs = await _prefs;
    final list = bookmarks.map((b) => json.encode(b.toMap())).toList();
    await prefs.setStringList(_bookmarksKey, list);
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    final list = await getBookmarks();
    list.add(bookmark);
    await saveBookmarks(list);
  }

  Future<void> updateBookmark(Bookmark bookmark) async {
    final list = await getBookmarks();
    final index = list.indexWhere((b) => b.id == bookmark.id);
    if (index != -1) {
      // Create new history list with previous bookmark's map added
      final newHistory = List<Map<String, dynamic>>.from(list[index].history);
      newHistory.add(list[index].toMap());

      // Create a new Bookmark instance with updated history to avoid mutating original object
      final updatedBookmark = Bookmark(
        id: bookmark.id,
        title: bookmark.title,
        url: bookmark.url,
        coverImage: bookmark.coverImage,
        currentChapter: bookmark.currentChapter,
        totalChapters: bookmark.totalChapters,
        status: bookmark.status,
        tags: List<String>.from(bookmark.tags),
        notes: bookmark.notes,
        rating: bookmark.rating,
        mood: bookmark.mood,
        collectionId: bookmark.collectionId,
        lastUpdated: bookmark.lastUpdated,
        history: newHistory,
      );

      list[index] = updatedBookmark;
      await saveBookmarks(list);
    }
  }

  Future<void> deleteBookmark(String id) async {
    final list = await getBookmarks();
    list.removeWhere((b) => b.id == id);
    await saveBookmarks(list);
  }

  // --- Tags ---
  Future<List<Tag>> getTags() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_tagsKey) ?? [];
    return list.map((e) => Tag(id: e, name: e)).toList();
  }

  Future<void> saveTags(List<Tag> tags) async {
    final prefs = await _prefs;
    final list = tags.map((t) => t.name).toList();
    await prefs.setStringList(_tagsKey, list);
  }

  Future<void> addTag(Tag tag) async {
    final list = await getTags();
    if (!list.any((t) => t.name == tag.name)) {
      list.add(tag);
      await saveTags(list);
    }
  }

  // --- Reading Status ---
  Future<List<ReadingStatus>> getReadingStatus() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_readingStatusKey) ?? [];
    return list.map((e) => ReadingStatus(id: e, name: e)).toList();
  }

  Future<void> saveReadingStatus(List<ReadingStatus> list) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      _readingStatusKey,
      list.map((e) => e.name).toList(),
    );
  }

  // --- Reading Goals ---
  Future<List<ReadingGoal>> getReadingGoals() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_readingGoalsKey) ?? [];
    // Corrected: decode JSON string to Map, then pass to fromMap
    return list.map((e) => ReadingGoal.fromMap(json.decode(e))).toList();
  }

  Future<void> saveReadingGoals(List<ReadingGoal> goals) async {
    final prefs = await _prefs;
    // Corrected: encode Map to JSON string, don't double encode
    final list = goals.map((g) => json.encode(g.toMap())).toList();
    await prefs.setStringList(_readingGoalsKey, list);
  }

  Future<void> addReadingGoal(ReadingGoal goal) async {
    final goals = await getReadingGoals();
    goals.add(goal);
    await saveReadingGoals(goals);
  }

  Future<void> updateReadingGoal(ReadingGoal goal) async {
    final goals = await getReadingGoals();
    final idx = goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) {
      goals[idx] = goal;
      await saveReadingGoals(goals);
    }
  }

  Future<void> deleteReadingGoal(String goalId) async {
    final goals = await getReadingGoals();
    goals.removeWhere((g) => g.id == goalId);
    await saveReadingGoals(goals);
  }

  // --- View Presets ---
  Future<List<ViewPreset>> getViewPresets() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_viewPresetsKey) ?? [];
    return list.map((e) => ViewPreset.fromMap(json.decode(e))).toList();
  }

  Future<void> saveViewPresets(List<ViewPreset> presets) async {
    final prefs = await _prefs;
    final list = presets.map((p) => json.encode(p.toMap())).toList();
    await prefs.setStringList(_viewPresetsKey, list);
  }

  // --- Export/Import ---
  Future<bool> importDataFromJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null) {
        final file = File(result.files.single.path!);
        final data = json.decode(await file.readAsString());
        await saveBookmarks(
          (data['bookmarks'] as List).map((e) => Bookmark.fromMap(e)).toList(),
        );
        await saveTags(
          (data['tags'] as List).map((e) => Tag(id: e, name: e)).toList(),
        );
        await saveReadingStatus(
          (data['readingStatus'] as List)
              .map((e) => ReadingStatus(id: e, name: e))
              .toList(),
        );
        return true;
      }
    } catch (e) {
      print('Import error: $e');
    }
    return false;
  }

  Future<void> exportDataToJson() async {
    final data = {
      'bookmarks': (await getBookmarks()).map((b) => b.toMap()).toList(),
      'tags': (await getTags()).map((t) => t.name).toList(),
      'readingStatus': (await getReadingStatus()).map((rs) => rs.name).toList(),
    };
    final jsonString = json.encode(data);

    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Data',
        fileName: 'manga_marker_data.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );
      if (path != null) {
        await File(path).writeAsString(jsonString);
        print('Exported to $path');
      }
    } catch (e) {
      print('Export error: $e');
    }
  }

  // --- Encryption ---
  Future<void> exportEncryptedDataToJson(String password) async {
    final key = encrypt.Key.fromUtf8(password.padRight(32, '0'));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final data = {
      'bookmarks': (await getBookmarks()).map((b) => b.toMap()).toList(),
      'tags': (await getTags()).map((t) => t.name).toList(),
      'readingStatus': (await getReadingStatus()).map((rs) => rs.name).toList(),
    };

    final encrypted = encrypter.encrypt(json.encode(data), iv: iv);

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Encrypted',
      fileName: 'manga_marker_encrypted.json',
      allowedExtensions: ['json'],
      type: FileType.custom,
    );
    if (path != null) {
      await File(path).writeAsString(encrypted.base64);
    }
  }

  Future<void> importEncryptedDataFromJson(String password) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      final encryptedString = await File(
        result.files.single.path!,
      ).readAsString();

      final key = encrypt.Key.fromUtf8(password.padRight(32, '0'));
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decrypt(
        encrypt.Encrypted.fromBase64(encryptedString),
        iv: iv,
      );
      final data = json.decode(decrypted);

      await saveBookmarks(
        (data['bookmarks'] as List).map((e) => Bookmark.fromMap(e)).toList(),
      );
      await saveTags(
        (data['tags'] as List).map((e) => Tag(id: e, name: e)).toList(),
      );
      await saveReadingStatus(
        (data['readingStatus'] as List)
            .map((e) => ReadingStatus(id: e, name: e))
            .toList(),
      );
    }
  }

  // --- Backup & Restore ---
  Future<String> _getBackupDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/MangaMarkerBackups';
    final backupDir = Directory(path);
    if (!await backupDir.exists()) await backupDir.create(recursive: true);
    return path;
  }

  Future<void> performAutoBackup() async {
    final dir = await _getBackupDirectory();
    final fileName =
        'backup_${DateTime.now().toIso8601String().split('T').first}.json';
    final path = '$dir/$fileName';

    final data = {
      'bookmarks': (await getBookmarks()).map((b) => b.toMap()).toList(),
      'tags': (await getTags()).map((t) => t.name).toList(),
      'readingStatus': (await getReadingStatus()).map((rs) => rs.name).toList(),
    };

    await File(path).writeAsString(json.encode(data));
  }

  Future<void> restoreFromBackup(File file) async {
    final data = json.decode(await file.readAsString());
    await saveBookmarks(
      (data['bookmarks'] as List).map((e) => Bookmark.fromMap(e)).toList(),
    );
    await saveTags(
      (data['tags'] as List).map((e) => Tag(id: e, name: e)).toList(),
    );
    await saveReadingStatus(
      (data['readingStatus'] as List)
          .map((e) => ReadingStatus(id: e, name: e))
          .toList(),
    );
  }

  // --- QR Code Export/Import ---
  Future<String?> exportBookmarkAsQrCode(Bookmark bookmark) async {
    try {
      // Fixed: use toMap(), then encode, no double encode
      final jsonStr = json.encode(bookmark.toMap());
      final compressed = GZipEncoder().encode(
        Uint8List.fromList(utf8.encode(jsonStr)),
      );
      return compressed == null ? null : base64Encode(compressed);
    } catch (e) {
      print('QR Export error: $e');
      return null;
    }
  }

  Future<Bookmark?> importBookmarkFromQrCode(String data) async {
    try {
      final compressed = base64Decode(data);
      final jsonStr = utf8.decode(GZipDecoder().decodeBytes(compressed));
      return Bookmark.fromMap(json.decode(jsonStr));
    } catch (e) {
      print('QR Import error: $e');
      return null;
    }
  }

  // --- Activity Log ---
  Future<List<ActivityLogEntry>> getActivityLog() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_activityLogKey) ?? [];
    return list.map((e) => ActivityLogEntry.fromMap(json.decode(e))).toList();
  }

  Future<void> addActivityLogEntry(ActivityLogEntry entry) async {
    final list = await getActivityLog();
    list.add(entry);
    await saveActivityLog(list);
  }

  Future<void> saveActivityLog(List<ActivityLogEntry> log) async {
    final prefs = await _prefs;
    final list = log.map((e) => json.encode(e.toMap())).toList();
    await prefs.setStringList(_activityLogKey, list);
  }

  // --- Dev Mode ---
  Future<void> setDevMode(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_devModeKey, enabled);
  }

  Future<bool> getDevMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_devModeKey) ?? false;
  }

  // --- Session Data ---
  Future<void> saveSessionData(Map<String, dynamic> data) async {
    final prefs = await _prefs;
    await prefs.setString(_sessionDataKey, json.encode(data));
  }

  Future<Map<String, dynamic>?> loadSessionData() async {
    final prefs = await _prefs;
    final str = prefs.getString(_sessionDataKey);
    return str != null ? json.decode(str) : null;
  }

  // --- Clear All ---
  Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  Future<int> getLocalStorageSize() async {
    final prefs = await _prefs;
    int size = 0;
    for (final key in prefs.getKeys()) {
      final val = prefs.get(key);
      if (val is String) {
        size += utf8.encode(val).length;
      } else if (val is List<String>)
        size += val.fold(0, (prev, s) => prev + utf8.encode(s).length);
    }
    return size;
  }

  int? extractChapterNumberFromUrl(String url) {
    final regex = RegExp(r'chapter[-_]?([0-9]+)');
    final match = regex.firstMatch(url);
    return match != null ? int.tryParse(match.group(1) ?? '') : null;
  }

  Future<bool> getAutoUpdateBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('autoUpdateBookmarks') ?? false;
  }

  Future<void> setAutoUpdateBookmarks(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoUpdateBookmarks', enabled);
  }

  Future<Map<String, bool>> getDashboardWidgetVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'goals': prefs.getBool('widget_goals') ?? true,
      'recent': prefs.getBool('widget_recent') ?? true,
      'stats': prefs.getBool('widget_stats') ?? true,
    };
  }

  Future<void> setDashboardWidgetVisibility(Map<String, bool> values) async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in values.entries) {
      await prefs.setBool('widget_${entry.key}', entry.value);
    }
  }
}
