import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/export_service.dart';
import 'package:provider/provider.dart';
import 'package:manga_marker/theme_manager.dart';
import 'package:manga_marker/models.dart';
import 'package:manga_marker/help_about_screen.dart';
import 'package:manga_marker/anilist_mal_import_export.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoUpdateBookmarks = true;
  Map<String, bool> _dashboardWidgetVisibility = {};
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _autoUpdateBookmarks = await _dbHelper.getAutoUpdateBookmarks();
    _dashboardWidgetVisibility = await _dbHelper.getDashboardWidgetVisibility();
    setState(() {});
  }

  Future<void> _toggleAutoUpdateBookmarks(bool value) async {
    await _dbHelper.setAutoUpdateBookmarks(value);
    setState(() {
      _autoUpdateBookmarks = value;
    });
  }

  Future<void> _toggleDashboardWidgetVisibility(String key, bool value) async {
    setState(() {
      _dashboardWidgetVisibility[key] = value;
    });
    await _dbHelper.setDashboardWidgetVisibility(_dashboardWidgetVisibility);
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Semantics(
            label:
                'Automatic Bookmark Update. Automatically update existing bookmarks when adding a new one with the same URL.',
            toggled: _autoUpdateBookmarks,
            child: SwitchListTile(
              title: const Text('Automatic Bookmark Update'),
              subtitle: const Text(
                'Automatically update existing bookmarks when adding a new one with the same URL.',
              ),
              value: _autoUpdateBookmarks,
              onChanged: _toggleAutoUpdateBookmarks,
            ),
          ),
          ListTile(
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: themeManager.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  themeManager.setThemeMode(newValue);
                }
              },
              items: const <DropdownMenuItem<ThemeMode>>[
                DropdownMenuItem<ThemeMode>(
                  value: ThemeMode.system,
                  child: Text('System Default'),
                ),
                DropdownMenuItem<ThemeMode>(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem<ThemeMode>(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Show Total Bookmarks on Dashboard'),
            value: _dashboardWidgetVisibility['totalBookmarks'] ?? true,
            onChanged: (value) =>
                _toggleDashboardWidgetVisibility('totalBookmarks', value),
          ),
          SwitchListTile(
            title: const Text('Show Favorite Bookmarks on Dashboard'),
            value: _dashboardWidgetVisibility['favoriteBookmarks'] ?? true,
            onChanged: (value) =>
                _toggleDashboardWidgetVisibility('favoriteBookmarks', value),
          ),
          SwitchListTile(
            title: const Text('Show Total Chapters Read on Dashboard'),
            value: _dashboardWidgetVisibility['totalChaptersRead'] ?? true,
            onChanged: (value) =>
                _toggleDashboardWidgetVisibility('totalChaptersRead', value),
          ),
          SwitchListTile(
            title: const Text('Show Recent Activity on Dashboard'),
            value: _dashboardWidgetVisibility['recentActivity'] ?? true,
            onChanged: (value) =>
                _toggleDashboardWidgetVisibility('recentActivity', value),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Export your bookmarks and settings'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                final bookmarks = await _dbHelper.getBookmarks();
                final tags = await _dbHelper.getTags();

                bool success = false;
                switch (value) {
                  case 'json':
                    success = await ExportService.exportAsJson(bookmarks, tags);
                    break;
                  case 'html':
                    success = await ExportService.exportAsHtml(bookmarks, tags);
                    break;
                }

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
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'json',
                  child: ListTile(
                    leading: Icon(Icons.code),
                    title: Text('Export as JSON'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'html',
                  child: ListTile(
                    leading: Icon(Icons.web),
                    title: Text('Export as HTML'),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Data'),
            subtitle: const Text('Import bookmarks from JSON file'),
            onTap: () async {
              try {
                final data = await ExportService.importFromJson();
                if (data != null) {
                  // Show confirmation dialog
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Import Data'),
                      content: Text(
                        'This will import ${data['bookmarks']?.length ?? 0} bookmarks. '
                        'Existing data may be overwritten. Continue?',
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

                  if (confirm == true && mounted) {
                    try {
                      final bookmarks = (data['bookmarks'] as List)
                          .map((e) => Bookmark.fromMap(e))
                          .toList();
                      await _dbHelper.saveBookmarks(bookmarks);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Import successful!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Import failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Import failed: Invalid or no file selected.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Import failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Accessibility Features'),
            subtitle: const Text('Enhanced accessibility support'),
            value: true, // This would be a real setting
            onChanged: (value) {
              // Implement accessibility toggle
            },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Tracker Import/Export'),
            subtitle: const Text('Import/export AniList/MyAnimeList files'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AniListMalImportExportScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & About'),
            subtitle: const Text('Usage instructions and app information'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HelpAboutScreen(),
                ),
              );
            },
          ),
          // Add more settings here,
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset to Defaults'),
            subtitle: const Text(
              'Clear all app data and restore default settings',
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset to Defaults'),
                  content: const Text(
                    'This will clear all your data and restore default settings. This cannot be undone. Continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await _dbHelper.clearAllData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App reset to defaults.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reset failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
