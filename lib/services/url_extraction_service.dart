import 'package:http/http.dart' as http;

class UrlExtractionService {
  static Future<Map<String, dynamic>> extractMangaInfo(
    String url, {
    bool fetchHtml = false,
  }) async {
    // 1. Try to extract info locally from the URL
    final uri = Uri.tryParse(url);
    String title = '';
    String currentChapter = '';
    String totalChapters = '';
    String author = '';
    String description = '';
    String coverImage = '';

    if (uri != null) {
      // Try to extract title from the path
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        // e.g., /manga-title/chapter-123
        final titleSegment = pathSegments.firstWhere(
          (s) =>
              s.isNotEmpty &&
              !RegExp(
                r'chapter|ch|vol|volume|ep|episode|\d',
              ).hasMatch(s.toLowerCase()),
          orElse: () => '',
        );
        if (titleSegment.isNotEmpty) {
          title = titleSegment.replaceAll('-', ' ').replaceAll('_', ' ');
        }
        // Try to extract chapter from path
        final chapterSegment = pathSegments.firstWhere(
          (s) => RegExp(
            r'(chapter|ch|ep|episode)[-_]?(\d+)',
          ).hasMatch(s.toLowerCase()),
          orElse: () => '',
        );
        if (chapterSegment.isNotEmpty) {
          final match = RegExp(
            r'(chapter|ch|ep|episode)[-_]?(\d+)',
          ).firstMatch(chapterSegment.toLowerCase());
          if (match != null && match.groupCount >= 2) {
            currentChapter = match.group(2) ?? '';
          }
        }
      }
      // Try to extract chapter from query params
      if (currentChapter.isEmpty && uri.queryParameters.isNotEmpty) {
        for (final entry in uri.queryParameters.entries) {
          if (RegExp(
            r'chapter|ch|ep|episode',
          ).hasMatch(entry.key.toLowerCase())) {
            currentChapter = entry.value;
            break;
          }
        }
      }
    }

    // If we got enough info, return it
    if (title.isNotEmpty || currentChapter.isNotEmpty) {
      return {
        'title': title,
        'currentChapter': currentChapter,
        'totalChapters': totalChapters,
        'author': author,
        'description': description,
        'coverImage': coverImage,
      };
    }

    // 2. Optionally fetch HTML for more info if requested
    if (fetchHtml) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final html = response.body;
          // Extract title
          final titleStart = html.indexOf('<title>');
          final titleEnd = html.indexOf('</title>');
          if (titleStart != -1 && titleEnd != -1) {
            title = html.substring(titleStart + 7, titleEnd).trim();
          }
          // Extract chapter information
          final chapterIndex = html.toLowerCase().indexOf('chapter');
          if (chapterIndex != -1) {
            final chapterText = html.substring(chapterIndex, chapterIndex + 20);
            final numbers = RegExp(r'\d+').firstMatch(chapterText);
            if (numbers != null) {
              currentChapter = numbers.group(0) ?? '';
            }
          }
          // Extract total chapters
          final totalIndex = html.toLowerCase().indexOf('total');
          if (totalIndex != -1) {
            final totalText = html.substring(totalIndex, totalIndex + 30);
            final numbers = RegExp(r'\d+').firstMatch(totalText);
            if (numbers != null) {
              totalChapters = numbers.group(0) ?? '';
            }
          }
        }
      } catch (e) {
        // print('Error extracting manga info: $e');
      }
    }
    return {
      'title': title,
      'currentChapter': currentChapter,
      'totalChapters': totalChapters,
      'author': author,
      'description': description,
      'coverImage': coverImage,
    };
  }

  static String? extractChapterFromUrl(String url) {
    // Simple chapter extraction from URL
    final urlLower = url.toLowerCase();

    if (urlLower.contains('chapter')) {
      final chapterIndex = urlLower.indexOf('chapter');
      final afterChapter = url.substring(chapterIndex);
      final numbers = RegExp(r'\d+').firstMatch(afterChapter);
      return numbers?.group(0);
    }

    if (urlLower.contains('ch')) {
      final chIndex = urlLower.indexOf('ch');
      final afterCh = url.substring(chIndex);
      final numbers = RegExp(r'\d+').firstMatch(afterCh);
      return numbers?.group(0);
    }

    if (urlLower.contains('episode')) {
      final episodeIndex = urlLower.indexOf('episode');
      final afterEpisode = url.substring(episodeIndex);
      final numbers = RegExp(r'\d+').firstMatch(afterEpisode);
      return numbers?.group(0);
    }

    if (urlLower.contains('ep')) {
      final epIndex = urlLower.indexOf('ep');
      final afterEp = url.substring(epIndex);
      final numbers = RegExp(r'\d+').firstMatch(afterEp);
      return numbers?.group(0);
    }

    return null;
  }
}
