import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final dbHelper = DatabaseHelper();

  int totalBookmarks = 0;
  int favoriteBookmarks = 0;
  Map<String, int> statusDistribution = {};
  List<Bookmark> bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final allBookmarks = await dbHelper.getBookmarks();
    final statusMap = <String, int>{};

    for (var bookmark in allBookmarks) {
      statusMap.update(
        bookmark.status,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    setState(() {
      bookmarks = allBookmarks;
      totalBookmarks = bookmarks.length;
      favoriteBookmarks = bookmarks.where((b) => b.rating == 5).length;
      statusDistribution = statusMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: bookmarks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Bookmarks: $totalBookmarks',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Favorite Bookmarks (★5): $favoriteBookmarks',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Status Distribution:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ...statusDistribution.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Text('- ${entry.key}: ${entry.value}'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Bookmark Progress:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];
                        final progress = bookmark.totalChapters > 0
                            ? bookmark.currentChapter / bookmark.totalChapters
                            : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookmark.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[300],
                                color: Colors.blue,
                              ),
                              Text('${(progress * 100).toStringAsFixed(0)}%'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
