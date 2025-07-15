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
  double _averageReadingTime = 0.0;
  String _mostActiveReadingDay = 'N/A';
  Map<String, int> _tagFrequency = {};
  Map<String, double> _tagAverageRating = {};
  Map<String, double> _statusPercentages = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final bookmarks = await _dbHelper.getBookmarks();
    _chaptersReadPerWeek = _calculateChaptersReadPerPeriod(bookmarks, Period.week);
    _chaptersReadPerMonth = _calculateChaptersReadPerPeriod(bookmarks, Period.month);
    _calculateAverageReadingTime(bookmarks);
    _calculateMostActiveReadingDay(bookmarks);
    _calculateTagStatistics(bookmarks);
    _calculateStatusPercentages(bookmarks);
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

  void _calculateAverageReadingTime(List<Bookmark> bookmarks) {
    int totalDuration = 0;
    int sessionCount = 0;

    for (final bookmark in bookmarks) {
      for (final entry in bookmark.history) {
        if (entry.containsKey('duration') && entry['duration'] is int) {
          totalDuration += entry['duration'] as int;
          sessionCount++;
        }
      }
    }

    if (sessionCount > 0) {
      _averageReadingTime = totalDuration / sessionCount;
    } else {
      _averageReadingTime = 0.0;
    }
  }

  void _calculateMostActiveReadingDay(List<Bookmark> bookmarks) {
    final Map<int, int> dayOfWeekCounts = {}; // 1 for Monday, 7 for Sunday

    for (final bookmark in bookmarks) {
      for (final entry in bookmark.history) {
        final timestamp = DateTime.parse(entry['timestamp']);
        final dayOfWeek = timestamp.weekday; // 1 (Monday) through 7 (Sunday)
        dayOfWeekCounts.update(dayOfWeek, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    if (dayOfWeekCounts.isNotEmpty) {
      int maxCount = 0;
      int mostActiveDay = 0;
      dayOfWeekCounts.forEach((day, count) {
        if (count > maxCount) {
          maxCount = count;
          mostActiveDay = day;
        }
      });

      switch (mostActiveDay) {
        case 1:
          _mostActiveReadingDay = 'Monday';
          break;
        case 2:
          _mostActiveReadingDay = 'Tuesday';
          break;
        case 3:
          _mostActiveReadingDay = 'Wednesday';
          break;
        case 4:
          _mostActiveReadingDay = 'Thursday';
          break;
        case 5:
          _mostActiveReadingDay = 'Friday';
          break;
        case 6:
          _mostActiveReadingDay = 'Saturday';
          break;
        case 7:
          _mostActiveReadingDay = 'Sunday';
          break;
        default:
          _mostActiveReadingDay = 'N/A';
      }
    } else {
      _mostActiveReadingDay = 'N/A';
    }
  }

  void _calculateTagStatistics(List<Bookmark> bookmarks) {
    final Map<String, int> tagCounts = {};
    final Map<String, int> tagRatingSums = {};

    for (final bookmark in bookmarks) {
      for (final tag in bookmark.tags) {
        tagCounts.update(tag, (value) => value + 1, ifAbsent: () => 1);
        tagRatingSums.update(tag, (value) => value + bookmark.rating, ifAbsent: () => bookmark.rating);
      }
    }

    _tagFrequency = tagCounts;
    _tagAverageRating = tagRatingSums.map((key, value) => MapEntry(key, value / tagCounts[key]!));
  }

  void _calculateStatusPercentages(List<Bookmark> bookmarks) {
    final Map<String, int> statusCounts = {};
    int totalBookmarks = bookmarks.length;

    if (totalBookmarks == 0) {
      _statusPercentages = {};
      return;
    }

    for (final bookmark in bookmarks) {
      statusCounts.update(bookmark.status, (value) => value + 1, ifAbsent: () => 1);
    }

    _statusPercentages = statusCounts.map((key, value) => MapEntry(key, (value / totalBookmarks) * 100));
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
              'Average Reading Time Per Session:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${_averageReadingTime.toStringAsFixed(2)} minutes',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Most Active Reading Day:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              _mostActiveReadingDay,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            Text(
              'Tag Frequency:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _tagFrequency.isEmpty
                ? const Text('No tag data available.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _tagFrequency.keys.length,
                    itemBuilder: (context, index) {
                      final tag = _tagFrequency.keys.elementAt(index);
                      final count = _tagFrequency[tag];
                      final avgRating = _tagAverageRating[tag]?.toStringAsFixed(2) ?? 'N/A';
                      return ListTile(
                        title: Text('$tag (Count: $count)'),
                        trailing: Text('Avg Rating: $avgRating'),
                      );
                    },
                  ),
            const SizedBox(height: 20),
            Text(
              'Bookmark Status Distribution:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _statusPercentages.isEmpty
                ? const Text('No status data available.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _statusPercentages.keys.length,
                    itemBuilder: (context, index) {
                      final status = _statusPercentages.keys.elementAt(index);
                      final percentage = _statusPercentages[status]?.toStringAsFixed(2) ?? '0.00';
                      return ListTile(
                        title: Text('$status'),
                        trailing: Text('$percentage%'),
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