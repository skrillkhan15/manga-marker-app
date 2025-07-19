import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/manga.dart';
import '../providers/manga_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../services/url_extraction_service.dart';
import 'dart:convert'; // Added for base64Encode and base64Decode

class MangaEditScreen extends StatefulWidget {
  final Manga? manga;

  const MangaEditScreen({super.key, this.manga});

  @override
  State<MangaEditScreen> createState() => _MangaEditScreenState();
}

class _MangaEditScreenState extends State<MangaEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _artistController;
  late TextEditingController _urlController;
  late TextEditingController _sourceUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _publisherController;
  late TextEditingController _languageController;
  late TextEditingController _notesController;
  late TextEditingController _currentChapterController;
  late TextEditingController _totalChaptersController;
  late TextEditingController _yearController;
  late TextEditingController _tagsController;
  late FocusNode _tagFocusNode;

  String _selectedStatus = 'Reading';
  int _rating = 0;
  String _coverImage = '';
  bool _isBookmarked = false;
  bool _isCompleted = false;
  DateTime? _startDate;
  DateTime? _finishDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _tagFocusNode = FocusNode();
    if (widget.manga != null) {
      _loadMangaData();
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _artistController = TextEditingController();
    _urlController = TextEditingController();
    _sourceUrlController = TextEditingController();
    _descriptionController = TextEditingController();
    _publisherController = TextEditingController();
    _languageController = TextEditingController();
    _notesController = TextEditingController();
    _currentChapterController = TextEditingController();
    _totalChaptersController = TextEditingController();
    _yearController = TextEditingController();
    _tagsController = TextEditingController();
  }

  void _loadMangaData() {
    final manga = widget.manga!;
    _titleController.text = manga.title;
    _authorController.text = manga.author;
    _artistController.text = manga.artist;
    _urlController.text = manga.url;
    _sourceUrlController.text = manga.sourceUrl ?? '';
    _descriptionController.text = manga.description ?? '';
    _publisherController.text = manga.publisher ?? '';
    _languageController.text = manga.language ?? '';
    _notesController.text = manga.notes;
    _currentChapterController.text = manga.currentChapter.toString();
    _totalChaptersController.text = manga.totalChapters.toString();
    _yearController.text = manga.year?.toString() ?? '';
    _tagsController.text = manga.tags.join(', ');
    _selectedStatus = manga.status;
    _rating = manga.rating;
    _coverImage = manga.coverImage;
    _isBookmarked = manga.isBookmarked;
    _isCompleted = manga.isCompleted;
    _startDate = manga.startDate;
    _finishDate = manga.finishDate;
  }

  Future<void> _extractFromUrl(String url, {bool fetchHtml = false}) async {
    if (url.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // First try local extraction
      final mangaInfo = await UrlExtractionService.extractMangaInfo(
        url,
        fetchHtml: fetchHtml,
      );
      if (mangaInfo.isNotEmpty) {
        if (mangaInfo['title']?.isNotEmpty == true) {
          _titleController.text = mangaInfo['title'];
        }
        if (mangaInfo['author']?.isNotEmpty == true) {
          _authorController.text = mangaInfo['author'];
        }
        if (mangaInfo['description']?.isNotEmpty == true) {
          _descriptionController.text = mangaInfo['description'];
        }
        if (mangaInfo['currentChapter']?.isNotEmpty == true) {
          _currentChapterController.text = mangaInfo['currentChapter'];
        }
        if (mangaInfo['totalChapters']?.isNotEmpty == true) {
          _totalChaptersController.text = mangaInfo['totalChapters'];
        }
        if (mangaInfo['coverImage']?.isNotEmpty == true) {
          _coverImage = mangaInfo['coverImage'];
        }
      }
      // If not enough info, show option to fetch HTML
      if (!fetchHtml && (mangaInfo['title']?.isEmpty ?? true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not extract full info from URL. Try to fetch more info?',
            ),
            action: SnackBarAction(
              label: 'Try',
              onPressed: () => _extractFromUrl(url, fetchHtml: true),
            ),
          ),
        );
      }
    } catch (e) {
      // print('Error extracting from URL: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tagFocusNode.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _artistController.dispose();
    _urlController.dispose();
    _sourceUrlController.dispose();
    _descriptionController.dispose();
    _publisherController.dispose();
    _languageController.dispose();
    _notesController.dispose();
    _currentChapterController.dispose();
    _totalChaptersController.dispose();
    _yearController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        // For web, use a data URL
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        setState(() {
          _coverImage =
              'data:image/${image.name.split('.').last};base64,$base64Image';
        });
      } else {
        // For mobile/desktop, use file path
        setState(() {
          _coverImage = image.path;
        });
      }
    }
  }

  Future<void> _saveManga() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final manga = Manga(
        id: widget.manga?.id ?? _uuid.v4(),
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        artist: _artistController.text.trim(),
        coverImage: _coverImage,
        url: _urlController.text.trim(),
        currentChapter: int.tryParse(_currentChapterController.text) ?? 0,
        totalChapters: int.tryParse(_totalChaptersController.text) ?? 0,
        status: _selectedStatus,
        tags: tags,
        notes: _notesController.text.trim(),
        rating: _rating,
        isBookmarked: _isBookmarked,
        lastUpdated: DateTime.now(),
        startDate: _startDate,
        finishDate: _finishDate,
        sourceUrl: _sourceUrlController.text.trim().isEmpty
            ? null
            : _sourceUrlController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        year: int.tryParse(_yearController.text),
        publisher: _publisherController.text.trim().isEmpty
            ? null
            : _publisherController.text.trim(),
        language: _languageController.text.trim().isEmpty
            ? null
            : _languageController.text.trim(),
        isCompleted: _isCompleted,
        history: widget.manga?.history ?? [],
      );

      final provider = Provider.of<MangaProvider>(context, listen: false);

      if (widget.manga != null) {
        await provider.updateManga(manga);
      } else {
        await provider.addManga(manga);
      }

      if (mounted) {
        Navigator.of(context).pop(manga);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.manga != null
                  ? 'Manga updated successfully!'
                  : 'Manga added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      //   );
      // }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.manga != null ? 'Edit Manga' : 'Add Manga'),
        actions: [
          if (widget.manga != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.mdSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: AppConstants.lgSpacing),
                    _buildDetailsSection(),
                    const SizedBox(height: AppConstants.lgSpacing),
                    _buildProgressSection(),
                    const SizedBox(height: AppConstants.lgSpacing),
                    _buildAdditionalInfoSection(),
                    const SizedBox(height: AppConstants.xlSpacing),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    final mangaProvider = Provider.of<MangaProvider>(context, listen: false);
    final allTags = mangaProvider.allTags;
    final allAuthors = mangaProvider.mangaList
        .map((m) => m.author)
        .where((a) => a.isNotEmpty)
        .toSet()
        .toList();
    final allArtists = mangaProvider.mangaList
        .map((m) => m.artist)
        .where((a) => a.isNotEmpty)
        .toSet()
        .toList();
    final allPublishers = mangaProvider.mangaList
        .map((m) => m.publisher ?? '')
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppConstants.mdSpacing),

            // Cover Image
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _coverImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? (_coverImage.startsWith('data:image/')
                                    ? Image.memory(
                                        base64Decode(
                                          _coverImage.split(',').last,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        _coverImage,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              );
                                            },
                                      ))
                              : Image.file(
                                  File(_coverImage),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                    );
                                  },
                                ),
                        )
                      : const Icon(Icons.add_photo_alternate, size: 40),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.smSpacing),
            Center(
              child: TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Add Cover Image'),
              ),
            ),

            const SizedBox(height: AppConstants.mdSpacing),

            // Cover Image URL
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Paste Cover Image URL',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                setState(() {
                  _coverImage = value.trim();
                });
              },
            ),
            const SizedBox(height: AppConstants.smSpacing),

            // Loading indicator for URL extraction
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Extracting information from URL...'),
                  ],
                ),
              ),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.smSpacing),

            // Author with suggestions
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return allAuthors.where(
                  (a) => a.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _authorController = controller;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Author',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
              onSelected: (String selection) {
                _authorController.text = selection;
              },
            ),

            const SizedBox(height: AppConstants.smSpacing),

            // Artist with suggestions
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return allArtists.where(
                  (a) => a.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _artistController = controller;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Artist',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
              onSelected: (String selection) {
                _artistController.text = selection;
              },
            ),

            const SizedBox(height: AppConstants.smSpacing),

            // Publisher with suggestions
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return allPublishers.where(
                  (p) => p.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _publisherController = controller;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Publisher',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
              onSelected: (String selection) {
                _publisherController.text = selection;
              },
            ),

            const SizedBox(height: AppConstants.smSpacing),

            // Tag chip input with suggestions
            _buildTagChipInput(allTags),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChipInput(List<String> allTags) {
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: tags
              .map(
                (tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    final newTags = List<String>.from(tags)..remove(tag);
                    _tagsController.text = newTags.join(', ');
                    setState(() {});
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _tagsController,
          focusNode: _tagFocusNode,
          decoration: InputDecoration(
            labelText: 'Add Tag',
            border: const OutlineInputBorder(),
            suffixIcon: PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_drop_down),
              onSelected: (tag) {
                final newTags = Set<String>.from(tags)..add(tag);
                _tagsController.text = newTags.join(', ');
                setState(() {});
                _tagFocusNode.requestFocus();
              },
              itemBuilder: (context) => allTags
                  .where((t) => !tags.contains(t))
                  .map((t) => PopupMenuItem(value: t, child: Text(t)))
                  .toList(),
            ),
          ),
          onSubmitted: (value) {
            final newTags = Set<String>.from(tags)..add(value.trim());
            _tagsController.text = newTags.join(', ');
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppConstants.mdSpacing),

            // Status
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.mangaStatuses.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),

            const SizedBox(height: AppConstants.smSpacing),

            // Rating
            Row(
              children: [
                const Text('Rating: '),
                ...List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
                Text(' $_rating/5'),
              ],
            ),

            const SizedBox(height: AppConstants.smSpacing),

            // Tags
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    border: OutlineInputBorder(),
                    hintText: 'action, fantasy, romance',
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                if (_tagsController.text.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: Provider.of<MangaProvider>(context, listen: false)
                        .allTags
                        .where(
                          (tag) =>
                              tag.toLowerCase().contains(
                                _tagsController.text.toLowerCase(),
                              ) &&
                              !_tagsController.text
                                  .split(',')
                                  .map((t) => t.trim())
                                  .contains(tag),
                        )
                        .take(5)
                        .map(
                          (tag) => ActionChip(
                            label: Text(tag),
                            onPressed: () {
                              final tags = _tagsController.text
                                  .split(',')
                                  .map((t) => t.trim())
                                  .where((t) => t.isNotEmpty)
                                  .toList();
                              tags.add(tag);
                              _tagsController.text = tags.toSet().join(', ');
                              setState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),

            const SizedBox(height: AppConstants.smSpacing),

            // URL
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _extractFromUrl(_urlController.text),
                  icon: const Icon(Icons.download),
                  tooltip: 'Extract info from URL',
                ),
              ],
            ),

            const SizedBox(height: AppConstants.smSpacing),

            // Source URL
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sourceUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Source URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _extractFromUrl(_sourceUrlController.text),
                  icon: const Icon(Icons.download),
                  tooltip: 'Extract info from URL',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
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
                  child: TextFormField(
                    controller: _currentChapterController,
                    decoration: const InputDecoration(
                      labelText: 'Current Chapter',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppConstants.smSpacing),
                const Text('/'),
                const SizedBox(width: AppConstants.smSpacing),
                Expanded(
                  child: TextFormField(
                    controller: _totalChaptersController,
                    decoration: const InputDecoration(
                      labelText: 'Total Chapters',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.smSpacing),

            Row(
              children: [
                Checkbox(
                  value: _isBookmarked,
                  onChanged: (value) {
                    setState(() {
                      _isBookmarked = value ?? false;
                    });
                  },
                ),
                const Text('Bookmarked'),
                const SizedBox(width: AppConstants.lgSpacing),
                Checkbox(
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value ?? false;
                    });
                  },
                ),
                const Text('Completed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppConstants.mdSpacing),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: AppConstants.smSpacing),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Personal Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: AppConstants.smSpacing),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _publisherController,
                    decoration: const InputDecoration(
                      labelText: 'Publisher',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smSpacing),
                Expanded(
                  child: TextFormField(
                    controller: _languageController,
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.smSpacing),

            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: AppConstants.smSpacing),

            // Start Date
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Start Date: ${_startDate != null ? _startDate!.toLocal().toString().split(' ')[0] : 'Not set'}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  child: const Text('Pick'),
                ),
                if (_startDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _startDate = null),
                  ),
              ],
            ),

            // Finish Date
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Finish Date: ${_finishDate != null ? _finishDate!.toLocal().toString().split(' ')[0] : 'Not set'}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _finishDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _finishDate = picked;
                      });
                    }
                  },
                  child: const Text('Pick'),
                ),
                if (_finishDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _finishDate = null),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saveManga,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(widget.manga != null ? 'Update Manga' : 'Add Manga'),
          ),
        ),
        const SizedBox(width: AppConstants.mdSpacing),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Manga'),
        content: Text(
          'Are you sure you want to delete "${widget.manga!.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final provider = Provider.of<MangaProvider>(
                context,
                listen: false,
              );
              await provider.deleteManga(widget.manga!.id);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manga deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
