import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _totalBookmarks = 0;
  int _favoriteBookmarks = 0;
  int _totalChaptersRead = 0;
  List<ActivityLogEntry> _recentActivities = [];
  Map<String, bool> _visibility = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final bookmarks = await _dbHelper.getBookmarks();
    final visibility = await _dbHelper.getDashboardWidgetVisibility();
    final logs = await _dbHelper.getActivityLog();

    setState(() {
      _totalBookmarks = bookmarks.length;
      _favoriteBookmarks = bookmarks.where((b) => b.rating == 5).length;
      _totalChaptersRead = bookmarks.fold(
        0,
        (sum, b) => sum + b.currentChapter,
      );
      _recentActivities = logs.reversed.take(5).toList();
      _visibility = visibility;
    });
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Semantics(
      label: '[$title]: [$value]',
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
                semanticLabel: title,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Semantics(
      label: 'Recent Activity',
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).primaryColor,
                    semanticLabel: 'Recent Activity',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_recentActivities.isEmpty)
                const Text('No recent activities.')
              else
                Column(
                  children: _recentActivities.map((activity) {
                    return Semantics(
                      label:
                          'Activity: [${activity.description}], [${_formatTimestamp(activity.timestamp)}]',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.description,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    textScaleFactor: MediaQuery.of(
                                      context,
                                    ).textScaleFactor,
                                  ),
                                  Text(
                                    _formatTimestamp(activity.timestamp),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                    textScaleFactor: MediaQuery.of(
                                      context,
                                    ).textScaleFactor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;

            final widgets = <Widget>[];

            if (_visibility['totalBookmarks'] == true) {
              widgets.add(
                _buildStatCard(
                  Icons.bookmark,
                  'Total Bookmarks',
                  _totalBookmarks.toString(),
                ),
              );
            }

            if (_visibility['favoriteBookmarks'] == true) {
              widgets.add(
                _buildStatCard(
                  Icons.favorite,
                  'Favorite Bookmarks',
                  _favoriteBookmarks.toString(),
                ),
              );
            }

            if (_visibility['totalChaptersRead'] == true) {
              widgets.add(
                _buildStatCard(
                  Icons.menu_book,
                  'Chapters Read',
                  _totalChaptersRead.toString(),
                ),
              );
            }

            if (_visibility['recentActivity'] == true) {
              widgets.add(_buildRecentActivityCard());
            }

            if (isWideScreen) {
              // Grid layout for wider screens
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: widgets,
                ),
              );
            } else {
              // List layout for narrow screens
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(children: widgets),
              );
            }
          },
        ),
      ),
    );
  }
}
