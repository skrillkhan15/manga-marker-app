import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io'; // For File in backup/restore

import 'package:manga_marker/bookmark_edit_screen.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';
import 'package:manga_marker/reading_goals_screen.dart';
import 'package:manga_marker/activity_log_screen.dart';
import 'package:manga_marker/streak_tracking_screen.dart';
import 'package:manga_marker/monthly_summary_screen.dart';
import 'package:manga_marker/faq_help_screen.dart';
import 'package:manga_marker/walkthrough_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:manga_marker/quick_edit_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:manga_marker/theme_manager.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:manga_marker/auth_manager.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:manga_marker/statistics_screen.dart';
import 'package:manga_marker/theme_editor_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeManager()),
        Provider(create: (context) => AuthManager()),
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isLocked = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveSession();
    }
  }

  Future<void> _saveSession() async {
    final dbHelper = DatabaseHelper();
    final homePageState = _homePageKey.currentState;
    if (homePageState != null) {
      await dbHelper.saveSessionData({
        'scrollOffset': homePageState._scrollController.offset,
        'isGridView': homePageState._isGridView,
        'filterStatus': homePageState._currentFilter.status,
        'filterTag': homePageState._currentFilter.tag,
        'filterCollection': homePageState._currentFilter.collection,
      });
    }
  }

  Future<void> _checkLockStatus() async {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final pin = await authManager.getPin();
    setState(() {
      _isLocked = pin != null;
    });
  }

  void _unlockApp() {
    setState(() {
      _isLocked = false;
    });
  }

  final GlobalKey<_MyHomePageState> _homePageKey = GlobalKey<_MyHomePageState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
          title: 'Manga Marker',
          theme: ThemeData(
            primarySwatch: themeManager.getMaterialColor(themeManager.primaryColor),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            primarySwatch: themeManager.getMaterialColor(themeManager.primaryColor),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.dark,
          ),
          themeMode: themeManager.themeMode,
          home: _isLocked ? PinEntryScreen(onUnlock: _unlockApp) : MyHomePage(key: _homePageKey, title: 'Manga Marker'),
        );
      },
    );
  }
}

class PinEntryScreen extends StatefulWidget {
  final VoidCallback onUnlock;

  const PinEntryScreen({super.key, required this.onUnlock});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';

