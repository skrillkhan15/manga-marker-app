import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manga_provider.dart';
import '../models/manga.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'manga_detail_screen.dart';
import 'dart:convert'; // Added for base64Decode
import 'dart:io'; // Added for File
import 'package:flutter/foundation.dart' show kIsWeb; // Added for kIsWeb
import 'package:url_launcher/url_launcher.dart'; // Added for url_launcher

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<MangaProvider>(
        builder: (context, provider, child) {
          final bookmarkedManga = provider.mangaList
              .where((m) => m.isBookmarked)
              .toList();

          return Column(
            children: [
              _buildHeader(context, bookmarkedManga.length),
              Expanded(child: _buildContent(context, bookmarkedManga)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      child: Row(
        children: [
          Text('Bookmarks', style: AppTheme.getHeadlineStyle(context)),
          const Spacer(),
          Text(
            '$count bookmarked',
            style: AppTheme.getBodyStyle(context).copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Manga> bookmarkedManga) {
    if (bookmarkedManga.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      itemCount: bookmarkedManga.length,
      itemBuilder: (context, index) {
        final manga = bookmarkedManga[index];
        return _buildMangaCard(context, manga);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark,
            size: 64,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'No bookmarks',
            style: AppTheme.getHeadlineStyle(context).copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          Text(
            'Bookmark manga to see them here',
            style: AppTheme.getBodyStyle(context).copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMangaCard(BuildContext context, Manga manga) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smSpacing),
      child: ListTile(
        leading: manga.coverImage.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? (manga.coverImage.startsWith('data:image/')
                          ? Image.memory(
                              base64Decode(manga.coverImage.split(',').last),
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              manga.coverImage,
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.book,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ))
                    : Image.file(
                        File(manga.coverImage),
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.book, color: Colors.grey),
                          );
                        },
                      ),
              )
            : Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book, color: Colors.grey),
              ),
        title: Text(
          manga.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapter ${manga.currentChapter}${manga.totalChapters > 0 ? '/${manga.totalChapters}' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            if (manga.rating > 0)
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < manga.rating ? Icons.star : Icons.star_border,
                      size: 12,
                      color: Colors.amber,
                    );
                  }),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(manga.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                manga.status,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(manga.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chrome_reader_mode, color: Colors.blue),
              tooltip: 'Read',
              onPressed: () async {
                final url = manga.sourceUrl?.isNotEmpty == true
                    ? manga.sourceUrl
                    : manga.url;
                if (url != null && url.isNotEmpty) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open URL'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No URL available for this manga'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const Icon(Icons.bookmark, color: Colors.amber, size: 20),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MangaDetailScreen(manga: manga),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Reading':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'On-hold':
        return Colors.orange;
      case 'Dropped':
        return Colors.red;
      case 'Plan to Read':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
