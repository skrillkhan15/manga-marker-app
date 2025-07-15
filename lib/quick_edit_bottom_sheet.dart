import 'package:flutter/material.dart';
import 'package:manga_marker/models.dart';

class QuickEditBottomSheet extends StatefulWidget {
  final Bookmark bookmark;

  const QuickEditBottomSheet({super.key, required this.bookmark});

  @override
  State<QuickEditBottomSheet> createState() => _QuickEditBottomSheetState();
}

class _QuickEditBottomSheetState extends State<QuickEditBottomSheet> {
  late int _currentChapter;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.bookmark.currentChapter;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Quick Edit: ${widget.bookmark.title}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16.0),
          TextFormField(
            initialValue: _currentChapter.toString(),
            decoration: const InputDecoration(labelText: 'Current Chapter'),
            keyboardType: TextInputType.number,
            onChanged: (value) => _currentChapter = int.tryParse(value) ?? _currentChapter,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              final updatedBookmark = widget.bookmark
                ..currentChapter = _currentChapter
                ..lastUpdated = DateTime.now();
              Navigator.of(context).pop(updatedBookmark);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
