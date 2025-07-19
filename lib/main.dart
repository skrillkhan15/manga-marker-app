import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manga_marker/providers/manga_provider.dart';
import 'package:manga_marker/providers/theme_provider.dart';
import 'package:manga_marker/providers/settings_provider.dart';
import 'profile_provider.dart';
import 'package:manga_marker/screens/main_screen.dart';
import 'package:manga_marker/screens/pin_lock_screen.dart';
import 'package:manga_marker/screens/walkthrough_screen.dart';
import 'package:manga_marker/theme/app_theme.dart';
import 'dart:convert'; // Added for json.decode and json.encode

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Legacy data migration
  final prefs = await SharedPreferences.getInstance();
  final profilesJson = prefs.getString('profiles');
  final List<dynamic> profiles = profilesJson != null
      ? (json.decode(profilesJson) as List)
      : [];
  final hasGlobalManga = prefs.containsKey('manga_list');
  final hasGlobalSettings = prefs.containsKey('app_settings');
  bool migrated = false;
  if (profiles.length == 1 && (hasGlobalManga || hasGlobalSettings)) {
    final profileId = profiles[0]['id'] as String;
    // Migrate manga
    if (hasGlobalManga) {
      final mangaJson = prefs.getString('manga_list');
      await prefs.setString('manga_list_' + profileId, mangaJson ?? '');
      await prefs.remove('manga_list');
      migrated = true;
    }
    // Migrate settings
    if (hasGlobalSettings) {
      final settingsJson = prefs.getString('app_settings');
      if (settingsJson != null) {
        final settings = json.decode(settingsJson) as Map<String, dynamic>;
        for (final entry in settings.entries) {
          await prefs.setString(
            '${entry.key}_$profileId',
            json.encode(entry.value),
          );
        }
      }
      await prefs.remove('app_settings');
      migrated = true;
    }
    // Show one-time migration flag
    await prefs.setBool('migration_done', true);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider('default')),
        ChangeNotifierProvider(create: (_) => MangaProvider('default')),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MangaMarksAppWithMigrationDialog(migrated: migrated),
    ),
  );
}

class MangaMarksAppWithMigrationDialog extends StatelessWidget {
  final bool migrated;
  const MangaMarksAppWithMigrationDialog({required this.migrated, super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (migrated) {
          // Show dialog after first frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Data Migration Complete'),
                content: const Text(
                  'Your existing manga and settings have been migrated to your profile for improved privacy and isolation.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
        }
        return const MangaMarksApp();
      },
    );
  }
}

class MangaMarksApp extends StatefulWidget {
  const MangaMarksApp({super.key});

  @override
  State<MangaMarksApp> createState() => _MangaMarksAppState();
}

class _MangaMarksAppState extends State<MangaMarksApp> {
  bool _isUnlocked = false;
  bool _showWalkthrough = false;

  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    final prefs = await SharedPreferences.getInstance();
    final walkthroughCompleted =
        prefs.getBool('walkthrough_completed') ?? false;
    final hasPin = prefs.getString('app_pin') != null;

    if (!walkthroughCompleted) {
      setState(() {
        _showWalkthrough = true;
      });
    } else if (hasPin) {
      // Show PIN lock
      setState(() {
        _isUnlocked = false;
      });
    } else {
      // No PIN, go directly to main screen
      setState(() {
        _isUnlocked = true;
      });
    }
  }

  void _onUnlock() {
    setState(() {
      _isUnlocked = true;
    });
  }

  void _onWalkthroughComplete() {
    setState(() {
      _showWalkthrough = false;
      _isUnlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'MangaMarks Local',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(context, themeProvider),
          darkTheme: AppTheme.darkTheme(context, themeProvider),
          themeMode: themeProvider.themeMode,
          home: _showWalkthrough
              ? WalkthroughScreen(onComplete: _onWalkthroughComplete)
              : !_isUnlocked
              ? PinLockScreen(onUnlock: _onUnlock)
              : const MainScreen(),
        );
      },
    );
  }
}
