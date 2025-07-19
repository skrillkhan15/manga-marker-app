import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manga_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../models/manga.dart';
import '../widgets/multi_action_fab.dart';
import '../export_service.dart';
import 'manga_edit_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile_provider.dart';

class MyMangaScreen extends StatefulWidget {
  const MyMangaScreen({super.key});

  @override
  State<MyMangaScreen> createState() => _MyMangaScreenState();
}

class _MyMangaScreenState extends State<MyMangaScreen>
    with AutomaticKeepAliveClientMixin {
  final Set<String> _selectedMangaIds = {};
  bool get _isBulkMode => _selectedMangaIds.isNotEmpty;
  Manga? _lastDeletedManga;
  List<Manga>? _lastBulkDeletedManga;

  @override
  @mustCallSuper
  bool get wantKeepAlive => true;

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedMangaIds.contains(id)) {
        _selectedMangaIds.remove(id);
      } else {
        _selectedMangaIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMangaIds.clear();
    });
  }

  Future<void> _bulkDelete(MangaProvider provider) async {
    _lastBulkDeletedManga = provider.mangaList
        .where((m) => _selectedMangaIds.contains(m.id))
        .toList();
    await provider.bulkDeleteManga(_selectedMangaIds.toList());
    _clearSelection();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Deleted selected manga'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            if (_lastBulkDeletedManga != null) {
              for (final manga in _lastBulkDeletedManga!) {
                await provider.addManga(manga);
              }
              _lastBulkDeletedManga = null;
            }
          },
        ),
      ),
    );
  }

  Future<void> _bulkStatus(MangaProvider provider, String status) async {
    await provider.updateMangaStatusBulk(_selectedMangaIds.toList(), status);
    _clearSelection();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated status to $status'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _bulkTags(MangaProvider provider, List<String> tags) async {
    await provider.updateMangaTagsBulk(_selectedMangaIds.toList(), tags);
    _clearSelection();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Updated tags'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MangaProvider>(
      builder: (context, mangaProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              if (_isBulkMode) _buildBulkActionsBar(mangaProvider),
              _buildSearchBar(context, mangaProvider),
              Expanded(
                child: mangaProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : mangaProvider.filteredMangaList.isEmpty
                    ? _buildEmptyState(context)
                    : _buildMangaList(context, mangaProvider),
              ),
            ],
          ),
          floatingActionButton: MultiActionFAB(
            onAddManga: () async {
              final result = await Navigator.of(context).push<Manga>(
                MaterialPageRoute(
                  builder: (context) => const MangaEditScreen(),
                ),
              );
              if (result != null) {
                // Manga was added successfully
              }
            },
            onImportData: () async {
              try {
                final profileProvider = Provider.of<ProfileProvider>(
                  context,
                  listen: false,
                );
                final profileId = profileProvider.activeProfileId ?? 'default';
                final result = await ExportService.importFromJson(profileId);
                if (result != null) {
                  await Provider.of<MangaProvider>(
                    context,
                    listen: false,
                  ).importData(result);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data imported successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error importing data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            onScanQR: () {
              _showQRImportDialog(context);
            },
            onStartTimer: () {
              _showReadingTimerDialog(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildBulkActionsBar(MangaProvider provider) {
    return Material(
      color: Colors.grey[200],
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Cancel selection',
            child: SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: const Icon(Icons.close, semanticLabel: 'Cancel'),
                onPressed: _clearSelection,
                tooltip: 'Cancel',
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          ),
          Text('${_selectedMangaIds.length} selected'),
          const Spacer(),
          Semantics(
            button: true,
            label: 'Change status',
            child: SizedBox(
              width: 48,
              height: 48,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.label, semanticLabel: 'Change status'),
                tooltip: 'Change Status',
                itemBuilder: (context) => AppConstants.mangaStatuses
                    .map((s) => PopupMenuItem(value: s, child: Text(s)))
                    .toList(),
                onSelected: (status) => _bulkStatus(provider, status),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Delete selected',
            child: SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: const Icon(Icons.delete, semanticLabel: 'Delete'),
                onPressed: () => _bulkDelete(provider),
                tooltip: 'Delete',
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Set tags',
            child: SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: const Icon(Icons.local_offer, semanticLabel: 'Set tags'),
                onPressed: () async {
                  final tags = await showDialog<List<String>>(
                    context: context,
                    builder: (context) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        title: const Text('Set Tags (comma separated)'),
                        content: TextField(controller: controller),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(
                              context,
                              controller.text
                                  .split(',')
                                  .map((t) => t.trim())
                                  .where((t) => t.isNotEmpty)
                                  .toList(),
                            ),
                            child: const Text('Set'),
                          ),
                        ],
                      );
                    },
                  );
                  if (tags != null) _bulkTags(provider, tags);
                },
                tooltip: 'Set Tags',
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, MangaProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search library... e.g., status:reading rating:>7',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),

          // Status filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', ...AppConstants.mangaStatuses].map((status) {
                final isSelected = provider.selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: AppConstants.smSpacing),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      provider.setSelectedStatus(status);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 64,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.3),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'No manga found',
            style: AppTheme.getHeadlineStyle(context).copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          Text(
            'Add your first manga to get started',
            style: AppTheme.getBodyStyle(context).copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMangaList(BuildContext context, MangaProvider provider) {
    return ListView.builder(
      key: const PageStorageKey('myMangaList'),
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      itemCount: provider.filteredMangaList.length,
      itemBuilder: (context, index) {
        final manga = provider.filteredMangaList[index];
        final selected = _selectedMangaIds.contains(manga.id);
        return _buildMangaCard(context, manga, provider, selected);
      },
      // If all items are the same height, you can set itemExtent for better performance:
      // itemExtent: 90,
    );
  }

  Widget _buildMangaCard(
    BuildContext context,
    Manga manga,
    MangaProvider provider,
    bool selected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mdSpacing),
      decoration: AppTheme.getCardDecoration(context),
      child: ListTile(
        leading: Checkbox(
          value: selected,
          onChanged: (_) => _toggleSelect(manga.id),
        ),
        title: Text(
          manga.title,
          style: AppTheme.getBodyStyle(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${manga.status}'),
            Text('Tags: ${manga.tags.join(", ")}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (manga.currentChapter > 0) {
                  provider.updateChapter(manga.id, manga.currentChapter - 1);
                }
              },
              icon: const Icon(Icons.remove),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Chapter', style: TextStyle(fontSize: 10)),
                Text(
                  '${manga.currentChapter}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                provider.updateChapter(manga.id, manga.currentChapter + 1);
              },
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<Manga>(
                  MaterialPageRoute(
                    builder: (context) => MangaEditScreen(manga: manga),
                  ),
                );
                if (result != null) {
                  // Manga was updated successfully
                }
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              icon: const Icon(Icons.chrome_reader_mode, color: Colors.blue),
              tooltip: 'Read',
              onPressed: () async {
                final url = manga.sourceUrl?.isNotEmpty == true
                    ? manga.sourceUrl
                    : manga.url;
                if (url != null && url.isNotEmpty) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open URL'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No URL available for this manga'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                _lastDeletedManga = manga;
                await provider.deleteManga(manga.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted ${manga.title}'),
                    backgroundColor: Colors.red,
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: Colors.white,
                      onPressed: () async {
                        if (_lastDeletedManga != null) {
                          await provider.addManga(_lastDeletedManga!);
                          _lastDeletedManga = null;
                        }
                      },
                    ),
                  ),
                );
              },
              tooltip: 'Delete',
            ),
          ],
        ),
        onLongPress: () => _toggleSelect(manga.id),
        onTap: _isBulkMode ? () => _toggleSelect(manga.id) : null,
      ),
    );
  }

  void _showQRImportDialog(BuildContext context) {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Manga from URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the manga URL to import:'),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/manga/...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                Navigator.of(context).pop();
                // Navigate to manga edit screen with URL pre-filled
                final result = await Navigator.of(context).push<Manga>(
                  MaterialPageRoute(builder: (context) => MangaEditScreen()),
                );
                if (result != null) {
                  // Manga was added successfully
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showReadingTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Reading Session'),
        content: const Text(
          'A reading timer will be started. You can stop it anytime and log your reading session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Reading timer started! Use the timer in the top bar.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Start Timer'),
          ),
        ],
      ),
    );
  }
}
