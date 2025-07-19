import 'package:flutter_test/flutter_test.dart';
import 'package:manga_marker/services/url_extraction_service.dart';

void main() {
  group('UrlExtractionService', () {
    test('extractChapterFromUrl should extract chapter number from URL', () {
      // Test various URL patterns
      expect(
        UrlExtractionService.extractChapterFromUrl(
          'https://example.com/manga/chapter-123',
        ),
        '123',
      );
      expect(
        UrlExtractionService.extractChapterFromUrl(
          'https://example.com/manga/ch123',
        ),
        '123',
      );
      expect(
        UrlExtractionService.extractChapterFromUrl(
          'https://example.com/manga/episode-456',
        ),
        '456',
      );
      expect(
        UrlExtractionService.extractChapterFromUrl(
          'https://example.com/manga/ep789',
        ),
        '789',
      );

      // Test URLs without chapter numbers
      expect(
        UrlExtractionService.extractChapterFromUrl('https://example.com/manga'),
        null,
      );
      expect(UrlExtractionService.extractChapterFromUrl(''), null);
    });

    test('extractMangaInfo should return empty map for invalid URLs', () async {
      final result = await UrlExtractionService.extractMangaInfo('invalid-url');
      expect(result, {});
    });
  });
}
