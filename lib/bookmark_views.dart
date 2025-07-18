import 'package:flutter/material.dart';
import 'package:manga_marker/models.dart';

class CompactBookmarkListItem extends StatelessWidget {
  final Bookmark bookmark;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CompactBookmarkListItem({
    super.key,
    required this.bookmark,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8.0 : 2.0,
      color: isSelected
          ? Theme.of(context).primaryColor.withAlpha((0.5 * 255).toInt())
          : null,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(child: Text(bookmark.title[0])),
        title: Text(bookmark.title),
        subtitle: Text('Chapter:  [bookmark.currentChapter]'),
        trailing: Icon(Icons.drag_handle),
      ),
    );
  }
}

class ExpandedBookmarkListItem extends StatelessWidget {
  final Bookmark bookmark;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ExpandedBookmarkListItem({
    super.key,
    required this.bookmark,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8.0 : 2.0,
      color: isSelected
          ? Theme.of(context).primaryColor.withAlpha((0.5 * 255).toInt())
          : null,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: AspectRatio(
          aspectRatio: 2 / 3,
          child: Container(
            color: Colors.grey[300],
            child: Center(
              child: Icon(Icons.image),
            ), // Placeholder for cover image
          ),
        ),
        title: Text(
          bookmark.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chapter:  [bookmark.currentChapter]'),
            // Removed 'Last Read' as it's not in the Bookmark model
            if (bookmark.tags.isNotEmpty)
              Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: bookmark.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
          ],
        ),
        trailing: Icon(Icons.drag_handle),
      ),
    );
  }
}

class CardStackBookmarkItem extends StatelessWidget {
  final Bookmark bookmark;

  const CardStackBookmarkItem({super.key, required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              bookmark.title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text('Chapter:  [bookmark.currentChapter]'),
          ],
        ),
      ),
    );
  }
}

class CoverWallBookmarkItem extends StatelessWidget {
  final Bookmark bookmark;

  const CoverWallBookmarkItem({super.key, required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          title: Text(bookmark.title, textAlign: TextAlign.center),
        ),
        child: Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(Icons.image, size: 50),
          ), // Placeholder for cover image
        ),
      ),
    );
  }
}
