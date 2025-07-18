import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfCbzViewerScreen extends StatefulWidget {
  const PdfCbzViewerScreen({super.key});

  @override
  State<PdfCbzViewerScreen> createState() => _PdfCbzViewerScreenState();
}

class _PdfCbzViewerScreenState extends State<PdfCbzViewerScreen> {
  String? _filePath;
  List<File>? _cbzImages;
  int _currentPage = 0;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'cbz'],
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      if (path.toLowerCase().endsWith('.cbz')) {
        await _extractCbzImages(path);
      } else {
        setState(() {
          _filePath = path;
          _cbzImages = null;
        });
      }
    }
  }

  Future<void> _extractCbzImages(String cbzPath) async {
    final tempDir = await Directory.systemTemp.createTemp('cbz_extract');
    final bytes = await File(cbzPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final imageFiles = <File>[];
    for (final file in archive) {
      if (!file.isFile) continue;
      final name = file.name.toLowerCase();
      if (name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.png')) {
        final outPath = '${tempDir.path}/${file.name.split('/').last}';
        await File(outPath).writeAsBytes(file.content as List<int>);
        imageFiles.add(File(outPath));
      }
    }
    imageFiles.sort((a, b) => a.path.compareTo(b.path));
    setState(() {
      _filePath = cbzPath;
      _cbzImages = imageFiles;
      _currentPage = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _pickFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF/CBZ Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Pick File',
            onPressed: _pickFile,
          ),
        ],
      ),
      body: _cbzImages != null
          ? (_cbzImages!.isEmpty
                ? const Center(child: Text('No images found in CBZ.'))
                : PageView.builder(
                    itemCount: _cbzImages!.length,
                    controller: PageController(initialPage: _currentPage),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Image.file(
                          _cbzImages![index],
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ))
          : (_filePath != null && _filePath!.toLowerCase().endsWith('.pdf'))
          ? SfPdfViewer.file(File(_filePath!))
          : const Center(child: Text('Pick a PDF or CBZ file to start.')),
      bottomNavigationBar: _cbzImages != null && _cbzImages!.isNotEmpty
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
                  Text('${_currentPage + 1} / ${_cbzImages!.length}'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _cbzImages!.length - 1
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
