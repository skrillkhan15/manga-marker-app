import 'package:flutter/material.dart';

class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & About')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Manga Marker',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          const Text(
            'A fully local, privacy-respecting manga tracker and bookmark manager.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Key Features:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• Add, edit, and delete manga bookmarks'),
          const Text('• Automatic duplicate detection and update'),
          const Text('• Tag and status management'),
          const Text('• Reading goals and dashboard statistics'),
          const Text('• Activity log with search and filter'),
          const Text('• Local import/export, backup, and restore'),
          const Text('• PIN lock and user profiles'),
          const Text('• Bulk editing and multi-select'),
          const Text('• Accessibility and responsive UI'),
          const Text('• No cloud, no AI, no external APIs'),
          const SizedBox(height: 24),
          const Text(
            'Usage Tips:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• Tap the + button to add a new bookmark.'),
          const Text('• Long-press a bookmark to enter multi-select mode.'),
          const Text(
            '• Use the dashboard for quick stats and recent activity.',
          ),
          const Text(
            '• Access settings to customize your experience and reset the app.',
          ),
          const Text(
            '• Use the help screen for guidance and feature overview.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Contact & Support:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'For feedback or support, contact: support@mangamarker.local',
          ),
        ],
      ),
    );
  }
}
