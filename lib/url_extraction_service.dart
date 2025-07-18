class UrlExtractionService {
  // Common manga site patterns for chapter extraction
  static final List<RegExp> _chapterPatterns = [
    // MangaDex pattern
    RegExp(r'/chapter/[^/]+-chapter-(\d+)', caseSensitive: false),
    // Generic chapter patterns
    RegExp(r'chapter[-_/]?(\d+)', caseSensitive: false),
    RegExp(r'ch[-_/]?(\d+)', caseSensitive: false),
    RegExp(r'/(\d+)/?$', caseSensitive: false), // ending with number
    RegExp(r'episode[-_/]?(\d+)', caseSensitive: false),
    RegExp(r'part[-_/]?(\d+)', caseSensitive: false),
    // Webtoon patterns
    RegExp(r'episode_no=(\d+)', caseSensitive: false),
    // Manga reader patterns
    RegExp(r'/read/[^/]+/(\d+)', caseSensitive: false),
  ];

  // Common manga site patterns for title extraction
  static final List<RegExp> _titlePatterns = [
    // MangaDex
    RegExp(r'/title/[^/]+/([^/]+)', caseSensitive: false),
    // Generic patterns
    RegExp(r'/manga/([^/]+)/', caseSensitive: false),
    RegExp(r'/series/([^/]+)/', caseSensitive: false),
    RegExp(r'/title/([^/]+)/', caseSensitive: false),
    RegExp(r'/read/([^/]+)/', caseSensitive: false),
    RegExp(r'/comic/([^/]+)/', caseSensitive: false),
    RegExp(r'/webtoon/([^/]+)/', caseSensitive: false),
    // Specific site patterns
    RegExp(r'mangakakalot\.com/manga/([^/]+)', caseSensitive: false),
    RegExp(r'manganelo\.com/manga/([^/]+)', caseSensitive: false),
    RegExp(r'readmanga\.today/([^/]+)', caseSensitive: false),
  ];

  /// Extract chapter number from URL
  static int? extractChapterNumber(String url) {
    if (url.isEmpty) return null;

    for (var pattern in _chapterPatterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final chapterStr = match.group(1);
        if (chapterStr != null) {
          return int.tryParse(chapterStr);
        }
      }
    }

    // Fallback: try to find any number in the URL path
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final pathSegments = uri.pathSegments.reversed;
      for (var segment in pathSegments) {
        final numbers = RegExp(r'\d+').allMatches(segment);
        for (var match in numbers) {
          final number = int.tryParse(match.group(0)!);
          if (number != null && number > 0 && number < 10000) {
            return number;
          }
        }
      }
    }

    return null;
  }

  /// Extract manga title from URL
  static String? extractTitle(String url) {
    if (url.isEmpty) return null;

    for (var pattern in _titlePatterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final titleSlug = match.group(1);
        if (titleSlug != null) {
          return _formatTitle(titleSlug);
        }
      }
    }

    // Fallback: try to extract from domain and path
    final uri = Uri.tryParse(url);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      // Look for meaningful path segments
      for (var segment in uri.pathSegments) {
        if (segment.length > 3 &&
            !segment.contains(RegExp(r'^\d+$')) && // not just numbers
            ![
              'manga',
              'chapter',
              'read',
              'series',
              'title',
              'comic',
            ].contains(segment.toLowerCase())) {
          return _formatTitle(segment);
        }
      }
    }

    return null;
  }

  /// Format title slug into readable title
  static String _formatTitle(String slug) {
    // Replace common separators with spaces
    String formatted = slug
        .replaceAll(RegExp(r'[-_+]'), ' ')
        .replaceAll(RegExp(r'%20'), ' ')
        .trim();

    // Decode URL encoding
    try {
      formatted = Uri.decodeComponent(formatted);
    } catch (e) {
      // If decoding fails, use the original
    }

    // Split into words and capitalize
    final words = formatted
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) {
          // Handle special cases
          if (word.toLowerCase() == 'wa') return 'wa';
          if (word.toLowerCase() == 'no') return 'no';
          if (word.toLowerCase() == 'ni') return 'ni';
          if (word.toLowerCase() == 'ga') return 'ga';
          if (word.toLowerCase() == 'wo') return 'wo';

          // Capitalize first letter, keep rest as is for proper nouns
          return word[0].toUpperCase() + word.substring(1);
        });

    return words.join(' ');
  }

  /// Get supported site information
  static Map<String, List<String>> getSupportedSites() {
    return {
      'MangaDex': ['mangadex.org'],
      'MangaKakalot': ['mangakakalot.com'],
      'Manganelo': ['manganelo.com'],
      'ReadManga': ['readmanga.today'],
      'Generic': ['Most manga reader sites with standard URL patterns'],
    };
  }

  /// Check if URL is from a known manga site
  static bool isMangaSite(String url) {
    if (url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final domain = uri.host.toLowerCase();

    // Known manga site domains
    final mangaSites = [
      'mangadex.org',
      'mangakakalot.com',
      'manganelo.com',
      'readmanga.today',
      'mangahere.cc',
      'mangafox.me',
      'mangastream.com',
      'webtoons.com',
      'tapas.io',
    ];

    return mangaSites.any((site) => domain.contains(site)) ||
        domain.contains('manga') ||
        domain.contains('webtoon') ||
        domain.contains('comic');
  }

  /// Extract both title and chapter from URL
  static Map<String, dynamic> extractTitleAndChapter(String url) {
    return {
      'title': extractTitle(url),
      'chapter': extractChapterNumber(url),
      'isMangaSite': isMangaSite(url),
    };
  }
}
