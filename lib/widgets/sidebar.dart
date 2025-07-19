import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final bool isCollapsed;
  final Function(int) onItemSelected;
  final VoidCallback onToggleCollapse;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onItemSelected,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Column(
        children: [
          // App branding
          _buildBranding(context),

          // Navigation items
          Expanded(child: _buildNavigationItems(context)),

          // Reading session timer
          _buildReadingTimer(context),
        ],
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Logo
          Row(
            children: [
              if (!isCollapsed) ...[
                // Logo icon (three vertical lines)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CustomPaint(painter: LogoPainter()),
                ),
                const SizedBox(width: 12),
                // App name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MangaMarks',
                      style: AppTheme.getHeadlineStyle(
                        context,
                      ).copyWith(fontSize: 18, color: Colors.white),
                    ),
                    Text(
                      'Local',
                      style: AppTheme.getBodyStyle(
                        context,
                      ).copyWith(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ] else ...[
                // Collapsed logo
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CustomPaint(painter: LogoPainter()),
                ),
              ],
            ],
          ),

          if (!isCollapsed) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF3A3A3A)),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    final navigationItems = [
      _NavigationItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        index: AppConstants.dashboardIndex,
      ),
      _NavigationItem(
        icon: Icons.menu_book,
        label: 'My Manga',
        index: AppConstants.myMangaIndex,
      ),
      _NavigationItem(
        icon: Icons.bar_chart,
        label: 'Library',
        index: AppConstants.libraryIndex,
      ),
      _NavigationItem(
        icon: Icons.flash_on,
        label: 'Discover',
        index: AppConstants.discoverIndex,
      ),
      _NavigationItem(
        icon: Icons.bookmark,
        label: 'Bookmarks',
        index: AppConstants.bookmarksIndex,
      ),
      _NavigationItem(
        icon: Icons.history,
        label: 'History',
        index: AppConstants.historyIndex,
      ),
      _NavigationItem(
        icon: Icons.analytics,
        label: 'Analytics',
        index: AppConstants.analyticsIndex,
      ),
      _NavigationItem(
        icon: Icons.local_offer,
        label: 'Tags',
        index: AppConstants.tagsIndex,
      ),
      _NavigationItem(
        icon: Icons.settings,
        label: 'Settings',
        index: AppConstants.settingsIndex,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: navigationItems.length,
      itemBuilder: (context, index) {
        final item = navigationItems[index];
        final isSelected = selectedIndex == item.index;

        return _buildNavigationItem(context, item, isSelected);
      },
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    _NavigationItem item,
    bool isSelected,
  ) {
    return Semantics(
      button: true,
      label: item.label + (isSelected ? ' (selected)' : ''),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onItemSelected(item.index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConstants.primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: isSelected ? Colors.white : Colors.white70,
                    size: 24,
                    semanticLabel: item.label,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTheme.getBodyStyle(context).copyWith(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadingTimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!isCollapsed) ...[
            const Divider(color: Color(0xFF3A3A3A)),
            const SizedBox(height: 16),
          ],
          // Reading session timer button
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              label: 'Start Reading Session Timer',
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle reading session timer
                },
                icon: const Icon(Icons.timer, size: 20, semanticLabel: 'Timer'),
                label: isCollapsed
                    ? const SizedBox.shrink()
                    : const Text('Start Reading Session Timer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(48, 48),
                ),
              ),
            ),
          ),

          if (!isCollapsed) ...[
            const SizedBox(height: 16),
            // Collapse button
            IconButton(
              onPressed: onToggleCollapse,
              icon: const Icon(Icons.chevron_left, color: Colors.white70),
              tooltip: 'Collapse sidebar',
            ),
          ],
        ],
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final int index;

  _NavigationItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final lineWidth = size.width / 4;
    final spacing = lineWidth / 2;

    // Draw three vertical lines of varying heights
    final heights = [size.height, size.height * 0.7, size.height * 0.4];

    for (int i = 0; i < 3; i++) {
      final x = (i + 1) * spacing + i * lineWidth;
      final y = (size.height - heights[i]) / 2;

      canvas.drawLine(Offset(x, y), Offset(x, y + heights[i]), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
