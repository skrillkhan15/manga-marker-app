import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final bookmarks = await _dbHelper.getBookmarks();
    setState(() {
      _totalBookmarks = bookmarks.length;
      _favoriteBookmarks = bookmarks
          .where((b) => b.rating == 5)
          .length; // Assuming 5-star rating means favorite
      _totalChaptersRead = bookmarks.fold(
        0,
        (sum, b) => sum + b.currentChapter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('Total Bookmarks'),
                trailing: Text(_totalBookmarks.toString()),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favorite Bookmarks'),
                trailing: Text(_favoriteBookmarks.toString()),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text('Total Chapters Read'),
                trailing: Text(_totalChaptersRead.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
