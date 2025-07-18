import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class ExportService {
  /// Export bookmarks as JSON with enhanced formatting
  static Future<bool> exportAsJson(List<Bookmark> bookmarks, List<Tag> tags) async {
    try {
      final exportData = {
        'metadata': {
          'exportDate': DateTime.now().toIso8601String(),
          'version': '1.0',
          'totalBookmarks': bookmarks.length,
          'totalTags': tags.length,
        },
        'bookmarks': bookmarks.map((b) => b.toMap()).toList(),
        'tags': tags.map((t) => t.toMap()).toList(),
        'statistics': _generateStatistics(bookmarks),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Bookmarks as JSON',
        fileName: 'manga_marker_export_${DateTime.now().millisecondsSinceEpoch}.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );

      if (path != null) {
        await File(path).writeAsString(jsonString);
        return true;
      }
    } catch (e) {
      print('JSON Export error: $e');
    }
    return false;
  }

  /// Export bookmarks as HTML with enhanced styling
  static Future<bool> exportAsHtml(List<Bookmark> bookmarks, List<Tag> tags) async {
    try {
      final statistics = _generateStatistics(bookmarks);
      final htmlContent = _generateHtmlContent(bookmarks, tags, statistics);

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Bookmarks as HTML',
        fileName: 'manga_marker_export_${DateTime.now().millisecondsSinceEpoch}.html',
        allowedExtensions: ['html'],
        type: FileType.custom,
      );

      if (path != null) {
        await File(path).writeAsString(htmlContent);
        return true;
      }
    } catch (e) {
      print('HTML Export error: $e');
    }
    return false;
  }

  /// Import bookmarks from JSON file
  static Future<Map<String, dynamic>?> importFromJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = json.decode(jsonString);

        // Validate the structure
        if (data is Map<String, dynamic> && data.containsKey('bookmarks')) {
          return data;
        }
      }
    } catch (e) {
      print('Import error: $e');
    }
    return null;
  }

  /// Generate statistics from bookmarks
  static Map<String, dynamic> _generateStatistics(List<Bookmark> bookmarks) {
    final stats = <String, dynamic>{};
    
    stats['totalBookmarks'] = bookmarks.length;
    stats['totalChaptersRead'] = bookmarks.fold(0, (sum, b) => sum + b.currentChapter);
    
    // Status distribution
    final statusCounts = <String, int>{};
    for (var bookmark in bookmarks) {
      statusCounts[bookmark.status] = (statusCounts[bookmark.status] ?? 0) + 1;
    }
    stats['statusDistribution'] = statusCounts;
    
    // Rating distribution
    final ratingCounts = <int, int>{};
    for (var bookmark in bookmarks) {
      if (bookmark.rating > 0) {
        ratingCounts[bookmark.rating] = (ratingCounts[bookmark.rating] ?? 0) + 1;
      }
    }
    stats['ratingDistribution'] = ratingCounts;
    
    // Tag usage
    final tagCounts = <String, int>{};
    for (var bookmark in bookmarks) {
      for (var tag in bookmark.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    stats['tagUsage'] = tagCounts;
    
    // Average rating
    final ratedBookmarks = bookmarks.where((b) => b.rating > 0).toList();
    if (ratedBookmarks.isNotEmpty) {
      stats['averageRating'] = ratedBookmarks
          .map((b) => b.rating)
          .reduce((a, b) => a + b) / ratedBookmarks.length;
    }
    
    return stats;
  }

  /// Generate HTML content with enhanced styling
  static String _generateHtmlContent(
    List<Bookmark> bookmarks, 
    List<Tag> tags, 
    Map<String, dynamic> statistics
  ) {
    final exportDate = DateTime.now();
    
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manga Marker Export</title>
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
        
        .bookmarks-section {
            padding: 30px;
        }
        
        .section-title {
            font-size: 1.8em;
            margin-bottom: 20px;
            color: #333;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
        }
        
        .bookmark-grid {
            display: grid;
            gap: 20px;
        }
        
        .bookmark-card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .bookmark-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .bookmark-title {
            font-size: 1.3em;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }
        
        .bookmark-url {
            color: #667eea;
            text-decoration: none;
            word-break: break-all;
            margin-bottom: 10px;
            display: block;
        }
        
        .bookmark-details {
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
            
            .bookmark-details {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📚 Manga Marker Export</h1>
            <p>Exported on ${exportDate.day}/${exportDate.month}/${exportDate.year} at ${exportDate.hour}:${exportDate.minute.toString().padLeft(2, '0')}</p>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-number">${statistics['totalBookmarks']}</span>
                <div class="stat-label">Total Bookmarks</div>
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
                <span class="stat-number">${tags.length}</span>
                <div class="stat-label">Total Tags</div>
            </div>
        </div>
        
        <div class="bookmarks-section">
            <h2 class="section-title">📖 Your Bookmarks</h2>
            <div class="bookmark-grid">
                ${bookmarks.map((bookmark) => '''
                <div class="bookmark-card">
                    <div class="bookmark-title">${bookmark.title}</div>
                    <a href="${bookmark.url}" class="bookmark-url" target="_blank">${bookmark.url}</a>
                    
                    <div class="bookmark-details">
                        <div class="detail-item">
                            <span class="detail-label">Status:</span>
                            <span class="status ${bookmark.status.toLowerCase().replaceAll(' ', '-')}">${bookmark.status}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Progress:</span>
                            ${bookmark.currentChapter}/${bookmark.totalChapters > 0 ? bookmark.totalChapters : '?'} chapters
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Rating:</span>
                            <span class="rating">${'★' * bookmark.rating}${'☆' * (5 - bookmark.rating)}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Last Updated:</span>
                            ${bookmark.lastUpdated.day}/${bookmark.lastUpdated.month}/${bookmark.lastUpdated.year}
                        </div>
                    </div>
                    
                    ${bookmark.tags.isNotEmpty ? '''
                    <div class="tags">
                        ${bookmark.tags.map((tag) => '<span class="tag">$tag</span>').join('')}
                    </div>
                    ''' : ''}
                    
                    ${bookmark.notes.isNotEmpty ? '''
                    <div class="notes">
                        <strong>Notes:</strong> ${bookmark.notes}
                    </div>
                    ''' : ''}
                </div>
                ''').join('')}
            </div>
        </div>
        
        <div class="footer">
            Generated by Manga Marker • ${bookmarks.length} bookmarks exported
        </div>
    </div>
</body>
</html>
    ''';
  }
}
