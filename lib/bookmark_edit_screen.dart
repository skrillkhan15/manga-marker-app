import 'dart:convert';
import 'dart:io';
import 'dart:async'; // Import for Timer

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manga_marker/models.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:manga_marker/database_helper.dart';

class BookmarkEditScreen extends StatefulWidget {
  final Bookmark? bookmark;

  const BookmarkEditScreen({super.key, this.bookmark});

  @override
  _BookmarkEditScreenState createState() => _BookmarkEditScreenState();
}

class _BookmarkEditScreenState extends State<BookmarkEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _url;
  late String _coverImage;
  late String _status;
  late List<String> _tags;
  late int _currentChapter;
  late int _totalChapters;
  late String _notes;
  late int _rating;
  late String _mood;
  late String _collectionId;
  late int _readingDuration; // New state variable for reading duration
  String? _parentCollectionId; // New state variable for parent collection
  List<Bookmark> _possibleParentCollections = []; // To store potential parent bookmarks

  // Timer variables
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _title = widget.bookmark?.title ?? '';
    _url = widget.bookmark?.url ?? '';
    _coverImage = widget.bookmark?.coverImage ?? '';
    _status = widget.bookmark?.status ?? 'Reading';
    _tags = widget.bookmark?.tags ?? [];
    _currentChapter = widget.bookmark?.currentChapter ?? 0;
    _totalChapters = widget.bookmark?.totalChapters ?? 0;
    _notes = widget.bookmark?.notes ?? '';
    _rating = widget.bookmark?.rating ?? 0;
    _mood = widget.bookmark?.mood ?? '';
    _collectionId = widget.bookmark?.collectionId ?? '';
    _readingDuration = 0; // Initialize reading duration
    _parentCollectionId = widget.bookmark?.parentId; // Initialize from existing bookmark

    _loadPossibleParentCollections();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startTimer() {
    if (!_isTimerRunning) {
      _isTimerRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
        });
      });
    }
  }

  void _stopTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() {
        _isTimerRunning = false;
        _readingDuration = _elapsedSeconds ~/ 60; // Convert to minutes
      });
    }
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _elapsedSeconds = 0;
      _readingDuration = 0;
    });
  }

  Future<void> _loadPossibleParentCollections() async {
    final dbHelper = DatabaseHelper();
    final allBookmarks = await dbHelper.getBookmarks();
    setState(() {
      // Filter out the current bookmark itself to prevent self-nesting
      _possibleParentCollections = allBookmarks.where((b) => b.id != widget.bookmark?.id).toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _coverImage = base64Encode(bytes);
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newBookmark = Bookmark(
        id: widget.bookmark?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _title,
        url: _url,
        coverImage: _coverImage,
        status: _status,
        tags: _tags,
        currentChapter: _currentChapter,
        totalChapters: _totalChapters,
        notes: _notes,
        rating: _rating,
        mood: _mood,
        collectionId: _collectionId,
        parentId: _parentCollectionId, // Save the parentId
        lastUpdated: DateTime.now(),
        history: widget.bookmark?.history ?? [],
      );

      // Add to history if currentChapter has increased
      if (widget.bookmark != null && _currentChapter > widget.bookmark!.currentChapter) {
        newBookmark.history.add({
          'chapter': _currentChapter,
          'timestamp': DateTime.now().toIso8601String(),
          'duration': _readingDuration, // Include duration
        });

        // Update reading goals
        final goals = await DatabaseHelper().getReadingGoals();
        final chaptersRead = _currentChapter - widget.bookmark!.currentChapter;
        final minutesRead = _readingDuration;

        for (var goal in goals) {
          if (DateTime.now().isAfter(goal.startDate) && DateTime.now().isBefore(goal.endDate)) {
            if (goal.type == 'Chapters') {
              goal.currentValue += chaptersRead;
            } else if (goal.type == 'Minutes') {
              goal.currentValue += minutesRead;
            } else if (goal.type == 'Manga' && newBookmark.status == 'Completed' && widget.bookmark?.status != 'Completed') {
              goal.currentValue += 1;
            }
            await DatabaseHelper().updateReadingGoal(goal);
          }
        }
      }

      Navigator.of(context).pop(newBookmark);
    }
  }

  void _undoChanges() {
    if (widget.bookmark != null && widget.bookmark!.history.isNotEmpty) {
      setState(() {
        final previousState = widget.bookmark!.history.removeLast();
        _title = previousState['title'] ?? '';
        _url = previousState['url'] ?? '';
        _coverImage = previousState['coverImage'] ?? '';
        _status = previousState['status'] ?? 'Reading';
        _tags = List<String>.from(previousState['tags'] ?? []);
        _currentChapter = previousState['currentChapter'] ?? 0;
        _totalChapters = previousState['totalChapters'] ?? 0;
        _notes = previousState['notes'] ?? '';
        _rating = previousState['rating'] ?? 0;
        _mood = previousState['mood'] ?? '';
        _collectionId = previousState['collectionId'] ?? '';
        _parentCollectionId = previousState['parentId']; // Restore parentId
      });
    }
  }

  Future<void> _showQrCode() async {
    final dbHelper = DatabaseHelper();
    final newBookmark = Bookmark(
      id: widget.bookmark?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title,
      url: _url,
      coverImage: _coverImage,
      status: _status,
      tags: _tags,
      currentChapter: _currentChapter,
      totalChapters: _totalChapters,
      notes: _notes,
      rating: _rating,
      mood: _mood,
      collectionId: _collectionId,
      parentId: _parentCollectionId, // Include parentId in QR code data
      lastUpdated: DateTime.now(),
      history: widget.bookmark?.history ?? [],
    );
    final qrData = await dbHelper.exportBookmarkAsQrCode(jsonEncode(newBookmark.toJson()));
    if (qrData != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bookmark QR Code'),
          content: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 200.0,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookmark == null ? 'Add Bookmark' : 'Edit Bookmark'),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code), onPressed: _showQrCode),
          IconButton(icon: const Icon(Icons.undo), onPressed: _undoChanges),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_coverImage.isNotEmpty)
                Image.memory(base64Decode(_coverImage), height: 150),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Select Cover Image'),
                onPressed: _pickImage,
              ),
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _url,
                decoration: const InputDecoration(labelText: 'URL'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a URL'
                    : null,
                onSaved: (value) => _url = value!,
                onChanged: (value) {
                  _url = value;
                  final detectedChapter = DatabaseHelper().extractChapterNumberFromUrl(value);
                  if (detectedChapter != null) {
                    setState(() {
                      _currentChapter = detectedChapter;
                    });
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _currentChapter.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Current Chapter',
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) =>
                          _currentChapter = int.tryParse(value ?? '0') ?? 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: _totalChapters.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Total Chapters',
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) =>
                          _totalChapters = int.tryParse(value ?? '0') ?? 0,
                    ),
                  ),
                ],
              ),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
                onSaved: (value) => _notes = value!,
              ),
              TextFormField(
                initialValue: _rating.toString(),
                decoration: const InputDecoration(labelText: 'Rating (1–5)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _rating = int.tryParse(value ?? '0') ?? 0;
                  if (_rating < 0) _rating = 0;
                  if (_rating > 5) _rating = 5;
                },
              ),
              TextFormField(
                initialValue: _mood,
                decoration: const InputDecoration(
                  labelText: 'Mood / Emoji Tags',
                ),
                onSaved: (value) => _mood = value!,
              ),
              TextFormField(
                initialValue: _collectionId,
                decoration: const InputDecoration(
                  labelText: 'Collection / Folder',
                ),
                onSaved: (value) => _collectionId = value!,
              ),
              TextFormField(
                initialValue: _readingDuration.toString(),
                decoration: const InputDecoration(
                  labelText: 'Reading Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _readingDuration = int.tryParse(value ?? '0') ?? 0,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isTimerRunning ? _stopTimer : _startTimer,
                    child: Text(_isTimerRunning ? 'Stop Timer' : 'Start Timer'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _resetTimer,
                    child: const Text('Reset Timer'),
                  ),
                ],
              ),
              Text('Elapsed Time: ${_elapsedSeconds ~/ 60}m ${_elapsedSeconds % 60}s'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _parentCollectionId,
                decoration: const InputDecoration(labelText: 'Parent Collection'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('None (Top Level)'),
                  ),
                  ..._possibleParentCollections.map((bookmark) {
                    return DropdownMenuItem<String>(
                      value: bookmark.id,
                      child: Text(bookmark.title),
                    );
                  }).toList(),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _parentCollectionId = newValue;
                  });
                },
                onSaved: (value) => _parentCollectionId = value,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items:
                    <String>[
                      'Reading',
                      'Completed',
                      'On Hold',
                      'Dropped',
                      'Plan to Read',
                    ].map((String value) {
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
                initialValue: _tags.join(', '),
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                ),
                onSaved: (value) {
                  _tags = value!
                      .split(',')
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .toList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}