import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/sidebar.dart';
import '../widgets/reading_timer.dart';
import 'dashboard_screen.dart';
import 'my_manga_screen.dart';
import 'library_screen.dart';
import 'discover_screen.dart';
import 'bookmarks_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'tags_screen.dart';
import 'settings_screen.dart';
import '../providers/settings_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = AppConstants.dashboardIndex;
  bool _isSidebarCollapsed = false;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MyMangaScreen(),
    const LibraryScreen(),
    const DiscoverScreen(),
    const BookmarksScreen(),
    const HistoryScreen(),
    const AnalyticsScreen(),
    const TagsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: AppConstants.mediumAnimation,
            width: _isSidebarCollapsed
                ? AppConstants.sidebarCollapsedWidth
                : AppConstants.sidebarWidth,
            child: Sidebar(
              selectedIndex: _selectedIndex,
              isCollapsed: _isSidebarCollapsed,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              onToggleCollapse: () {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                });
              },
            ),
          ),

          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top bar with navigation controls
                _buildTopBar(),

                // Main content
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Navigation arrows
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Handle back navigation
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              // Handle forward navigation
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Handle refresh
            },
          ),

          // URL bar
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3A3A3A)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/manga',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reading timer
          if (context.watch<SettingsProvider>().showReadingTimer)
            const ReadingTimer(),
        ],
      ),
    );
  }
}
