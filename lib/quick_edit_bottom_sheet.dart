import 'package:flutter/material.dart';
import 'package:manga_marker/models.dart';

class QuickEditBottomSheet extends StatefulWidget {
  final Bookmark bookmark;

  const QuickEditBottomSheet({super.key, required this.bookmark});

  @override
  State<QuickEditBottomSheet> createState() => _QuickEditBottomSheetState();
}

class _QuickEditBottomSheetState extends State<QuickEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late int _currentChapter;
  late String _status;
  late String _notes;

  @override
  void initState() {
    super.initState();
    _title = widget.bookmark.title;
    _currentChapter = widget.bookmark.currentChapter;
    _status = widget.bookmark.status;
    _notes = widget.bookmark.notes;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quick Edit: ${widget.bookmark.title}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16.0),
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              onSaved: (value) => _title = value!,
            ),
            TextFormField(
              initialValue: _currentChapter.toString(),
              decoration: const InputDecoration(labelText: 'Current Chapter'),
              keyboardType: TextInputType.number,
              onSaved: (value) => _currentChapter = int.tryParse(value!) ?? _currentChapter,
            ),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items:
                  <String>['Reading', 'Completed', 'On Hold', 'Dropped', 'Plan to Read']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              onSaved: (value) => _status = value!,
            ),
            TextFormField(
              initialValue: _notes,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
              onSaved: (value) => _notes = value!,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final updatedBookmark = widget.bookmark
                    ..title = _title
                    ..currentChapter = _currentChapter
                    ..status = _status
                    ..notes = _notes
                    ..lastUpdated = DateTime.now();
                  Navigator.of(context).pop(updatedBookmark);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
