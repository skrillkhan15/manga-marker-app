import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'manga_edit_screen.dart';

class MangaDetailScreen extends StatelessWidget {
  final Manga manga;

  const MangaDetailScreen({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(manga.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).push<Manga>(
                MaterialPageRoute(
                  builder: (context) => MangaEditScreen(manga: manga),
                ),
              );
              if (result != null) {
                Navigator.of(context).pop(result);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppConstants.lgSpacing),
            _buildInfoSection(context),
            const SizedBox(height: AppConstants.lgSpacing),
            _buildProgressSection(context),
            const SizedBox(height: AppConstants.lgSpacing),
            _buildTagsSection(context),
            const SizedBox(height: AppConstants.lgSpacing),
            _buildNotesSection(context),
            const SizedBox(height: AppConstants.lgSpacing),
            _buildHistorySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Image
        Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[300],
          ),
          child: manga.coverImage.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    manga.coverImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.book, size: 40);
                    },
                  ),
                )
              : const Icon(Icons.book, size: 40),
        ),
        const SizedBox(width: AppConstants.mdSpacing),

        // Title and basic info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                manga.title,
                style: AppTheme.getHeadlineStyle(
                  context,
                ).copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppConstants.smSpacing),
              if (manga.author.isNotEmpty)
                Text(
                  'Author: ${manga.author}',
                  style: AppTheme.getBodyStyle(context),
                ),
              if (manga.artist.isNotEmpty)
                Text(
                  'Artist: ${manga.artist}',
                  style: AppTheme.getBodyStyle(context),
                ),
              const SizedBox(height: AppConstants.smSpacing),

              // Rating
              if (manga.rating > 0)
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < manga.rating ? Icons.star : Icons.star_border,
                        size: 20,
                        color: Colors.amber,
                      );
                    }),
                    const SizedBox(width: 8),
                    Text('${manga.rating}/5'),
                  ],
                ),

              const SizedBox(height: AppConstants.smSpacing),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(manga.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  manga.status,
                  style: TextStyle(
                    color: _getStatusColor(manga.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Information',
              style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppConstants.mdSpacing),

            if (manga.publisher?.isNotEmpty == true)
              _buildInfoRow('Publisher', manga.publisher!),
            if (manga.language?.isNotEmpty == true)
              _buildInfoRow('Language', manga.language!),
            if (manga.year != null)
              _buildInfoRow('Year', manga.year.toString()),
            if (manga.url.isNotEmpty)
              _buildInfoRow('URL', manga.url, isUrl: true),
            if (manga.sourceUrl?.isNotEmpty == true)
              _buildInfoRow('Source URL', manga.sourceUrl!, isUrl: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress',
              style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppConstants.mdSpacing),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Chapter',
                        style: AppTheme.getBodyStyle(context).copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '${manga.currentChapter}',
                        style: AppTheme.getHeadlineStyle(
                          context,
                        ).copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                ),
                const Text('/', style: TextStyle(fontSize: 24)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Chapters',
                        style: AppTheme.getBodyStyle(context).copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        manga.totalChapters > 0
                            ? '${manga.totalChapters}'
                            : '?',
                        style: AppTheme.getHeadlineStyle(
                          context,
                        ).copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (manga.totalChapters > 0) ...[
              const SizedBox(height: AppConstants.mdSpacing),
              LinearProgressIndicator(
                value: manga.currentChapter / manga.totalChapters,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: AppConstants.smSpacing),
              Text(
                '${((manga.currentChapter / manga.totalChapters) * 100).toStringAsFixed(1)}% Complete',
                style: AppTheme.getBodyStyle(context).copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    if (manga.tags.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppConstants.mdSpacing),
            Wrap(
              spacing: AppConstants.smSpacing,
              runSpacing: AppConstants.smSpacing,
              children: manga.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    if (manga.notes.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppConstants.mdSpacing),
            Text(manga.notes, style: AppTheme.getBodyStyle(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    if (manga.history.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading History',
              style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppConstants.mdSpacing),
            ...manga.history.take(5).map((session) {
              final date = DateTime.parse(session['date']);
              final chaptersRead = session['chaptersRead'] as int;
              final duration = session['duration'] as int;

              return ListTile(
                leading: const Icon(Icons.history),
                title: Text('Read $chaptersRead chapters'),
                subtitle: Text('${_formatDate(date)} • $duration minutes'),
                dense: true,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: isUrl
                ? SelectableText(
                    value,
                    style: const TextStyle(color: Colors.blue),
                  )
                : Text(value),
          ),
        ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
