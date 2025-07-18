import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class MangaViewerScreen extends StatefulWidget {
  const MangaViewerScreen({super.key});

  @override
  State<MangaViewerScreen> createState() => _MangaViewerScreenState();
}

class _MangaViewerScreenState extends State<MangaViewerScreen> {
  List<File> _images = [];
  int _currentPage = 0;

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Manga Chapter Folder',
    );
    if (result != null) {
      final dir = Directory(result);
      final files =
          dir
              .listSync()
              .whereType<File>()
              .where(
                (f) =>
                    f.path.toLowerCase().endsWith('.jpg') ||
                    f.path.toLowerCase().endsWith('.jpeg') ||
                    f.path.toLowerCase().endsWith('.png'),
              )
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));
      setState(() {
        _images = files;
        _currentPage = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pickFolder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Pick Folder',
            onPressed: _pickFolder,
          ),
        ],
      ),
      body: _images.isEmpty
          ? const Center(
              child: Text('No images found. Pick a folder to start.'),
            )
          : PageView.builder(
              itemCount: _images.length,
              controller: PageController(initialPage: _currentPage),
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.file(_images[index], fit: BoxFit.contain),
                );
              },
            ),
      bottomNavigationBar: _images.isNotEmpty
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Text('${_currentPage + 1} / ${_images.length}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _images.length - 1
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
