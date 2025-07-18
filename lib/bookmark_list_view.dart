import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:manga_marker/models.dart';
import 'package:manga_marker/bookmark_edit_screen.dart';
import 'package:manga_marker/bookmark_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class BookmarkListView extends StatefulWidget {
  final List<Bookmark> bookmarks;
  const BookmarkListView({super.key, required this.bookmarks});

  @override
  State<BookmarkListView> createState() => _BookmarkListViewState();
}

class _BookmarkListViewState extends State<BookmarkListView> {
  bool _multiSelectMode = false;
  final Set<String> _selectedIds = {};

  void _toggleMultiSelect() {
    setState(() {
      _multiSelectMode = !_multiSelectMode;
      if (!_multiSelectMode) _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _deleteSelected(BuildContext context) async {
    final provider = Provider.of<BookmarkProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookmarks'),
        content: Text(
          'Delete ${_selectedIds.length} selected bookmarks? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      for (final id in _selectedIds) {
        provider.deleteBookmark(id);
      }
      setState(() {
        _selectedIds.clear();
        _multiSelectMode = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted bookmarks.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = widget.bookmarks;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        if (isWideScreen) {
          // Grid View for wide screens (e.g., tablets, desktops)
          return GridView.builder(
            itemCount: bookmarks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Adjust as needed for desired grid density
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.7, // Adjust aspect ratio for cover images
            ),
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return Semantics(
                label:
                    'Bookmark: ${bookmark.title}, Chapter ${bookmark.currentChapter} of ${bookmark.totalChapters}, Status ${bookmark.status}',
                child: GestureDetector(
                  key: ValueKey(
                    bookmark.id,
                  ), // Key for ReorderableListView compatibility
                  onTap: () async {
                    final updatedBookmark = await Navigator.of(context)
                        .push<Bookmark>(
                          MaterialPageRoute(
                            builder: (context) =>
                                BookmarkEditScreen(bookmark: bookmark),
                          ),
                        );
                    if (updatedBookmark != null) {
                      Provider.of<BookmarkProvider>(
                        context,
                        listen: false,
                      ).updateBookmark(updatedBookmark);
                    }
                  },
                  onLongPress: () {
                    // Implement long press actions (e.g., delete, copy)
                    _showBookmarkActions(context, bookmark);
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: bookmark.coverImage.isNotEmpty
                              ? Semantics(
                                  label: 'Cover image for ${bookmark.title}',
                                  child: Image.memory(
                                    base64Decode(bookmark.coverImage),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.grey,
                                    semanticLabel: 'No cover image',
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            bookmark.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textScaler: MediaQuery.of(
                              context,
                            ).textScaler, // Font scaling
                          ),
                        ),
                        Text(
                          'Ch: ${bookmark.currentChapter}/${bookmark.totalChapters}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          textScaler: MediaQuery.of(context).textScaler,
                        ),
                        Text(
                          bookmark.status,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(bookmark.status),
                          ),
                          textScaler: MediaQuery.of(context).textScaler,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          // List View for narrow screens (default compact view)
          return Column(
            children: [
              if (_multiSelectMode)
                Material(
                  color: Theme.of(context).colorScheme.secondary.withAlpha(51),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Cancel',
                        onPressed: _toggleMultiSelect,
                      ),
                      Text('${_selectedIds.length} selected'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete Selected',
                        onPressed: _selectedIds.isEmpty
                            ? null
                            : () => _deleteSelected(context),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: bookmarks.length,
                  onReorder: (oldIndex, newIndex) {
                    Provider.of<BookmarkProvider>(
                      context,
                      listen: false,
                    ).reorderBookmarks(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    final selected = _selectedIds.contains(bookmark.id);
                    return Semantics(
                      label:
                          'Bookmark: ${bookmark.title}, Chapter ${bookmark.currentChapter} of ${bookmark.totalChapters}, Status ${bookmark.status}',
                      child: ListTile(
                        key: ValueKey(bookmark.id),
                        leading: _multiSelectMode
                            ? Checkbox(
                                value: selected,
                                onChanged: (_) => _toggleSelect(bookmark.id),
                              )
                            : (bookmark.coverImage.isNotEmpty
                                  ? Image.memory(
                                      base64Decode(bookmark.coverImage),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        title: Text(bookmark.title),
                        subtitle: Text(
                          '${bookmark.url} - ${bookmark.status} - ${bookmark.tags.join(', ')}\n'
                          'Ch: ${bookmark.currentChapter}/${bookmark.totalChapters} - Rating: ${bookmark.rating} - Mood: ${bookmark.mood}',
                        ),
                        onTap: _multiSelectMode
                            ? () => _toggleSelect(bookmark.id)
                            : () async {
                                final updatedBookmark =
                                    await Navigator.of(context).push<Bookmark>(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BookmarkEditScreen(
                                              bookmark: bookmark,
                                            ),
                                      ),
                                    );
                                if (updatedBookmark != null) {
                                  Provider.of<BookmarkProvider>(
                                    context,
                                    listen: false,
                                  ).updateBookmark(updatedBookmark);
                                }
                              },
                        onLongPress: _multiSelectMode
                            ? () => _toggleSelect(bookmark.id)
                            : _toggleMultiSelect,
                        trailing: !_multiSelectMode
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      _copyBookmark(
                                        context,
                                        bookmark,
                                      ); // Pass context
                                    },
                                    tooltip:
                                        'Copy Bookmark', // Accessibility: Add tooltip
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteBookmark(
                                        context,
                                        bookmark,
                                      ); // Pass context
                                    },
                                    tooltip:
                                        'Delete Bookmark', // Accessibility: Add tooltip
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // Helper method to get status color (can be moved to a utility class)
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Reading':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'On Hold':
        return Colors.orange;
      case 'Dropped':
        return Colors.red;
      case 'Plan to Read':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  // Helper method to show actions for a bookmark (for GridView long press)
  void _showBookmarkActions(BuildContext context, Bookmark bookmark) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Bookmark'),
                onTap: () async {
                  Navigator.pop(context); // Close bottom sheet
                  final updatedBookmark = await Navigator.of(context)
                      .push<Bookmark>(
                        MaterialPageRoute(
                          builder: (context) =>
                              BookmarkEditScreen(bookmark: bookmark),
                        ),
                      );
                  if (updatedBookmark != null) {
                    Provider.of<BookmarkProvider>(
                      context,
                      listen: false,
                    ).updateBookmark(updatedBookmark);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Bookmark'),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  _copyBookmark(context, bookmark);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Bookmark'),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  _deleteBookmark(context, bookmark);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method for copy bookmark (duplicated from main.dart for now)
  Future<void> _copyBookmark(BuildContext context, Bookmark bookmark) async {
    final clonedBookmark = Bookmark(
      id: const Uuid().v4(),
      title: '${bookmark.title} (Copy)',
      url: bookmark.url,
      coverImage: bookmark.coverImage,
      currentChapter: bookmark.currentChapter,
      totalChapters: bookmark.totalChapters,
      status: bookmark.status,
      tags: List.from(bookmark.tags),
      notes: bookmark.notes,
      rating: bookmark.rating,
      mood: bookmark.mood,
      collectionId: bookmark.collectionId,
      lastUpdated: DateTime.now(),
    );
    Provider.of<BookmarkProvider>(
      context,
      listen: false,
    ).addBookmark(clonedBookmark);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bookmark copied!')));
  }

  // Helper method for delete bookmark (duplicated from main.dart for now)
  Future<void> _deleteBookmark(BuildContext context, Bookmark bookmark) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this bookmark?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      Provider.of<BookmarkProvider>(
        context,
        listen: false,
      ).deleteBookmark(bookmark.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bookmark deleted!')));
    }
  }
}
