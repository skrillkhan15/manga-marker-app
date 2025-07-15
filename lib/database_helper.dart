import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'models.dart';

class DatabaseHelper {
  static const String _bookmarksKey = 'bookmarks';
  static const String _viewPresetsKey = 'viewPresets';
  static const String _devModeKey = 'devMode';
  static const String _sessionDataKey = 'sessionData';
  static const String _activityLogKey = 'activityLog';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    final prefs = await _prefs;
    final bookmarksJson = bookmarks.map((b) => jsonEncode(b.toMap())).toList();
    await prefs.setStringList(_bookmarksKey, bookmarksJson);
  }

  Future<List<Bookmark>> getBookmarks() async {
    final prefs = await _prefs;
    final bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];
    return bookmarksJson.map((json) => Bookmark.fromMap(jsonDecode(json))).toList();
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    final bookmarks = await getBookmarks();
    bookmarks.add(bookmark);
    await saveBookmarks(bookmarks);
  }

  Future<void> updateBookmark(Bookmark bookmark) async {
    final bookmarks = await getBookmarks();
    final index = bookmarks.indexWhere((b) => b.id == bookmark.id);
    if (index != -1) {
      bookmarks[index] = bookmark;
      await saveBookmarks(bookmarks);
    }
  }

  Future<void> deleteBookmark(String id) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b.id == id);
    await saveBookmarks(bookmarks);
  }

  Future<void> saveViewPresets(List<ViewPreset> presets) async {
    final prefs = await _prefs;
    final presetsJson = presets.map((p) => jsonEncode(p.toMap())).toList();
    await prefs.setStringList(_viewPresetsKey, presetsJson);
  }

  Future<List<ViewPreset>> getViewPresets() async {
    final prefs = await _prefs;
    final presetsJson = prefs.getStringList(_viewPresetsKey) ?? [];
    return presetsJson.map((json) => ViewPreset.fromMap(jsonDecode(json))).toList();
  }

  Future<void> setDevMode(bool devMode) async {
    final prefs = await _prefs;
    await prefs.setBool(_devModeKey, devMode);
  }

  Future<bool> getDevMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_devModeKey) ?? false;
  }

  Future<void> saveSessionData(Map<String, dynamic> data) async {
    final prefs = await _prefs;
    await prefs.setString(_sessionDataKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadSessionData() async {
    final prefs = await _prefs;
    final sessionDataJson = prefs.getString(_sessionDataKey);
    if (sessionDataJson != null) {
      return jsonDecode(sessionDataJson);
    }
    return null;
  }

  Future<void> addActivityLogEntry(ActivityLogEntry entry) async {
    final log = await getActivityLog();
    log.add(entry);
    await saveActivityLog(log);
  }

  Future<void> saveActivityLog(List<ActivityLogEntry> log) async {
    final prefs = await _prefs;
    final logJson = log.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_activityLogKey, logJson);
  }

  Future<List<ActivityLogEntry>> getActivityLog() async {
    final prefs = await _prefs;
    final logJson = prefs.getStringList(_activityLogKey) ?? [];
    return logJson.map((json) => ActivityLogEntry.fromMap(jsonDecode(json))).toList();
  }

  Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  Future<int> getLocalStorageSize() async {
    final prefs = await _prefs;
    final keys = prefs.getKeys();
    int totalSize = 0;
    for (final key in keys) {
      totalSize += (prefs.get(key).toString().length);
    }
    return totalSize;
  }

  Future<void> exportDataToJson() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/manga_marker_backup.json');
    final bookmarks = await getBookmarks();
    final data = {
      'bookmarks': bookmarks.map((b) => b.toMap()).toList(),
    };
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> importDataFromJson() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/manga_marker_backup.json');
    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString());
      final bookmarks = (data['bookmarks'] as List).map((b) => Bookmark.fromMap(b)).toList();
      await saveBookmarks(bookmarks);
    }
  }

  Future<void> exportEncryptedDataToJson(String password) async {
    final key = encrypt.Key.fromUtf8(password.padRight(32, '0'));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/manga_marker_backup.enc');
    final bookmarks = await getBookmarks();
    final data = {
      'bookmarks': bookmarks.map((b) => b.toMap()).toList(),
    };
    final encrypted = encrypter.encrypt(jsonEncode(data), iv: iv);
    await file.writeAsBytes(encrypted.bytes);
  }

  Future<void> importEncryptedDataFromJson(String password) async {
    final key = encrypt.Key.fromUtf8(password.padRight(32, '0'));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/manga_marker_backup.enc');
    if (await file.exists()) {
      final encrypted = encrypt.Encrypted(await file.readAsBytes());
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      final data = jsonDecode(decrypted);
      final bookmarks = (data['bookmarks'] as List).map((b) => Bookmark.fromMap(b)).toList();
      await saveBookmarks(bookmarks);
    }
  }

  Future<String> exportBookmarkAsQrCode(String data) async {
    // Replace with actual logic later
    return base64Encode(utf8.encode(data));
  }

  Future<Bookmark?> importBookmarkFromQrCode(String qrData) async {
    try {
      final data = jsonDecode(qrData);
      return Bookmark.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> performAutoBackup() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/manga_marker_autobackup.json');
    final bookmarks = await getBookmarks();
    final data = {
      'bookmarks': bookmarks.map((b) => b.toMap()).toList(),
    };
    await file.writeAsString(jsonEncode(data));
  }

  Future<List<File>> getAvailableBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().where((item) => item.path.endsWith('.json')).map((item) => File(item.path)).toList();
    return files;
  }

  Future<void> restoreFromBackup(File backupFile) async {
    if (await backupFile.exists()) {
      final data = jsonDecode(await backupFile.readAsString());
      final bookmarks = (data['bookmarks'] as List).map((b) => Bookmark.fromMap(b)).toList();
      await saveBookmarks(bookmarks);
    }
  }
}