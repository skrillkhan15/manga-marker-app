import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:manga_marker/models.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:xml/xml.dart';

class AniListMalImportExportScreen extends StatefulWidget {
  const AniListMalImportExportScreen({super.key});

  @override
  State<AniListMalImportExportScreen> createState() =>
      _AniListMalImportExportScreenState();
}

class _AniListMalImportExportScreenState
    extends State<AniListMalImportExportScreen> {
  String? _status;

  Future<void> _importFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml', 'csv', 'json'],
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      try {
        if (path.endsWith('.xml')) {
          await _importFromXml(path);
        } else if (path.endsWith('.csv')) {
          await _importFromCsv(path);
        } else if (path.endsWith('.json')) {
          await _importFromJson(path);
        }
        setState(() => _status = 'Import successful!');
      } catch (e) {
        setState(() => _status = 'Import failed: $e');
      }
    }
  }

  Future<void> _importFromXml(String path) async {
    final xmlString = await File(path).readAsString();
    final document = XmlDocument.parse(xmlString);
    final entries = document.findAllElements('manga');
    final bookmarks = entries.map((node) {
      return Bookmark(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: node.getElement('series_title')?.value ?? '',
        url: '',
        coverImage: '',
        currentChapter:
            int.tryParse(node.getElement('my_read_chapters')?.value ?? '0') ??
            0,
        totalChapters:
            int.tryParse(node.getElement('series_chapters')?.value ?? '0') ?? 0,
        status: node.getElement('my_status')?.value ?? 'Reading',
        tags: [],
        notes: '',
        rating: int.tryParse(node.getElement('my_score')?.value ?? '0') ?? 0,
        mood: '',
        collectionId: '',
        lastUpdated: DateTime.now(),
        history: [],
      );
    }).toList();
    await DatabaseHelper().saveBookmarks(bookmarks);
  }

  Future<void> _importFromCsv(String path) async {
    final lines = await File(path).readAsLines();
    final bookmarks = <Bookmark>[];
    for (var line in lines.skip(1)) {
      final fields = line.split(',');
      if (fields.length < 5) continue;
      bookmarks.add(
        Bookmark(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: fields[0],
          url: '',
          coverImage: '',
          currentChapter: int.tryParse(fields[1]) ?? 0,
          totalChapters: int.tryParse(fields[2]) ?? 0,
          status: fields[3],
          tags: [],
          notes: '',
          rating: int.tryParse(fields[4]) ?? 0,
          mood: '',
          collectionId: '',
          lastUpdated: DateTime.now(),
          history: [],
        ),
      );
    }
    await DatabaseHelper().saveBookmarks(bookmarks);
  }

  Future<void> _importFromJson(String path) async {
    // TODO: Implement JSON import logic if needed
  }

  Future<void> _exportToXml() async {
    // Export bookmarks to MAL/AniList XML format
    final bookmarks = await DatabaseHelper().getBookmarks();
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(
      'myanimelist',
      nest: () {
        builder.element(
          'manga',
          nest: () {
            for (final b in bookmarks) {
              builder.element('series_title', nest: b.title);
              builder.element(
                'my_read_chapters',
                nest: b.currentChapter.toString(),
              );
              builder.element(
                'series_chapters',
                nest: b.totalChapters.toString(),
              );
              builder.element('my_status', nest: b.status);
              builder.element('my_score', nest: b.rating.toString());
            }
          },
        );
      },
    );
    final xmlString = builder.buildDocument().toXmlString(pretty: true);
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Export as XML',
      fileName: 'manga_marker_export.xml',
      allowedExtensions: ['xml'],
      type: FileType.custom,
    );
    if (result != null) {
      await File(result).writeAsString(xmlString);
      setState(() => _status = 'Export successful!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AniList/MyAnimeList Import/Export')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload),
              label: const Text('Import from File (.xml, .csv, .json)'),
              onPressed: _importFile,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.file_download),
              label: const Text('Export as MAL/AniList XML'),
              onPressed: _exportToXml,
            ),
            const SizedBox(height: 24),
            if (_status != null)
              Text(
                _status!,
                style: TextStyle(
                  color: _status!.contains('failed')
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            const SizedBox(height: 24),
            const Text('• Import/export is fully offline and file-based.'),
            const Text(
              '• For AniList/MyAnimeList, export your list from their website and import here.',
            ),
            const Text(
              '• Exported files can be imported into those services manually.',
            ),
          ],
        ),
      ),
    );
  }
}