  Future<void> _verifyPin() async {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final isCorrect = await authManager.verifyPin(_pinController.text);
    if (isCorrect) {
      widget.onUnlock();
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _verifyPin,
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
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
  List<Bookmark> bookmarks = [];
  bool _isGridView = false;
  bool _isBulkEditing = false;
  final Set<String> _selectedBookmarks = {};
  BookmarkFilter _currentFilter = BookmarkFilter();
  double _fontSize = 16.0; // Default font size
  double _itemSpacing = 8.0; // Default item spacing
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  bool _devMode = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _loadDevMode();
    _loadSessionData();
    _scrollController.addListener(() {
      setState(() {
        _showScrollToTopButton = _scrollController.offset >= 400;
      });
    });
  }

  Future<void> _loadSessionData() async {
    final sessionData = await dbHelper.loadSessionData();
    if (sessionData != null) {
      setState(() {
        _scrollController.jumpTo(sessionData['scrollOffset'] ?? 0.0);
        _isGridView = sessionData['isGridView'] ?? false;
        _currentFilter = BookmarkFilter(
          status: sessionData['filterStatus'],
          tag: sessionData['filterTag'],
          collection: sessionData['filterCollection'],
        );
      });
    }
  }

  Future<void> _loadDevMode() async {
    _devMode = await dbHelper.getDevMode();
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    List<Bookmark> loadedBookmarks = await dbHelper.getBookmarks();
    if (_currentFilter.isActive) {
      loadedBookmarks = loadedBookmarks.where((bookmark) {
        bool matches = true;
        if (_currentFilter.status != null && _currentFilter.status != bookmark.status) {
          matches = false;
        }
        if (_currentFilter.tag != null && !bookmark.tags.contains(_currentFilter.tag!)) {
          matches = false;
        }
        if (_currentFilter.collection != null && _currentFilter.collection != bookmark.collectionId) {
          matches = false;
        }
        return matches;
      }).toList();
    }
    setState(() {
      bookmarks = loadedBookmarks;
    });
  }

  void _addBookmark() async {
    final newBookmark = await Navigator.of(context).push<Bookmark>(
      MaterialPageRoute(
        builder: (context) => const BookmarkEditScreen(),
      ),
    );
    if (newBookmark != null) {
      dbHelper.addBookmark(newBookmark);
      dbHelper.addActivityLogEntry(ActivityLogEntry(
        id: const Uuid().v4(),
        type: 'Bookmark Added',
        description: 'Added bookmark: ${newBookmark.title}',
        timestamp: DateTime.now(),
      ));
      _loadBookmarks();
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isBulkEditing ? '${_selectedBookmarks.length} selected' : widget.title),
        actions: [
          if (_isBulkEditing)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                setState(() {
                  bookmarks.removeWhere((bookmark) => _selectedBookmarks.contains(bookmark.id));
                  dbHelper.saveBookmarks(bookmarks);
                  _selectedBookmarks.clear();
                  _isBulkEditing = false;
                });
                HapticFeedback.heavyImpact();
              },
            ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () async {
              if (bookmarks.isNotEmpty) {
                final randomBookmark = (bookmarks..shuffle()).first;
                final updatedBookmark = await Navigator.of(context).push<Bookmark>(
                  MaterialPageRoute(
                    builder: (context) => BookmarkEditScreen(bookmark: randomBookmark),
                  ),
                );
                if (updatedBookmark != null) {
                  dbHelper.updateBookmark(updatedBookmark);
                  _loadBookmarks();
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
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_on),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final selectedFilter = await showDialog<BookmarkFilter>(
                context: context,
                builder: (context) => FilterDialog(currentFilter: _currentFilter),
              );
              if (selectedFilter != null) {
                setState(() {
                  _currentFilter = selectedFilter;
                });
                _loadBookmarks();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () async {
              String? presetNameInput;
              final presetName = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Save View Preset'),
                  content: TextField(
                    decoration: const InputDecoration(labelText: 'Preset Name'),
                    onChanged: (value) => presetNameInput = value,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, presetNameInput),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (presetName != null && presetName.isNotEmpty) {
                final newPreset = ViewPreset(
                  name: presetName,
                  isGridView: _isGridView,
                  filter: _currentFilter,
                );
                final presets = await dbHelper.getViewPresets();
                presets.add(newPreset);
                await dbHelper.saveViewPresets(presets);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Preset ${presetName} saved!')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () async {
              final presets = await dbHelper.getViewPresets();
              final selectedPreset = await showDialog<ViewPreset>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Load View Preset'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: presets.length,
                      itemBuilder: (context, index) {
                        final preset = presets[index];
                        return ListTile(
                          title: Text(preset.name),
                          subtitle: Text(preset.filter.toString()),
                          onTap: () => Navigator.pop(context, preset),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
              if (selectedPreset != null) {
                setState(() {
                  _isGridView = selectedPreset.isGridView;
                  _currentFilter = selectedPreset.filter;
                });
                _loadBookmarks();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Preset ${selectedPreset.name} loaded!')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_size),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Adjust Display Settings'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Font Size: ${_fontSize.toStringAsFixed(1)}'),
                      Slider(
                        value: _fontSize,
                        min: 12.0,
                        max: 24.0,
                        divisions: 12,
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value;
                          });
                        },
                      ),
                      Text('Item Spacing: ${_itemSpacing.toStringAsFixed(1)}'),
                      Slider(
                        value: _itemSpacing,
                        min: 0.0,
                        max: 20.0,
                        divisions: 20,
                        onChanged: (value) {
                          setState(() {
                            _itemSpacing = value;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          Consumer<ThemeManager>(
            builder: (context, themeManager, child) {
              return IconButton(
                icon: Icon(themeManager.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  themeManager.toggleTheme(themeManager.themeMode != ThemeMode.dark);
                },
              );
            },
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
          : _isGridView
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: _itemSpacing,
                    mainAxisSpacing: _itemSpacing,
                    childAspectRatio: 0.7,
                  ),
                  controller: _scrollController,
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    final isSelected = _selectedBookmarks.contains(bookmark.id);
                    return GestureDetector(
                      onLongPress: () async {
                        HapticFeedback.mediumImpact();
                        if (!_isBulkEditing) {
                          final updatedBookmark = await showModalBottomSheet<Bookmark>(
                            context: context,
                            builder: (context) => QuickEditBottomSheet(bookmark: bookmark),
                          );
                          if (updatedBookmark != null) {
                            dbHelper.updateBookmark(updatedBookmark);
                            _loadBookmarks();
                          }
                        } else {
                          setState(() {
                            if (isSelected) {
                              _selectedBookmarks.remove(bookmark.id);
                            } else {
                              _selectedBookmarks.add(bookmark.id);
                            }
                            if (_selectedBookmarks.isEmpty) {
                              _isBulkEditing = false;
                            }
                          });
                        }
                      },
                      onTap: () async {
                        if (_isBulkEditing) {
                          setState(() {
                            if (isSelected) {
                              _selectedBookmarks.remove(bookmark.id);
                            } else {
                              _selectedBookmarks.add(bookmark.id);
                            }
                            if (_selectedBookmarks.isEmpty) {
                              _isBulkEditing = false;
                            }
                          });
                        } else {
                          final updatedBookmark = await Navigator.of(context).push<Bookmark>(
                            MaterialPageRoute(
                              builder: (context) => BookmarkEditScreen(bookmark: bookmark),
                            ),
                          );
                          if (updatedBookmark != null) {
                            dbHelper.updateBookmark(updatedBookmark);
                            _loadBookmarks();
                          }
                        }
                      },
                      child: Card(
                        color: isSelected ? Colors.blue.withOpacity(0.5) : null,
                        child: Column(
                          children: [
                            if (bookmark.coverImage.isNotEmpty)
                              Expanded(
                                child: Image.memory(base64Decode(bookmark.coverImage), fit: BoxFit.cover),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(bookmark.title, textAlign: TextAlign.center, style: TextStyle(fontSize: _fontSize)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ReorderableListView.builder(
                  scrollController: _scrollController,
                  itemCount: bookmarks.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = bookmarks.removeAt(oldIndex);
                      bookmarks.insert(newIndex, item);
                      dbHelper.saveBookmarks(bookmarks);
                    });
                  },
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    final isSelected = _selectedBookmarks.contains(bookmark.id);
                    return Dismissible(
                      key: ValueKey(bookmark.id),
                      background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Icon(Icons.delete, color: Colors.white)),
                      secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (direction) {
                        dbHelper.deleteBookmark(bookmark.id);
                        _loadBookmarks();
                        HapticFeedback.heavyImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${bookmark.title} dismissed')),
                        );
                      },
                      child: ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.blue.withOpacity(0.2),
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _isBulkEditing = true;
                            if (isSelected) {
                              _selectedBookmarks.remove(bookmark.id);
                            } else {
                              _selectedBookmarks.add(bookmark.id);
                            }
                            if (_selectedBookmarks.isEmpty) {
                              _isBulkEditing = false;
                            }
                          });
                        },
                        onTap: () async {
                          if (_isBulkEditing) {
                            setState(() {
                              if (isSelected) {
                                _selectedBookmarks.remove(bookmark.id);
                              } else {
                                _selectedBookmarks.add(bookmark.id);
                              }
                              if (_selectedBookmarks.isEmpty) {
                                _isBulkEditing = false;
                              }
                            });
                          } else {
                            final updatedBookmark = await Navigator.of(context).push<Bookmark>(
                              MaterialPageRoute(
                                builder: (context) => BookmarkEditScreen(bookmark: bookmark),
                              ),
                            );
                            if (updatedBookmark != null) {
                              dbHelper.updateBookmark(updatedBookmark);
                              _loadBookmarks();
                            }
                          }
                        },
                        leading: bookmark.coverImage.isNotEmpty
                            ? Image.memory(base64Decode(bookmark.coverImage), width: 50, height: 50, fit: BoxFit.cover)
                            : null,
                        title: Text(bookmark.title, style: TextStyle(fontSize: _fontSize)),
                        subtitle: Text(
                            '${bookmark.url} - ${bookmark.status} - ${bookmark.tags.join(', ')}\n'
                            'Ch: ${bookmark.currentChapter}/${bookmark.totalChapters} - Rating: ${bookmark.rating} - Mood: ${bookmark.mood}',
                            style: TextStyle(fontSize: _fontSize * 0.8),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                final clonedBookmark = Bookmark(
                                  id: const Uuid().v4(),
                                  title: '${bookmark.title} (Copy)',
                                  url: bookmark.url,
                                  coverImage: bookmark.coverImage,
                                  currentChapter: bookmark.currentChapter,
                                  totalChapters: bookmark.totalChapters,
                                  status: bookmark.status,
                                  tags: List.from(bookmark.tags),
                                  notes: bookmark.notes,
                                  rating: bookmark.rating,
                                  mood: bookmark.mood,
                                  collectionId: bookmark.collectionId,
                                  lastUpdated: DateTime.now(),
                                );
                                dbHelper.addBookmark(clonedBookmark);
                                _loadBookmarks();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                dbHelper.deleteBookmark(bookmark.id);
                                _loadBookmarks();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_showScrollToTopButton)
            FloatingActionButton(
              heroTag: 'scrollToTop',
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addBookmark',
            onPressed: _addBookmark,
            tooltip: 'Add Bookmark',
            child: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manga Marker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  FutureBuilder<String?>(
                    future: Provider.of<AuthManager>(context).loadUserProfile(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        return Text(
                          'Profile: ${snapshot.data}',
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Reading Goals'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReadingGoalsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Settings Screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Statistics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Set PIN'),
              onTap: () async {
                Navigator.pop(context);
                final authManager = Provider.of<AuthManager>(context, listen: false);
                final newPin = await _showPinDialog(context, 'Set New PIN');
                if (newPin != null && newPin.isNotEmpty) {
                  await authManager.setPin(newPin);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN set successfully!')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('Set Security Question'),
              onTap: () async {
                Navigator.pop(context);
                final authManager = Provider.of<AuthManager>(context, listen: false);
                final result = await _showSecurityQuestionDialog(context);
                if (result != null && result['question'] != null && result['answer'] != null) {
                  await authManager.setSecurityQuestion(result['question']!, result['answer']!); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Security question set!')),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Manage Profiles'),
              onTap: () async {
                Navigator.pop(context);
                final authManager = Provider.of<AuthManager>(context, listen: false);
                final profiles = await authManager.getAllUserProfiles();
                String? newProfileNameInput;
                final newProfileName = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Manage User Profiles'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(labelText: 'New Profile Name'),
                          onChanged: (value) => newProfileNameInput = value,
                        ),
                        if (profiles.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Existing Profiles:'),
                              ),
                              ...profiles.map((profile) => ListTile(
                                    title: Text(profile),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await authManager.deleteUserProfile(profile);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    onTap: () async {
                                      await authManager.switchUserProfile(profile);
                                      Navigator.pop(context);
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (context) => const MyApp()),
                                      );
                                    },
                                  )),
                            ],
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (newProfileNameInput != null && newProfileNameInput!.isNotEmpty) {
                            await authManager.saveUserProfile(newProfileNameInput!); 
                            Navigator.pop(context, newProfileNameInput);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const MyApp()),
                            );
                          }
                        },
                        child: const Text('Add/Switch'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Export Data (JSON)'),
              onTap: () async {
                Navigator.pop(context);
                await dbHelper.exportDataToJson();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data exported!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Import Data (JSON)'),
              onTap: () async {
                Navigator.pop(context);
                await dbHelper.importDataFromJson();
                _loadBookmarks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data imported!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_open),
              title: const Text('Export Encrypted Data'),
              onTap: () async {
                Navigator.pop(context);
                final password = await _showPasswordDialog(context, 'Export Password');
                if (password != null && password.isNotEmpty) {
                  await dbHelper.exportEncryptedDataToJson(password);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Encrypted data exported!')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Import Encrypted Data'),
              onTap: () async {
                Navigator.pop(context);
                final password = await _showPasswordDialog(context, 'Import Password');
                if (password != null && password.isNotEmpty) {
                  await dbHelper.importEncryptedDataFromJson(password);
                  _loadBookmarks();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Encrypted data imported!')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Import from QR Code'),
              onTap: () async {
                Navigator.pop(context);
                final qrData = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (context) => const QrScannerScreen(),
                  ),
                );
                if (qrData != null && qrData.isNotEmpty) {
                  final importedBookmark = await dbHelper.importBookmarkFromQrCode(qrData);
                  if (importedBookmark != null) {
                    await dbHelper.addBookmark(importedBookmark);
                    _loadBookmarks();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bookmark ${importedBookmark.title} imported from QR!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to import bookmark from QR code.')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Perform Auto Backup'),
              onTap: () async {
                Navigator.pop(context);
                await dbHelper.performAutoBackup();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup created!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore from Backup'),
              onTap: () async {
                Navigator.pop(context);
                final backups = await dbHelper.getAvailableBackups();
                if (backups.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No backups found!')),
                  );
                  return;
                }

                final selectedBackup = await showDialog<File>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Backup to Restore'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: backups.length,
                        itemBuilder: (context, index) {
                          final backup = backups[index];
                          return ListTile(
                            title: Text(backup.path.split('/').last),
                            onTap: () => Navigator.pop(context, backup),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );

                if (selectedBackup != null) {
                  await dbHelper.restoreFromBackup(selectedBackup);
                  _loadBookmarks();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data restored!')),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Full App Reset'),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Reset'),
                    content: const Text('Are you sure you want to clear all app data? This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await dbHelper.clearAllData();
                  _loadBookmarks();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All app data cleared!')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_usage),
              title: const Text('Data Usage'),
              onTap: () async {
                Navigator.pop(context);
                final size = await dbHelper.getLocalStorageSize();
                final sizeKB = (size / 1024).toStringAsFixed(2);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Local Storage Usage: $sizeKB KB')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Activity Log'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ActivityLogScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Streak Tracking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StreakTrackingScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Monthly Summaries'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MonthlySummaryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('FAQ / Help'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FaqHelpScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.tour),
              title: const Text('Walkthrough'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WalkthroughScreen(),
                  ),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Developer Mode'),
              secondary: const Icon(Icons.developer_mode),
              value: _devMode,
              onChanged: (bool value) {
                setState(() {
                  _devMode = value;
                });
                dbHelper.setDevMode(value);
              },
            ),
            if (_devMode)
              ListTile(
                leading: const Icon(Icons.science),
                title: const Text('Experimental Features'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Experimental features enabled!')),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Theme Editor'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ThemeEditorScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showPasswordDialog(BuildContext context, String title) {
    String? password;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
          onChanged: (value) => password = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, password),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showPinDialog(BuildContext context, String title) {
    String? pin;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'PIN'),
          onChanged: (value) => pin = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, pin),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>?> _showSecurityQuestionDialog(BuildContext context) {
    String? question;
    String? answer;
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Security Question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Security Question'),
              onChanged: (value) => question = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Answer'),
              onChanged: (value) => answer = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {'question': question!, 'answer': answer!}),
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            Navigator.of(context).pop(barcode.rawValue);
            return;
          }
        },
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final BookmarkFilter currentFilter;

  const FilterDialog({super.key, required this.currentFilter});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String? _selectedStatus;
  late String? _selectedTag;
  late String? _selectedCollection;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentFilter.status;
    _selectedTag = widget.currentFilter.tag;
    _selectedCollection = widget.currentFilter.collection;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Bookmarks'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(labelText: 'Status'),
            items: <String>['Reading', 'Completed', 'On Hold', 'Dropped', 'Plan to Read', 'All']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value == 'All' ? null : value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedStatus = newValue;
              });
            },
          ),
          TextFormField(
            initialValue: _selectedTag,
            decoration: const InputDecoration(labelText: 'Tag'),
            onChanged: (value) {
              _selectedTag = value.isEmpty ? null : value;
            },
          ),
          TextFormField(
            initialValue: _selectedCollection,
            decoration: const InputDecoration(labelText: 'Collection'),
            onChanged: (value) {
              _selectedCollection = value.isEmpty ? null : value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              BookmarkFilter(
                status: _selectedStatus,
                tag: _selectedTag,
                collection: _selectedCollection,
              ),
            );
          },
          child: const Text('Apply Filter'),
        ),
      ],
    );
  }
}
