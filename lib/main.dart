import 'package:flutter/material.dart';

import 'package:manga_marker/bookmark_edit_screen.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';
import 'package:manga_marker/reading_goals_screen.dart';
import 'package:manga_marker/dashboard_screen.dart';
import 'package:manga_marker/settings_screen.dart';
import 'package:manga_marker/activity_log_screen.dart';
import 'package:manga_marker/theme_manager.dart';
import 'package:manga_marker/export_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:manga_marker/bookmark_provider.dart'; // Import BookmarkProvider
import 'package:manga_marker/bookmark_list_view.dart'; // Import BookmarkListView
import 'package:manga_marker/pin_lock_screen.dart';
import 'package:manga_marker/user_profile_screen.dart';
import 'package:manga_marker/manga_viewer_screen.dart';
import 'package:manga_marker/pdf_cbz_viewer_screen.dart';

void main() {
  runApp(
    MultiProvider(
      // Use MultiProvider for multiple providers
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeManager()),
        ChangeNotifierProvider(
          create: (context) => BookmarkProvider(),
        ), // Add BookmarkProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _authenticated = false;
  String? _selectedProfile;

  void _onProfileSelected(String profileName) {
    setState(() {
      _selectedProfile = profileName;
    });
  }

  void _onAuthenticated() {
    setState(() {
      _authenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
          title: 'Manga Marker',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            useMaterial3: true,
          ),
          themeMode: themeManager.themeMode,
          home: _selectedProfile == null
              ? UserProfileScreen(onProfileSelected: _onProfileSelected)
              : !_authenticated
              ? PinLockScreen(onAuthenticated: _onAuthenticated)
              : const MyHomePage(title: 'Manga Marker'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper();
  // bookmarks list will now be managed by BookmarkProvider

  @override
  void initState() {
    super.initState();
    // Bookmarks are loaded by the provider, no need to call _loadBookmarks here
  }

  Future<void> _addBookmark() async {
    final newBookmark = await Navigator.of(context).push<Bookmark>(
      MaterialPageRoute(builder: (context) => const BookmarkEditScreen()),
    );
    if (!mounted) return;
    if (newBookmark != null) {
      // Use provider to add bookmark
      Provider.of<BookmarkProvider>(
        context,
        listen: false,
      ).addBookmark(newBookmark);
    }
  }

  Future<void> _updateBookmark(Bookmark bookmark) async {
    // Use provider to update bookmark
    Provider.of<BookmarkProvider>(
      context,
      listen: false,
    ).updateBookmark(bookmark);
  }

  @override
  Widget build(BuildContext context) {
    // Consume bookmarks from the provider
    final bookmarks = Provider.of<BookmarkProvider>(context).bookmarks;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF/CBZ Viewer',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PdfCbzViewerScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Manga Viewer',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MangaViewerScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ActivityLogScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () async {
              if (bookmarks.isNotEmpty) {
                final randomBookmark = (bookmarks..shuffle()).first;
                final updatedBookmark = await Navigator.of(context)
                    .push<Bookmark>(
                      MaterialPageRoute(
                        builder: (context) =>
                            BookmarkEditScreen(bookmark: randomBookmark),
                      ),
                    );
                if (updatedBookmark != null) {
                  await _updateBookmark(updatedBookmark);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReadingGoalsScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'settings':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  break;
                case 'export_json':
                  final currentBookmarks = Provider.of<BookmarkProvider>(
                    context,
                    listen: false,
                  ).bookmarks;
                  final tags = await dbHelper.getTags();
                  final success = await ExportService.exportAsJson(
                    currentBookmarks,
                    tags,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? 'Export successful!' : 'Export failed',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                  break;
                case 'export_html':
                  final currentBookmarks = Provider.of<BookmarkProvider>(
                    context,
                    listen: false,
                  ).bookmarks;
                  final tags = await dbHelper.getTags();
                  final success = await ExportService.exportAsHtml(
                    currentBookmarks,
                    tags,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? 'Export successful!' : 'Export failed',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                  break;
                case 'import':
                  final data = await ExportService.importFromJson();
                  if (data != null && mounted) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Import Data'),
                        content: Text(
                          'This will import ${data['bookmarks']?.length ?? 0} bookmarks. '
                          'Continue?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Import'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        final importedBookmarks = (data['bookmarks'] as List)
                            .map((e) => Bookmark.fromMap(e))
                            .toList();
                        await dbHelper.saveBookmarks(importedBookmarks);
                        Provider.of<BookmarkProvider>(
                          context,
                          listen: false,
                        ).loadBookmarks(); // Reload via provider

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Import successful!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Import failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuItem(
                value: 'export_json',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export JSON'),
                ),
              ),
              const PopupMenuItem(
                value: 'export_html',
                child: ListTile(
                  leading: Icon(Icons.web),
                  title: Text('Export HTML'),
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Import Data'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: bookmarks.isEmpty
          ? const Center(
              child: Text(
                'No bookmarks yet.\nTap the + button to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            )
          : BookmarkListView(bookmarks: bookmarks), // Use BookmarkListView here
      floatingActionButton: FloatingActionButton(
        onPressed: _addBookmark,
        tooltip: 'Add Bookmark',
        child: const Icon(Icons.add),
      ),
    );
  }
}
