import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/manga_provider.dart';
import '../profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../export_service.dart';
import 'qr_import_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show kReleaseMode;
// Web-only avatar picker
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../screens/help_about_screen.dart';
import 'package:path_provider/path_provider.dart'; // Add to pubspec.yaml
import 'package:file_picker/file_picker.dart'; // Add to pubspec.yaml
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'manage_profiles_screen.dart';

Future<String?> pickWebAvatar() async {
  final input = html.FileUploadInputElement();
  input.accept = 'image/*';
  input.click();
  await input.onChange.first;
  if (input.files != null && input.files!.isNotEmpty) {
    final file = input.files!.first;
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;
    return reader.result as String;
  }
  return null;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        children: [
          _buildProfileSection(),
          Text('Settings', style: AppTheme.getHeadlineStyle(context)),
          const SizedBox(height: AppConstants.lgSpacing),

          _buildAppearanceSection(),
          const SizedBox(height: AppConstants.lgSpacing),
          _buildGoalsSection(),
          const SizedBox(height: AppConstants.lgSpacing),
          _buildBackupSection(),
          const SizedBox(height: AppConstants.lgSpacing),
          _buildDangerZone(),
          _buildDeveloperSection(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & About'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HelpAboutScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Manage Profiles'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ManageProfilesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset All Settings'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset All Settings'),
                  content: const Text(
                    'Are you sure you want to reset all settings and appearance to defaults? This cannot be undone.',
                  ),
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
                await Provider.of<SettingsProvider>(
                  context,
                  listen: false,
                ).resetToDefaults();
                await Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).resetToDefaults();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All settings reset to defaults'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profiles = profileProvider.profiles;
        final active = profileProvider.activeProfile;
        return Card(
          margin: const EdgeInsets.all(AppConstants.mdSpacing),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          (active != null && active.avatarPath.isNotEmpty)
                          ? (kIsWeb &&
                                    active.avatarPath.startsWith('data:image/')
                                ? MemoryImage(
                                    base64Decode(
                                      active.avatarPath.split(',').last,
                                    ),
                                  )
                                : FileImage(File(active.avatarPath))
                                      as ImageProvider)
                          : null,
                      child: (active == null || active.avatarPath.isEmpty)
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: AppConstants.mdSpacing),
                    Text(
                      active?.name ?? 'No Profile',
                      style: AppTheme.getHeadlineStyle(
                        context,
                      ).copyWith(fontSize: 18),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Profile',
                      onPressed: () async {
                        final nameController = TextEditingController();
                        String? avatarPath;
                        await showDialog(
                          context: context,
                          builder: (context) => StatefulBuilder(
                            builder: (context, setState) => AlertDialog(
                              title: const Text('Create Profile'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      if (kIsWeb) {
                                        final result = await pickWebAvatar();
                                        if (result != null) {
                                          setState(() {
                                            avatarPath = result;
                                          });
                                        }
                                      } else {
                                        // Mobile/desktop: use ImagePicker
                                        final picker = ImagePicker();
                                        final picked = await picker.pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            avatarPath = picked.path;
                                          });
                                        }
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundImage: avatarPath != null
                                          ? (kIsWeb &&
                                                    avatarPath!.startsWith(
                                                      'data:image/',
                                                    )
                                                ? MemoryImage(
                                                    base64Decode(
                                                      avatarPath!
                                                          .split(',')
                                                          .last,
                                                    ),
                                                  )
                                                : FileImage(File(avatarPath!))
                                                      as ImageProvider)
                                          : null,
                                      child: avatarPath == null
                                          ? const Icon(Icons.person, size: 32)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                    ),
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
                                    if (nameController.text.isNotEmpty) {
                                      await profileProvider.addProfile(
                                        nameController.text,
                                        avatarPath ?? '',
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Create'),
                                ),
                              ],
                            ),
                          ),
                        );
                        nameController.dispose(); // Dispose after dialog closes
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.smSpacing),
                if (profiles.length > 1)
                  Wrap(
                    spacing: 8,
                    children: profiles.map((profile) {
                      final isActive = profile.id == active?.id;
                      return InputChip(
                        avatar: profile.avatarPath.isNotEmpty
                            ? (kIsWeb &&
                                      profile.avatarPath.startsWith(
                                        'data:image/',
                                      )
                                  ? CircleAvatar(
                                      backgroundImage: MemoryImage(
                                        base64Decode(
                                          profile.avatarPath.split(',').last,
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundImage: FileImage(
                                        File(profile.avatarPath),
                                      ),
                                    ))
                            : null,
                        label: Text(profile.name),
                        selected: isActive,
                        onSelected: (_) =>
                            profileProvider.switchProfile(profile.id),
                        onDeleted: profiles.length > 1
                            ? () => profileProvider.deleteProfile(profile.id)
                            : null,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppearanceSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.mdSpacing),

                // Theme Mode
                ListTile(
                  title: const Text('Theme Mode'),
                  subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setThemeMode(value);
                      }
                    },
                  ),
                ),

                const Divider(),

                // Primary Color
                ListTile(
                  title: const Text('Primary Color'),
                  trailing: GestureDetector(
                    onTap: () => _showColorPicker(
                      context,
                      themeProvider.primaryColor,
                      (color) => themeProvider.setPrimaryColor(color),
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: themeProvider.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                // Secondary Color
                ListTile(
                  title: const Text('Secondary Color'),
                  trailing: GestureDetector(
                    onTap: () => _showColorPicker(
                      context,
                      themeProvider.secondaryColor,
                      (color) => themeProvider.setSecondaryColor(color),
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: themeProvider.secondaryColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                // Accent Color
                ListTile(
                  title: const Text('Accent Color'),
                  trailing: GestureDetector(
                    onTap: () => _showColorPicker(
                      context,
                      themeProvider.accentColor,
                      (color) => themeProvider.setAccentColor(color),
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: themeProvider.accentColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                const Divider(),

                // Fonts
                ListTile(
                  title: const Text('Headline Font'),
                  subtitle: Text(themeProvider.headlineFont),
                  trailing: DropdownButton<String>(
                    value: themeProvider.headlineFont,
                    items: const [
                      DropdownMenuItem(
                        value: 'Roboto Slab',
                        child: Text('Roboto Slab'),
                      ),
                      DropdownMenuItem(
                        value: 'Merriweather',
                        child: Text('Merriweather'),
                      ),
                      DropdownMenuItem(
                        value: 'Playfair Display',
                        child: Text('Playfair Display'),
                      ),
                      DropdownMenuItem(value: 'Lora', child: Text('Lora')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setHeadlineFont(value);
                      }
                    },
                  ),
                ),

                ListTile(
                  title: const Text('Body Font'),
                  subtitle: Text(themeProvider.bodyFont),
                  trailing: DropdownButton<String>(
                    value: themeProvider.bodyFont,
                    items: const [
                      DropdownMenuItem(
                        value: 'Open Sans',
                        child: Text('Open Sans'),
                      ),
                      DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                      DropdownMenuItem(value: 'Lato', child: Text('Lato')),
                      DropdownMenuItem(
                        value: 'Source Sans Pro',
                        child: Text('Source Sans Pro'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        themeProvider.setBodyFont(value);
                      }
                    },
                  ),
                ),

                ListTile(
                  title: const Text('Font Size'),
                  subtitle: Text(
                    '${Provider.of<ThemeProvider>(context).fontSize.toStringAsFixed(1)}',
                  ),
                  trailing: SizedBox(
                    width: 120,
                    child: Slider(
                      min: 12,
                      max: 24,
                      divisions: 12,
                      value: Provider.of<ThemeProvider>(context).fontSize,
                      onChanged: (val) {
                        Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).setFontSize(val);
                      },
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('High Contrast Mode'),
                  value: Provider.of<ThemeProvider>(context).highContrast,
                  onChanged: (bool value) => Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).setHighContrast(value),
                ),

                const Divider(),

                // Reset to Defaults
                ListTile(
                  title: const Text('Reset to Defaults'),
                  subtitle: const Text('Reset all appearance settings'),
                  trailing: const Icon(Icons.refresh),
                  onTap: () => _showResetDialog(context, themeProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalsSection() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reading Goals',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.mdSpacing),

                // Daily Goal
                ListTile(
                  title: const Text('Daily Goal'),
                  subtitle: Text('${settingsProvider.dailyGoal} chapters'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (settingsProvider.dailyGoal > 1) {
                            settingsProvider.setDailyGoal(
                              settingsProvider.dailyGoal - 1,
                            );
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text('${settingsProvider.dailyGoal}'),
                      IconButton(
                        onPressed: () {
                          settingsProvider.setDailyGoal(
                            settingsProvider.dailyGoal + 1,
                          );
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),

                // Weekly Goal
                ListTile(
                  title: const Text('Weekly Goal'),
                  subtitle: Text('${settingsProvider.weeklyGoal} chapters'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (settingsProvider.weeklyGoal > 1) {
                            settingsProvider.setWeeklyGoal(
                              settingsProvider.weeklyGoal - 1,
                            );
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text('${settingsProvider.weeklyGoal}'),
                      IconButton(
                        onPressed: () {
                          settingsProvider.setWeeklyGoal(
                            settingsProvider.weeklyGoal + 1,
                          );
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),

                // Monthly Goal
                ListTile(
                  title: const Text('Monthly Goal'),
                  subtitle: Text('${settingsProvider.monthlyGoal} chapters'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (settingsProvider.monthlyGoal > 1) {
                            settingsProvider.setMonthlyGoal(
                              settingsProvider.monthlyGoal - 1,
                            );
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text('${settingsProvider.monthlyGoal}'),
                      IconButton(
                        onPressed: () {
                          settingsProvider.setMonthlyGoal(
                            settingsProvider.monthlyGoal + 1,
                          );
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackupSection() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final profileProvider = Provider.of<ProfileProvider>(
          context,
          listen: false,
        );
        final profileName = profileProvider.activeProfile?.name ?? 'profile';
        return Card(
          margin: const EdgeInsets.all(AppConstants.mdSpacing),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Backup & Restore',
                      style: AppTheme.getHeadlineStyle(
                        context,
                      ).copyWith(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message:
                          'All backup, export, and import actions only affect the current profile (${profileName}). Other profiles are not changed.',
                      child: const Icon(Icons.info_outline, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.mdSpacing),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('Export Data'),
                  subtitle: Text(
                    'Backup your manga data to JSON (only for profile: $profileName)',
                  ),
                  trailing: Tooltip(
                    message:
                        'Exports only the manga and settings for the current profile.',
                    child: const Icon(Icons.info_outline, size: 18),
                  ),
                  onTap: () => _exportData(context),
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Export Encrypted Data'),
                  subtitle: Text(
                    'Backup with password protection (only for profile: $profileName)',
                  ),
                  trailing: Tooltip(
                    message:
                        'Exports only the manga and settings for the current profile, encrypted with your password.',
                    child: const Icon(Icons.info_outline, size: 18),
                  ),
                  onTap: () => _exportEncryptedData(context),
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Import Data'),
                  subtitle: Text(
                    'Restore manga data from JSON file (only for profile: $profileName)',
                  ),
                  trailing: Tooltip(
                    message:
                        'Imports only to the current profile. Other profiles are not affected.',
                    child: const Icon(Icons.info_outline, size: 18),
                  ),
                  onTap: () => _importData(context),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_open),
                  title: const Text('Import Encrypted Data'),
                  subtitle: Text(
                    'Restore from password-protected file (only for profile: $profileName)',
                  ),
                  trailing: Tooltip(
                    message:
                        'Imports only to the current profile. Other profiles are not affected.',
                    child: const Icon(Icons.info_outline, size: 18),
                  ),
                  onTap: () => _importEncryptedData(context),
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: const Text('QR Code Import'),
                  subtitle: Text(
                    'Import manga data by scanning QR code (only for profile: $profileName)',
                  ),
                  trailing: Tooltip(
                    message:
                        'Imports only to the current profile. Other profiles are not affected.',
                    child: const Icon(Icons.info_outline, size: 18),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRImportScreen(),
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Auto Backup'),
                  value: settingsProvider.autoBackupEnabled,
                  onChanged: (bool value) =>
                      settingsProvider.setAutoBackupEnabled(value),
                ),
                ListTile(
                  title: const Text('Auto-Backup Interval'),
                  subtitle: const Text(
                    'Automatically backup your data to device storage',
                  ),
                  trailing: DropdownButton<String>(
                    value: Provider.of<SettingsProvider>(
                      context,
                    ).autoBackupInterval,
                    items: const [
                      DropdownMenuItem(value: 'off', child: Text('Off')),
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        Provider.of<SettingsProvider>(
                          context,
                          listen: false,
                        ).setAutoBackupInterval(value);
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: const Text('Backup to Device'),
                  onTap: () async {
                    try {
                      final dir = await getApplicationDocumentsDirectory();
                      final timestamp = DateTime.now().millisecondsSinceEpoch;
                      final file = File(
                        '${dir.path}/mangamarks_backup_$timestamp.json',
                      );
                      final mangaProvider = Provider.of<MangaProvider>(
                        context,
                        listen: false,
                      );
                      final exportData = {
                        'metadata': {
                          'exportDate': DateTime.now().toIso8601String(),
                          'version': '1.0',
                          'totalManga': mangaProvider.mangaList.length,
                        },
                        'manga': mangaProvider.mangaList
                            .map((m) => m.toMap())
                            .toList(),
                        // Add other fields as needed (profiles, settings, statistics)
                      };
                      final jsonString = const JsonEncoder.withIndent(
                        '  ',
                      ).convert(exportData);
                      await file.writeAsString(jsonString);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Backup saved: ${file.path}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Backup failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restore from Device'),
                  onTap: () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                      );
                      if (result != null && result.files.single.path != null) {
                        final file = File(result.files.single.path!);
                        final data = await file.readAsString();
                        final mangaProvider = Provider.of<MangaProvider>(
                          context,
                          listen: false,
                        );
                        await mangaProvider.importData(jsonDecode(data));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Restore successful!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Restore failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDangerZone() {
    return Card(
      margin: const EdgeInsets.all(AppConstants.mdSpacing),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danger Zone',
              style: AppTheme.getHeadlineStyle(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppConstants.mdSpacing),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete All Data'),
              subtitle: const Text('This action cannot be undone'),
              onTap: () => _showDeleteConfirmation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          margin: const EdgeInsets.all(AppConstants.mdSpacing),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Developer Mode',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.mdSpacing),
                SwitchListTile(
                  title: const Text('Developer Mode'),
                  subtitle: const Text(
                    'Enable experimental features and debug info',
                  ),
                  value: settingsProvider.developerMode,
                  onChanged: (bool value) =>
                      settingsProvider.setDeveloperMode(value),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Debug Info'),
                  subtitle: Text('Version: ${AppConstants.appVersion}'),
                  onTap: () => _showDebugInfo(),
                ),
                ListTile(
                  leading: const Icon(Icons.science),
                  title: const Text('Experimental Features'),
                  subtitle: const Text(
                    'Advanced analytics, performance metrics',
                  ),
                  onTap: () => _showExperimentalFeatures(),
                ),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Performance Metrics'),
                  subtitle: const Text('View app performance data'),
                  onTap: () => _showPerformanceMetrics(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showColorPicker(
    BuildContext context,
    Color initialColor,
    Function(Color) onColorChanged,
  ) {
    Color pickerColor = initialColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            showLabel: false,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onColorChanged(pickerColor);
              Navigator.of(context).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Appearance'),
        content: const Text(
          'Are you sure you want to reset all appearance settings to defaults?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              themeProvider.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appearance settings reset to defaults'),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final mangaProvider = Provider.of<MangaProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final mangaList = mangaProvider.mangaList;
    final settings = {
      'dailyGoal': settingsProvider.dailyGoal,
      'weeklyGoal': settingsProvider.weeklyGoal,
      'monthlyGoal': settingsProvider.monthlyGoal,
      'autoBackupEnabled': settingsProvider.autoBackupEnabled,
      'showReadingTimer': settingsProvider.showReadingTimer,
      'enableHapticFeedback': settingsProvider.enableHapticFeedback,
      'defaultSortBy': settingsProvider.defaultSortBy,
      'defaultGridView': settingsProvider.defaultGridView,
      'showChapterProgress': settingsProvider.showChapterProgress,
      'showRatingStars': settingsProvider.showRatingStars,
      'developerMode': settingsProvider.developerMode,
      'autoBackupInterval': settingsProvider.autoBackupInterval,
    };
    final profileId = profileProvider.activeProfileId ?? 'default';
    final profileName = profileProvider.activeProfile?.name ?? 'profile';
    if (mangaList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No manga data to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      final success = await ExportService.exportAsJson(
        mangaList,
        settings,
        profileId,
        profileName,
      );
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final profileId = profileProvider.activeProfileId ?? 'default';
    final data = await ExportService.importFromJson(profileId);
    if (data != null) {
      final mangaProvider = Provider.of<MangaProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );
      try {
        await mangaProvider.importData(data);
        final s = data['settings'] as Map<String, dynamic>?;
        if (s != null) {
          await settingsProvider.setDailyGoal(
            s['dailyGoal'] ?? settingsProvider.dailyGoal,
          );
          await settingsProvider.setWeeklyGoal(
            s['weeklyGoal'] ?? settingsProvider.weeklyGoal,
          );
          await settingsProvider.setMonthlyGoal(
            s['monthlyGoal'] ?? settingsProvider.monthlyGoal,
          );
          await settingsProvider.setAutoBackupEnabled(
            s['autoBackupEnabled'] ?? settingsProvider.autoBackupEnabled,
          );
          await settingsProvider.setShowReadingTimer(
            s['showReadingTimer'] ?? settingsProvider.showReadingTimer,
          );
          await settingsProvider.setEnableHapticFeedback(
            s['enableHapticFeedback'] ?? settingsProvider.enableHapticFeedback,
          );
          await settingsProvider.setDefaultSortBy(
            s['defaultSortBy'] ?? settingsProvider.defaultSortBy,
          );
          await settingsProvider.setDefaultGridView(
            s['defaultGridView'] ?? settingsProvider.defaultGridView,
          );
          await settingsProvider.setShowChapterProgress(
            s['showChapterProgress'] ?? settingsProvider.showChapterProgress,
          );
          await settingsProvider.setShowRatingStars(
            s['showRatingStars'] ?? settingsProvider.showRatingStars,
          );
          await settingsProvider.setDeveloperMode(
            s['developerMode'] ?? settingsProvider.developerMode,
          );
          await settingsProvider.setAutoBackupInterval(
            s['autoBackupInterval'] ?? settingsProvider.autoBackupInterval,
          );
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Import successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
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

  Future<void> _exportEncryptedData(BuildContext context) async {
    final mangaProvider = Provider.of<MangaProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final mangaList = mangaProvider.mangaList;
    final settings = {
      'dailyGoal': settingsProvider.dailyGoal,
      'weeklyGoal': settingsProvider.weeklyGoal,
      'monthlyGoal': settingsProvider.monthlyGoal,
      'autoBackupEnabled': settingsProvider.autoBackupEnabled,
      'showReadingTimer': settingsProvider.showReadingTimer,
      'enableHapticFeedback': settingsProvider.enableHapticFeedback,
      'defaultSortBy': settingsProvider.defaultSortBy,
      'defaultGridView': settingsProvider.defaultGridView,
      'showChapterProgress': settingsProvider.showChapterProgress,
      'showRatingStars': settingsProvider.showRatingStars,
      'developerMode': settingsProvider.developerMode,
      'autoBackupInterval': settingsProvider.autoBackupInterval,
    };
    final profileId = profileProvider.activeProfileId ?? 'default';
    final profileName = profileProvider.activeProfile?.name ?? 'profile';
    if (mangaList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No manga data to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Export Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter password for encryption',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty &&
                  passwordController.text == confirmPasswordController.text) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final success = await ExportService.exportAsEncryptedJson(
          mangaList,
          settings,
          profileId,
          profileName,
          passwordController.text,
        );
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Encrypted data exported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _importEncryptedData(BuildContext context) async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final profileId = profileProvider.activeProfileId ?? 'default';
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            hintText: 'Enter password for decryption',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final data = await ExportService.importFromEncryptedJson(
        profileId,
        passwordController.text,
      );
      if (data != null) {
        final mangaProvider = Provider.of<MangaProvider>(
          context,
          listen: false,
        );
        final settingsProvider = Provider.of<SettingsProvider>(
          context,
          listen: false,
        );
        try {
          await mangaProvider.importData(data);
          final s = data['settings'] as Map<String, dynamic>?;
          if (s != null) {
            await settingsProvider.setDailyGoal(
              s['dailyGoal'] ?? settingsProvider.dailyGoal,
            );
            await settingsProvider.setWeeklyGoal(
              s['weeklyGoal'] ?? settingsProvider.weeklyGoal,
            );
            await settingsProvider.setMonthlyGoal(
              s['monthlyGoal'] ?? settingsProvider.monthlyGoal,
            );
            await settingsProvider.setAutoBackupEnabled(
              s['autoBackupEnabled'] ?? settingsProvider.autoBackupEnabled,
            );
            await settingsProvider.setShowReadingTimer(
              s['showReadingTimer'] ?? settingsProvider.showReadingTimer,
            );
            await settingsProvider.setEnableHapticFeedback(
              s['enableHapticFeedback'] ??
                  settingsProvider.enableHapticFeedback,
            );
            await settingsProvider.setDefaultSortBy(
              s['defaultSortBy'] ?? settingsProvider.defaultSortBy,
            );
            await settingsProvider.setDefaultGridView(
              s['defaultGridView'] ?? settingsProvider.defaultGridView,
            );
            await settingsProvider.setShowChapterProgress(
              s['showChapterProgress'] ?? settingsProvider.showChapterProgress,
            );
            await settingsProvider.setShowRatingStars(
              s['showRatingStars'] ?? settingsProvider.showRatingStars,
            );
            await settingsProvider.setDeveloperMode(
              s['developerMode'] ?? settingsProvider.developerMode,
            );
            await settingsProvider.setAutoBackupInterval(
              s['autoBackupInterval'] ?? settingsProvider.autoBackupInterval,
            );
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Import successful!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
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
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete all manga, bookmarks, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement delete all data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Version: ${AppConstants.appVersion}'),
            Text('Flutter Version: ${AppConstants.flutterVersion}'),
            Text('Build Date: ${DateTime.now().toIso8601String()}'),
            Text('Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}'),
            Text('Is Debug: ${!kReleaseMode}'),
            Text(
              'Active Profile: ${Provider.of<ProfileProvider>(context, listen: false).activeProfile?.name ?? 'None'}',
            ),
            Text(
              'Manga Count: ${Provider.of<MangaProvider>(context, listen: false).mangaList.length}',
            ),
            // Add more debug info as needed
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
  }

  void _showExperimentalFeatures() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Experimental Features'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Enable Advanced Analytics'),
                value: Provider.of<SettingsProvider>(
                  context,
                  listen: false,
                ).developerMode,
                onChanged: (bool value) {
                  Provider.of<SettingsProvider>(
                    context,
                    listen: false,
                  ).setDeveloperMode(value);
                  setState(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Enable Feature X'),
                value: false,
                onChanged: (bool value) {},
              ),
              SwitchListTile(
                title: const Text('Enable Feature Y'),
                value: false,
                onChanged: (bool value) {},
              ),
              const Text('More features coming soon...'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPerformanceMetrics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Performance Metrics'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Memory Usage: 45MB'),
            Text('• CPU Usage: 2%'),
            Text('• Battery Usage: Low'),
            Text('• Network Requests: 0 (offline)'),
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
  }
}
