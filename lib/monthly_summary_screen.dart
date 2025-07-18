import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';
import 'package:intl/intl.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  final dbHelper = DatabaseHelper();

  Map<String, MonthlySummary> monthlySummaries = {};
  List<Bookmark> bookmarks = []; // <-- Store bookmarks list here

  @override
  void initState() {
    super.initState();
    _loadMonthlySummaries();
  }

  Future<void> _loadMonthlySummaries() async {
    final fetchedBookmarks = await dbHelper.getBookmarks();
    final Map<String, MonthlySummary> summaries = {};

    for (var bookmark in fetchedBookmarks) {
      final monthKey = DateFormat('yyyy-MM').format(bookmark.lastUpdated);
      summaries.putIfAbsent(monthKey, () => MonthlySummary(monthKey: monthKey));
      summaries[monthKey]!.totalBookmarks++;
      summaries[monthKey]!.totalChaptersRead += bookmark.currentChapter;
      if (bookmark.status == 'Completed') {
        summaries[monthKey]!.completedManga++;
      }
    }

    setState(() {
      bookmarks = fetchedBookmarks; // <-- Fix applied here
      monthlySummaries = summaries;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedMonths = monthlySummaries.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Summaries')),
      body: monthlySummaries.isEmpty
          ? const Center(child: Text('No monthly summaries yet.'))
          : ListView.builder(
              itemCount: sortedMonths.length,
              itemBuilder: (context, index) {
                final monthKey = sortedMonths[index];
                final summary = monthlySummaries[monthKey]!;
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthKey,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8.0),
                        Text('Total Bookmarks: ${summary.totalBookmarks}'),
                        Text('Completed Manga: ${summary.completedManga}'),
                        Text(
                          'Total Chapters Read: ${summary.totalChaptersRead}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MonthlySummary {
  final String monthKey;
  int totalBookmarks;
  int completedManga;
  int totalChaptersRead;

  MonthlySummary({
    required this.monthKey,
    this.totalBookmarks = 0,
    this.completedManga = 0,
    this.totalChaptersRead = 0,
  });
}
