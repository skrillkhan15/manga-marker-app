import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/manga_provider.dart';
import '../models/manga.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'manga_detail_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final TextEditingController _tagController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTagDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      child: Row(
        children: [
          Text('Tags', style: AppTheme.getHeadlineStyle(context)),
          const Spacer(),
          Consumer<MangaProvider>(
            builder: (context, provider, child) {
              final allTags = _getAllTags(provider.mangaList);
              return Text(
                '${allTags.length} tags',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.mdSpacing),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search tags...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final allTags = _getAllTags(provider.mangaList);
        final filteredTags = allTags.where((tag) {
          return tag.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredTags.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.mdSpacing),
          itemCount: filteredTags.length,
          itemBuilder: (context, index) {
            final tag = filteredTags[index];
            final mangaWithTag = _getMangaWithTag(provider.mangaList, tag);

            return _buildTagCard(tag, mangaWithTag);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
            _searchQuery.isEmpty
                ? 'No tags found'
                : 'No tags match your search',
            style: AppTheme.getHeadlineStyle(context).copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          Text(
            _searchQuery.isEmpty
                ? 'Add tags to your manga to organize them here'
                : 'Try a different search term',
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

  Widget _buildTagCard(String tag, List<Manga> mangaWithTag) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smSpacing),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.smSpacing),
            Expanded(
              child: Text(
                '${mangaWithTag.length} manga',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditTagDialog(context, tag);
                break;
              case 'delete':
                _showDeleteTagDialog(context, tag);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        children: mangaWithTag.map((manga) => _buildMangaTile(manga)).toList(),
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
      trailing: Container(
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MangaDetailScreen(manga: manga),
          ),
        );
      },
    );
  }

  void _showAddTagDialog(BuildContext context) {
    _tagController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Tag'),
        content: TextField(
          controller: _tagController,
          decoration: const InputDecoration(
            labelText: 'Tag Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tagName = _tagController.text.trim();
              if (tagName.isNotEmpty) {
                Provider.of<MangaProvider>(
                  context,
                  listen: false,
                ).createTag(tagName);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tag "$tagName" created'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTagDialog(BuildContext context, String currentTag) {
    _tagController.text = currentTag;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tag'),
        content: TextField(
          controller: _tagController,
          decoration: const InputDecoration(
            labelText: 'Tag Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTagName = _tagController.text.trim();
              if (newTagName.isNotEmpty && newTagName != currentTag) {
                Provider.of<MangaProvider>(
                  context,
                  listen: false,
                ).updateTag(currentTag, newTagName);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tag renamed to "$newTagName"'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTagDialog(BuildContext context, String tag) {
    final mangaWithTag = _getMangaWithTag(
      Provider.of<MangaProvider>(context, listen: false).mangaList,
      tag,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text(
          'Are you sure you want to delete the tag "$tag"?\n\n'
          'This will remove the tag from ${mangaWithTag.length} manga.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<MangaProvider>(context, listen: false).deleteTag(tag);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tag "$tag" deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<String> _getAllTags(List<Manga> mangaList) {
    final tagSet = <String>{};
    for (var manga in mangaList) {
      tagSet.addAll(manga.tags);
    }
    return tagSet.toList()..sort();
  }

  List<Manga> _getMangaWithTag(List<Manga> mangaList, String tag) {
    return mangaList.where((manga) => manga.tags.contains(tag)).toList();
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
