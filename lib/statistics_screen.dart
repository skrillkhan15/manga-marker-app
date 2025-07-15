import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, int> _chaptersReadPerWeek = {};
  Map<String, int> _chaptersReadPerMonth = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final bookmarks = await _dbHelper.getBookmarks();
    _chaptersReadPerWeek = _calculateChaptersReadPerPeriod(bookmarks, Period.week);
    _chaptersReadPerMonth = _calculateChaptersReadPerPeriod(bookmarks, Period.month);
    setState(() {});
  }

  Map<String, int> _calculateChaptersReadPerPeriod(List<Bookmark> bookmarks, Period period) {
    final Map<String, int> chaptersRead = {};

    for (final bookmark in bookmarks) {
      for (final entry in bookmark.history) {
        final timestamp = DateTime.parse(entry['timestamp']);
        final chapter = entry['chapter'] as int;

        String periodKey;
        if (period == Period.week) {
          // Get the start of the week (Monday)
          final startOfWeek = timestamp.subtract(Duration(days: timestamp.weekday - 1));
          periodKey = DateFormat('yyyy-MM-dd').format(startOfWeek);
        } else {
          periodKey = DateFormat('yyyy-MM').format(timestamp);
        }

        chaptersRead.update(periodKey, (value) => value + chapter, ifAbsent: () => chapter);
      }
    }
    return chaptersRead;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapters Read Per Week',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _chaptersReadPerWeek.isEmpty
                ? const Text('No data available for chapters read per week.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _chaptersReadPerWeek.keys.length,
                    itemBuilder: (context, index) {
                      final key = _chaptersReadPerWeek.keys.elementAt(index);
                      final value = _chaptersReadPerWeek[key];
                      return ListTile(
                        title: Text('Week of $key'),
                        trailing: Text('$value chapters'),
                      );
                    },
                  ),
            const SizedBox(height: 20),
            Text(
              'Chapters Read Per Month',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _chaptersReadPerMonth.isEmpty
                ? const Text('No data available for chapters read per month.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _chaptersReadPerMonth.keys.length,
                    itemBuilder: (context, index) {
                      final key = _chaptersReadPerMonth.keys.elementAt(index);
                      final value = _chaptersReadPerMonth[key];
                      return ListTile(
                        title: Text('Month of $key'),
                        trailing: Text('$value chapters'),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

enum Period { week, month }