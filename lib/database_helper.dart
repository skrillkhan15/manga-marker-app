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
  static const String _autoUpdateKey = 'autoUpdateBookmarks';
  static const String _dashboardVisibilityKey = 'dashboardWidgetVisibility';
  static const String _backupFrequencyKey = 'backupFrequency';
  static const String _lastBackupTimeKey = 'lastBackupTime';

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
    // Normalize title for comparison
    String normalize(String s) => s.trim().toLowerCase();
    final existingIndex = list.indexWhere(
      (b) =>
          b.url == bookmark.url ||
          normalize(b.title) == normalize(bookmark.title),
    );
    if (existingIndex != -1) {
      // Update existing bookmark
      final updatedBookmark = bookmark;
      list[existingIndex] = updatedBookmark;
      await saveBookmarks(list);
      await addActivityLogEntry(
        ActivityLogEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'Bookmark Updated',
          description: 'Updated bookmark for ${bookmark.title}',
          timestamp: DateTime.now(),
        ),
      );
    } else {
      list.add(bookmark);
      await saveBookmarks(list);
      await addActivityLogEntry(
        ActivityLogEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'Bookmark Added',
          description: 'Added bookmark for ${bookmark.title}',
          timestamp: DateTime.now(),
        ),
      );
    }
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

  Future<void> updateTag(Tag tag) async {
    final tags = await getTags();
    final idx = tags.indexWhere((t) => t.id == tag.id);
    if (idx != -1) {
      tags[idx] = tag;
      await saveTags(tags);
    }
  }

  Future<void> deleteTag(String tagId) async {
    final tags = await getTags();
    tags.removeWhere((t) => t.id == tagId);
    await saveTags(tags);
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
      // print('Import error: $e');
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
        // print('Exported to $path');
      }
    } catch (e) {
      // print('Export error: $e');
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
      // print('QR Export error: $e');
      return null;
    }
  }

  Future<Bookmark?> importBookmarkFromQrCode(String data) async {
    try {
      final compressed = base64Decode(data);
      final jsonStr = utf8.decode(GZipDecoder().decodeBytes(compressed));
      return Bookmark.fromMap(json.decode(jsonStr));
    } catch (e) {
      // print('QR Import error: $e');
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

  // --- Auto-update Settings ---
  Future<bool> getAutoUpdateBookmarks() async {
    final prefs = await _prefs;
    return prefs.getBool(_autoUpdateKey) ?? true;
  }

  Future<void> setAutoUpdateBookmarks(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_autoUpdateKey, enabled);
  }

  // --- Dashboard Widget Visibility ---
  Future<Map<String, bool>> getDashboardWidgetVisibility() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_dashboardVisibilityKey);
    if (raw != null) {
      final Map<String, dynamic> decoded = json.decode(raw);
      return decoded.map((k, v) => MapEntry(k, v as bool));
    }
    // Default: show all
    return {
      'totalBookmarks': true,
      'favoriteBookmarks': true,
      'totalChaptersRead': true,
      'recentActivity': true,
    };
  }

  Future<void> setDashboardWidgetVisibility(Map<String, bool> map) async {
    final prefs = await _prefs;
    await prefs.setString(_dashboardVisibilityKey, json.encode(map));
  }

  // --- URL-based Content Extraction ---
  static final _chapterPatterns = <RegExp>[
    // Common patterns for manga sites
    RegExp(r'chapter[-_/]?(\d+)', caseSensitive: false),
    RegExp(r'ch[-_/]?(\d+)', caseSensitive: false),
    RegExp(r'/(\d+)/?$', caseSensitive: false), // ending with number
    RegExp(r'episode[-_/]?(\d+)', caseSensitive: false),
    RegExp(r'part[-_/]?(\d+)', caseSensitive: false),
  ];

  static final _titlePatterns = <RegExp>[
    // Common patterns for extracting manga titles
    RegExp(r'/manga/([^/]+)/', caseSensitive: false),
    RegExp(r'/series/([^/]+)/', caseSensitive: false),
    RegExp(r'/title/([^/]+)/', caseSensitive: false),
    RegExp(r'/read/([^/]+)/', caseSensitive: false),
  ];

  int? extractChapterNumberFromUrl(String url) {
    for (var pattern in _chapterPatterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return int.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  String? extractTitleFromUrl(String url) {
    for (var pattern in _titlePatterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final raw = match.group(1)!;
        final words = raw
            .split(RegExp(r'[-_ ]'))
            .map((w) => w.trim())
            .where((w) => w.isNotEmpty);
        return words
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join(' ');
      }
    }
    return null;
  }

  // --- Enhanced Export Options ---
  Future<void> exportDataToHtml() async {
    final bookmarks = await getBookmarks();

    final htmlContent =
        '''
<!DOCTYPE html>
<html>
<head>
    <title>Manga Marker Export</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .bookmark { border: 1px solid #ddd; margin: 10px 0; padding: 15px; border-radius: 5px; }
        .title { font-size: 18px; font-weight: bold; color: #333; }
        .url { color: #666; margin: 5px 0; }
        .details { margin: 10px 0; }
        .tags { background: #f0f0f0; padding: 5px; border-radius: 3px; display: inline-block; margin: 2px; }
    </style>
</head>
<body>
    <h1>Manga Marker Export</h1>
    <p>Exported on: ${DateTime.now().toString()}</p>
    <p>Total Bookmarks: ${bookmarks.length}</p>
    
    ${bookmarks.map((b) => '''
    <div class="bookmark">
        <div class="title">${b.title}</div>
        <div class="url"><a href="${b.url}">${b.url}</a></div>
        <div class="details">
            <strong>Status:</strong> ${b.status} | 
            <strong>Chapter:</strong> ${b.currentChapter}/${b.totalChapters} | 
            <strong>Rating:</strong> ${b.rating}/5
        </div>
        ${b.tags.isNotEmpty ? '<div>Tags: ${b.tags.map((t) => '<span class="tags">$t</span>').join(' ')}</div>' : ''}
        ${b.notes.isNotEmpty ? '<div><strong>Notes:</strong> ${b.notes}</div>' : ''}
    </div>
    ''').join('')}
</body>
</html>
    ''';

    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export as HTML',
        fileName: 'manga_marker_export.html',
        allowedExtensions: ['html'],
        type: FileType.custom,
      );
      if (path != null) {
        await File(path).writeAsString(htmlContent);
        // print('Exported to $path');
      }
    } catch (e) {
      // print('HTML Export error: $e');
    }
  }

  Future<int> getBackupFrequency() async {
    final prefs = await _prefs;
    return prefs.getInt(_backupFrequencyKey) ?? 0;
  }

  Future<void> saveBackupFrequency(int frequency) async {
    final prefs = await _prefs;
    await prefs.setInt(_backupFrequencyKey, frequency);
  }

  Future<DateTime?> getLastBackupTime() async {
    final prefs = await _prefs;
    final str = prefs.getString(_lastBackupTimeKey);
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<void> saveLastBackupTime(DateTime time) async {
    final prefs = await _prefs;
    await prefs.setString(_lastBackupTimeKey, time.toIso8601String());
  }
}
