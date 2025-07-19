import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart';
import 'models/manga.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExportService {
  /// Export manga as JSON with enhanced formatting
  static Future<bool> exportAsJson(
    List<Manga> mangaList,
    Map<String, dynamic> settings,
    String profileId,
    String profileName,
  ) async {
    try {
      final exportData = {
        'metadata': {
          'exportDate': DateTime.now().toIso8601String(),
          'version': '1.0',
          'profileId': profileId,
          'profileName': profileName,
          'totalManga': mangaList.length,
        },
        'manga': mangaList.map((m) => m.toMap()).toList(),
        'settings': settings,
      };
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Manga as JSON',
        fileName:
            'manga_marks_export_${profileName}_${profileId}_${DateTime.now().millisecondsSinceEpoch}.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );
      if (path != null) {
        await File(path).writeAsString(jsonString);
        return true;
      }
    } catch (e) {}
    return false;
  }

  /// Export manga as HTML with enhanced styling
  static Future<bool> exportAsHtml(List<Manga> mangaList) async {
    try {
      final statistics = _generateStatistics(mangaList);
      final htmlContent = _generateHtmlContent(mangaList, statistics);

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Manga as HTML',
        fileName:
            'manga_marks_export_${DateTime.now().millisecondsSinceEpoch}.html',
        allowedExtensions: ['html'],
        type: FileType.custom,
      );

      if (path != null) {
        await File(path).writeAsString(htmlContent);
        return true;
      }
    } catch (e) {
      // print('HTML Export error: $e');
    }
    return false;
  }

  /// Export manga as encrypted JSON
  static Future<bool> exportAsEncryptedJson(
    List<Manga> mangaList,
    Map<String, dynamic> settings,
    String profileId,
    String profileName,
    String password,
  ) async {
    try {
      final exportData = {
        'metadata': {
          'exportDate': DateTime.now().toIso8601String(),
          'version': '1.0',
          'profileId': profileId,
          'profileName': profileName,
          'totalManga': mangaList.length,
          'encrypted': true,
        },
        'manga': mangaList.map((m) => m.toMap()).toList(),
        'settings': settings,
      };
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final key = Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
      final iv = IV.fromLength(16);
      final encrypter = Encrypter(AES(key));
      final encrypted = encrypter.encrypt(jsonString, iv: iv);
      final encryptedData = {
        'iv': base64.encode(iv.bytes),
        'data': encrypted.base64,
      };
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Encrypted Manga Data',
        fileName:
            'manga_marks_encrypted_${profileName}_${profileId}_${DateTime.now().millisecondsSinceEpoch}.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );
      if (path != null) {
        await File(path).writeAsString(json.encode(encryptedData));
        return true;
      }
    } catch (e) {}
    return false;
  }

  /// Import manga from JSON file
  static Future<Map<String, dynamic>?> importFromJson(String profileId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = json.decode(jsonString);
        if (data is Map<String, dynamic> && data.containsKey('manga')) {
          // Only import if profileId matches or is empty
          if (data['metadata']?['profileId'] == null ||
              data['metadata']['profileId'] == profileId) {
            return data;
          }
        }
      }
    } catch (e) {}
    return null;
  }

  /// Import manga from encrypted JSON file
  static Future<Map<String, dynamic>?> importFromEncryptedJson(
    String profileId,
    String password,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final encryptedJsonString = await file.readAsString();
        final encryptedData = json.decode(encryptedJsonString);
        if (encryptedData is Map<String, dynamic> &&
            encryptedData.containsKey('iv') &&
            encryptedData.containsKey('data')) {
          final key = Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
          final iv = IV.fromBase64(encryptedData['iv']);
          final encrypter = Encrypter(AES(key));
          final decrypted = encrypter.decrypt64(encryptedData['data'], iv: iv);
          final data = json.decode(decrypted);
          if (data is Map<String, dynamic> && data.containsKey('manga')) {
            if (data['metadata']?['profileId'] == null ||
                data['metadata']['profileId'] == profileId) {
              return data;
            }
          }
        }
      }
    } catch (e) {}
    return null;
  }

  /// Generate statistics from manga
  static Map<String, dynamic> _generateStatistics(List<Manga> mangaList) {
    final stats = <String, dynamic>{};

    stats['totalManga'] = mangaList.length;
    stats['totalChaptersRead'] = mangaList.fold(
      0,
      (sum, m) => sum + m.currentChapter,
    );

    // Status distribution
    final statusCounts = <String, int>{};
    for (var manga in mangaList) {
      statusCounts[manga.status] = (statusCounts[manga.status] ?? 0) + 1;
    }
    stats['statusDistribution'] = statusCounts;

    // Rating distribution
    final ratingCounts = <int, int>{};
    for (var manga in mangaList) {
      if (manga.rating > 0) {
        ratingCounts[manga.rating] = (ratingCounts[manga.rating] ?? 0) + 1;
      }
    }
    stats['ratingDistribution'] = ratingCounts;

    // Tag usage
    final tagCounts = <String, int>{};
    for (var manga in mangaList) {
      for (var tag in manga.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    stats['tagUsage'] = tagCounts;

    // Average rating
    final ratedManga = mangaList.where((m) => m.rating > 0).toList();
    if (ratedManga.isNotEmpty) {
      stats['averageRating'] =
          ratedManga.map((m) => m.rating).reduce((a, b) => a + b) /
          ratedManga.length;
    }

    return stats;
  }

  /// Generate HTML content with enhanced styling
  static String _generateHtmlContent(
    List<Manga> mangaList,
    Map<String, dynamic> statistics,
  ) {
    final exportDate = DateTime.now();

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MangaMarks Export</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f5f5f5;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 1.1em;
            opacity: 0.9;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            padding: 30px;
            background: #f8f9fa;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .stat-number {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
            display: block;
        }
        
        .stat-label {
            color: #666;
            margin-top: 5px;
        }
        
        .manga-section {
            padding: 30px;
        }
        
        .section-title {
            font-size: 1.8em;
            margin-bottom: 20px;
            color: #333;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
        }
        
        .manga-grid {
            display: grid;
            gap: 20px;
        }
        
        .manga-card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .manga-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .manga-title {
            font-size: 1.3em;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }
        
        .manga-url {
            color: #667eea;
            text-decoration: none;
            word-break: break-all;
            margin-bottom: 10px;
            display: block;
        }
        
        .manga-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 10px;
            margin: 15px 0;
        }
        
        .detail-item {
            background: #f8f9fa;
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 0.9em;
        }
        
        .detail-label {
            font-weight: bold;
            color: #555;
        }
        
        .tags {
            margin-top: 10px;
        }
        
        .tag {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            margin: 2px;
        }
        
        .notes {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 4px;
            padding: 10px;
            margin-top: 10px;
            font-style: italic;
        }
        
        .rating {
            color: #f39c12;
        }
        
        .status {
            font-weight: bold;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.9em;
        }
        
        .status.reading { background: #d4edda; color: #155724; }
        .status.completed { background: #cce5ff; color: #004085; }
        .status.on-hold { background: #fff3cd; color: #856404; }
        .status.dropped { background: #f8d7da; color: #721c24; }
        .status.plan-to-read { background: #e2e3e5; color: #383d41; }
        
        .footer {
            background: #333;
            color: white;
            text-align: center;
            padding: 20px;
            font-size: 0.9em;
        }
        
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .manga-details {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📚 MangaMarks Export</h1>
            <p>Exported on ${exportDate.day}/${exportDate.month}/${exportDate.year} at ${exportDate.hour}:${exportDate.minute.toString().padLeft(2, '0')}</p>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-number">${statistics['totalManga']}</span>
                <div class="stat-label">Total Manga</div>
            </div>
            <div class="stat-card">
                <span class="stat-number">${statistics['totalChaptersRead']}</span>
                <div class="stat-label">Chapters Read</div>
            </div>
            <div class="stat-card">
                <span class="stat-number">${(statistics['averageRating'] ?? 0).toStringAsFixed(1)}</span>
                <div class="stat-label">Average Rating</div>
            </div>
            <div class="stat-card">
                <span class="stat-number">${mangaList.map((m) => m.tags).expand((tags) => tags).toSet().length}</span>
                <div class="stat-label">Total Tags</div>
            </div>
        </div>
        
        <div class="manga-section">
            <h2 class="section-title">📖 Your Manga</h2>
            <div class="manga-grid">
                ${mangaList.map((manga) => '''
                <div class="manga-card">
                    <div class="manga-title">${manga.title}</div>
                    <a href="${manga.url}" class="manga-url" target="_blank">${manga.url}</a>
                    
                    <div class="manga-details">
                        <div class="detail-item">
                            <span class="detail-label">Status:</span>
                            <span class="status ${manga.status.toLowerCase().replaceAll(' ', '-')}">${manga.status}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Progress:</span>
                            ${manga.currentChapter}/${manga.totalChapters > 0 ? manga.totalChapters : '?'} chapters
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Rating:</span>
                            <span class="rating">${'★' * manga.rating}${'☆' * (5 - manga.rating)}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Last Updated:</span>
                            ${manga.lastUpdated.day}/${manga.lastUpdated.month}/${manga.lastUpdated.year}
                        </div>
                    </div>
                    
                    ${manga.tags.isNotEmpty ? '''
                    <div class="tags">
                        ${manga.tags.map((tag) => '<span class="tag">$tag</span>').join('')}
                    </div>
                    ''' : ''}
                    
                    ${manga.notes.isNotEmpty ? '''
                    <div class="notes">
                        <strong>Notes:</strong> ${manga.notes}
                    </div>
                    ''' : ''}
                </div>
                ''').join('')}
            </div>
        </div>
        
        <div class="footer">
            Generated by MangaMarks • ${mangaList.length} manga exported
        </div>
    </div>
</body>
</html>
    ''';
  }

  static Future<List<Map<String, dynamic>>> _getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString('profiles');
    if (profilesJson != null) {
      final List<dynamic> list = json.decode(profilesJson);
      return List<Map<String, dynamic>>.from(list);
    }
    return [];
  }

  static Future<Map<String, dynamic>> _getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      return json.decode(settingsJson);
    }
    return {};
  }

  static Future<void> _restoreProfiles(dynamic profiles) async {
    if (profiles is List) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profiles', json.encode(profiles));
      if (profiles.isNotEmpty &&
          profiles[0] is Map &&
          profiles[0]['id'] != null) {
        await prefs.setString('active_profile_id', profiles[0]['id']);
      }
    }
  }

  static Future<void> _restoreSettings(dynamic settings) async {
    if (settings is Map) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', json.encode(settings));
    }
  }
}
