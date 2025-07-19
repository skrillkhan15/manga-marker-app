import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manga_provider.dart';
import '../models/manga.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'dart:convert'; // Added for base64Decode
import 'dart:io'; // Added for File
import 'package:flutter/foundation.dart' show kIsWeb; // Added for kIsWeb

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final unfinished = provider.mangaList
            .where(
              (m) =>
                  m.status == 'Reading' && m.currentChapter < m.totalChapters,
            )
            .toList();
        final highRated = provider.mangaList
            .where((m) => m.rating >= 8)
            .toList();
        final planToRead = provider.mangaList
            .where((m) => m.status == 'Plan to Read')
            .toList();
        final today = DateTime.now();
        final onThisDay = provider.mangaList
            .where(
              (m) => m.history.any((h) {
                final d = DateTime.parse(h['date']);
                return d.month == today.month &&
                    d.day == today.day &&
                    d.year != today.year;
              }),
            )
            .toList();
        // Trending Tags: top 5 tags by usage
        final tagUsage = provider.tagUsage;
        final trendingTags = tagUsage.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final trendingTagNames = trendingTags
            .take(5)
            .map((e) => e.key)
            .toList();
        final trendingTagManga = provider.mangaList
            .where((m) => m.tags.any((t) => trendingTagNames.contains(t)))
            .toList();
        // Recently Added: last 5 manga by lastUpdated
        final recentlyAdded = List<Manga>.from(provider.mangaList)
          ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
        // Most Read: top 5 by currentChapter
        final mostRead = List<Manga>.from(provider.mangaList)
          ..sort((a, b) => b.currentChapter.compareTo(a.currentChapter));
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(title: const Text('Discover')),
          body: ListView(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            children: [
              _buildSection('Continue Reading', unfinished, context),
              _buildSection('High-Rated Manga', highRated, context),
              _buildSection('Plan to Read', planToRead, context),
              _buildSection('On This Day', onThisDay, context),
              _buildSection('Trending Tags', trendingTagManga, context),
              _buildSection(
                'Recently Added',
                recentlyAdded.take(5).toList(),
                context,
              ),
              _buildSection('Most Read', mostRead.take(5).toList(), context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    String title,
    List<Manga> mangaList,
    BuildContext context,
  ) {
    if (mangaList.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 20),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: mangaList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final manga = mangaList[i];
              return Card(
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: manga.coverImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb
                                    ? (manga.coverImage.startsWith(
                                            'data:image/',
                                          )
                                          ? Image.memory(
                                              base64Decode(
                                                manga.coverImage
                                                    .split(',')
                                                    .last,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              manga.coverImage,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return const Icon(
                                                      Icons.book,
                                                      size: 60,
                                                    );
                                                  },
                                            ))
                                    : Image.file(
                                        File(manga.coverImage),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.book,
                                                size: 60,
                                              );
                                            },
                                      ),
                              )
                            : const Icon(Icons.book, size: 60),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        manga.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.getBodyStyle(context),
                      ),
                      if (title == 'High-Rated Manga')
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Text(
                              '${manga.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      if (title == 'Continue Reading')
                        Text(
                          'Ch. ${manga.currentChapter}/${manga.totalChapters}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.lgSpacing),
      ],
    );
  }
}
