import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & About')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        children: [
          Text(
            'MangaMarks Local',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text('Version 1.0.0', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text('About', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'MangaMarks Local is a 100% offline, private, and customizable manga tracker. All your data stays on your device.',
          ),
          const SizedBox(height: 16),
          Text(
            'Getting Started',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('''1. Add manga using the + button.
2. Edit or delete manga by tapping on them.
3. Use tags, bookmarks, and notes to organize your library.
4. Track your reading progress and analytics.
5. Export/import your data for backup.'''),
          const SizedBox(height: 16),
          Text('FAQ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('''Q: Is my data private?
A: Yes, all data is stored locally and never leaves your device.

Q: Can I use this app offline?
A: Yes, all features work without internet.

Q: How do I backup my data?
A: Use the export/import options in settings.'''),
          const SizedBox(height: 16),
          Text('Tips', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('''- Use tags to quickly filter manga.
- Try bulk editing for fast organization.
- Customize the theme for your comfort.
- Use the reading timer to log sessions.'''),
          const SizedBox(height: 24),
          Text('What’s New', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('''• Local-only backup and restore
• Reading progress calendar view
• High-contrast and custom themes
• Advanced analytics and statistics
• Accessibility and mobile-friendliness
• Performance optimizations for large libraries
• Offline help, changelog, and more!'''),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            onTap: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: 'feedback@mangamarks.local',
                query: 'subject=Feedback for MangaMarks Local',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
        ],
      ),
    );
  }
}
