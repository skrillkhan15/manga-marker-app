import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/manga_provider.dart';
import '../models/manga.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'manga_detail_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert'; // Added for base64Decode

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedView = 'Status';
  final List<String> _viewOptions = ['Status', 'Author', 'Rating', 'Tags'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildViewSelector(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      child: Row(
        children: [
          Text('Library', style: AppTheme.getHeadlineStyle(context)),
          const Spacer(),
          Consumer<MangaProvider>(
            builder: (context, provider, child) {
              return Text(
                '${provider.mangaList.length} manga',
                style: AppTheme.getBodyStyle(context).copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.mdSpacing),
      child: Row(
        children: _viewOptions.map((option) {
          final isSelected = _selectedView == option;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedView = option;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  foregroundColor: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  elevation: isSelected ? 2 : 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final mangaList = provider.mangaList;

        if (mangaList.isEmpty) {
          return _buildEmptyState();
        }

        switch (_selectedView) {
          case 'Status':
            return _buildStatusView(mangaList);
          case 'Author':
            return _buildAuthorView(mangaList);
          case 'Rating':
            return _buildRatingView(mangaList);
          case 'Tags':
            return _buildTagsView(mangaList);
          default:
            return _buildStatusView(mangaList);
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 64,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'No manga in library',
            style: AppTheme.getHeadlineStyle(context).copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          Text(
            'Add some manga to see them organized here',
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

  Widget _buildStatusView(List<Manga> mangaList) {
    final statusGroups = <String, List<Manga>>{};

    for (var status in AppConstants.mangaStatuses) {
      statusGroups[status] = mangaList
          .where((m) => m.status == status)
          .toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      itemCount: statusGroups.length,
      itemBuilder: (context, index) {
        final status = statusGroups.keys.elementAt(index);
        final mangas = statusGroups[status]!;

        if (mangas.isEmpty) return const SizedBox.shrink();

        return _buildAccordionGroup(
          title: status,
          count: mangas.length,
          children: mangas.map((manga) => _buildMangaTile(manga)).toList(),
        );
      },
    );
  }

  Widget _buildAuthorView(List<Manga> mangaList) {
    final authorGroups = <String, List<Manga>>{};

    for (var manga in mangaList) {
      final author = manga.author.isNotEmpty ? manga.author : 'Unknown Author';
      if (!authorGroups.containsKey(author)) {
        authorGroups[author] = [];
      }
      authorGroups[author]!.add(manga);
    }

    final sortedAuthors = authorGroups.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      itemCount: sortedAuthors.length,
      itemBuilder: (context, index) {
        final author = sortedAuthors[index];
        final mangas = authorGroups[author]!;

        return _buildAccordionGroup(
          title: author,
          count: mangas.length,
          children: mangas.map((manga) => _buildMangaTile(manga)).toList(),
        );
      },
    );
  }

  Widget _buildRatingView(List<Manga> mangaList) {
    final ratingGroups = <int, List<Manga>>{};

    for (var i = 5; i >= 1; i--) {
      ratingGroups[i] = mangaList.where((m) => m.rating == i).toList();
    }

    // Add unrated manga
    ratingGroups[0] = mangaList.where((m) => m.rating == 0).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      itemCount: ratingGroups.length,
      itemBuilder: (context, index) {
        final rating = ratingGroups.keys.elementAt(index);
        final mangas = ratingGroups[rating]!;

        if (mangas.isEmpty) return const SizedBox.shrink();

        final title = rating == 0 ? 'Unrated' : '$rating Stars';

        return _buildAccordionGroup(
          title: title,
          count: mangas.length,
          children: mangas.map((manga) => _buildMangaTile(manga)).toList(),
        );
      },
    );
  }

  Widget _buildTagsView(List<Manga> mangaList) {
    final tagGroups = <String, List<Manga>>{};

    for (var manga in mangaList) {
      for (var tag in manga.tags) {
        if (!tagGroups.containsKey(tag)) {
          tagGroups[tag] = [];
        }
        tagGroups[tag]!.add(manga);
      }
    }

    final sortedTags = tagGroups.keys.toList()..sort();

    if (sortedTags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tag,
              size: 64,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppConstants.mdSpacing),
            Text(
              'No tags found',
              style: AppTheme.getHeadlineStyle(context).copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppConstants.smSpacing),
            Text(
              'Add tags to your manga to organize them here',
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

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      itemCount: sortedTags.length,
      itemBuilder: (context, index) {
        final tag = sortedTags[index];
        final mangas = tagGroups[tag]!;

        return _buildAccordionGroup(
          title: '#$tag',
          count: mangas.length,
          children: mangas.map((manga) => _buildMangaTile(manga)).toList(),
        );
      },
    );
  }

  Widget _buildAccordionGroup({
    required String title,
    required int count,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.mdSpacing),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTheme.getHeadlineStyle(
                  context,
                ).copyWith(fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        children: children,
      ),
    );
  }

  Widget _buildMangaTile(Manga manga) {
    return ListTile(
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
          if (manga.isBookmarked)
            const Icon(Icons.bookmark, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
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
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MangaDetailScreen(manga: manga),
          ),
        );
      },
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
