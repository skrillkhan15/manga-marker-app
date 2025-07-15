import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manga_marker/theme_manager.dart';

class ThemeEditorScreen extends StatelessWidget {
  const ThemeEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Editor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeManager.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeManager.toggleTheme(value);
              },
            ),
            const SizedBox(height: 16.0),
            const Text('Primary Color'),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildColorOption(context, Colors.blue, themeManager),
                _buildColorOption(context, Colors.red, themeManager),
                _buildColorOption(context, Colors.green, themeManager),
                _buildColorOption(context, Colors.purple, themeManager),
                _buildColorOption(context, Colors.orange, themeManager),
                _buildColorOption(context, Colors.teal, themeManager),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, Color color, ThemeManager themeManager) {
    final isSelected = themeManager.primaryColor == color;
    return GestureDetector(
      onTap: () => themeManager.setPrimaryColor(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.secondary, width: 2) : null,
        ),
      ),
    );
  }
}
