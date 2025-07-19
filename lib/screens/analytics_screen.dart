import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manga_provider.dart';
import '../providers/settings_provider.dart';
import '../models/manga.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'All Time';
  final List<String> _periods = [
    'All Time',
    'This Year',
    'This Month',
    'This Week',
  ];

  @override
  Widget build(BuildContext context) {
    final mangaProvider = Provider.of<MangaProvider>(context);
    final mangaList = mangaProvider.mangaList;
    final totalManga = mangaList.length;
    final totalChapters = mangaList.fold<int>(
      0,
      (sum, m) => sum + m.currentChapter,
    );
    final totalReadingSessions = mangaList.fold<int>(
      0,
      (sum, m) => sum + m.history.length,
    );
    final totalMinutes = mangaList.fold<int>(
      0,
      (sum, m) =>
          sum +
          m.history.fold<int>(0, (s, h) => s + (h['duration'] as int? ?? 0)),
    );
    final totalHours = (totalMinutes / 60).toStringAsFixed(1);
    final readingStreak = mangaProvider.readingStreak;
    final today = DateTime.now();
    final firstSession = mangaList.expand((m) => m.history).isNotEmpty
        ? mangaList
              .expand((m) => m.history)
              .map((h) => DateTime.parse(h['date']))
              .reduce((a, b) => a.isBefore(b) ? a : b)
        : today;
    final daysActive = today.difference(firstSession).inDays + 1;
    final avgChaptersPerDay = daysActive > 0
        ? (totalChapters / daysActive).toStringAsFixed(2)
        : '0';
    final mostReadManga = mangaList.isNotEmpty
        ? mangaList.reduce(
            (a, b) => a.currentChapter > b.currentChapter ? a : b,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Analytics as CSV',
            onPressed: () => _exportAnalyticsCsv(context, mangaList),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    children: [
                      _statTile('Total Manga', '$totalManga'),
                      _statTile('Total Chapters', '$totalChapters'),
                      _statTile('Total Sessions', '$totalReadingSessions'),
                      _statTile('Total Time', '$totalHours h'),
                      _statTile('Reading Streak', '$readingStreak days'),
                      _statTile('Avg Chapters/Day', '$avgChaptersPerDay'),
                      if (mostReadManga != null)
                        _statTile('Most Read', mostReadManga.title),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildReadingStreakCalendar(mangaList),
          _buildTagTrendChart(mangaList),
          _buildReadingVelocityChart(mangaList),
          _buildSessionDurationSummary(mangaList),
          _buildSessionDurationHistogram(mangaList),
          _buildCompletionVelocityHistogram(mangaList),
          _buildPeriodSelector(),
          const SizedBox(height: AppConstants.lgSpacing),
          _buildOverviewCards(),
          const SizedBox(height: AppConstants.lgSpacing),
          _buildStatusDistribution(),
          const SizedBox(height: AppConstants.lgSpacing),
          _buildRatingDistribution(),
          const SizedBox(height: AppConstants.lgSpacing),
          _buildReadingProgress(),
          const SizedBox(height: AppConstants.lgSpacing),
          _buildTopTags(),
          const SizedBox(height: AppConstants.lgSpacing),
          _buildReadingGoals(),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.mdSpacing),
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  foregroundColor: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  elevation: isSelected ? 2 : 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final stats = _calculateStats(provider.mangaList, provider);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.mdSpacing,
          mainAxisSpacing: AppConstants.mdSpacing,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Manga',
              '${stats['totalManga']}',
              Icons.book,
              Colors.blue,
            ),
            _buildStatCard(
              'Chapters Read',
              '${stats['totalChapters']}',
              Icons.menu_book,
              Colors.green,
            ),
            _buildStatCard(
              'Average Rating',
              '${stats['averageRating']}',
              Icons.star,
              Colors.amber,
            ),
            _buildStatCard(
              'Reading Streak',
              '${stats['readingStreak']} days',
              Icons.local_fire_department,
              Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppConstants.smSpacing),
            Text(
              value,
              style: AppTheme.getHeadlineStyle(context).copyWith(
                fontSize: 24,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.xsSpacing),
            Text(
              title,
              style: AppTheme.getBodyStyle(context).copyWith(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistribution() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final statusData = _getStatusDistribution(provider.mangaList);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Distribution',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.mdSpacing),
                ...statusData.map((data) => _buildStatusBar(data)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(Map<String, dynamic> data) {
    final status = data['status'] as String;
    final count = data['count'] as int;
    final percentage = data['percentage'] as double;
    final color = data['color'] as Color;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppConstants.smSpacing),
              Expanded(
                child: Text(
                  status,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final ratingData = _getRatingDistribution(provider.mangaList);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rating Distribution',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.mdSpacing),
                ...ratingData.map((data) => _buildRatingBar(data)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingBar(Map<String, dynamic> data) {
    final rating = data['rating'] as int;
    final count = data['count'] as int;
    final percentage = data['percentage'] as double;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smSpacing),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 12,
                    color: Colors.amber,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.smSpacing),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.amber.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: AppConstants.smSpacing),
          SizedBox(
            width: 50,
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingProgress() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final progressData = _getReadingProgress(provider.mangaList);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reading Progress',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.mdSpacing),
                ...progressData.map((data) => _buildProgressBar(data)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> data) {
    final title = data['title'] as String;
    final current = data['current'] as int;
    final total = data['total'] as int;
    final percentage = data['percentage'] as double;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$current/$total (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Theme.of(
              context,
            ).primaryColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTags() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final tagData = _getTopTags(provider.mangaList);

        if (tagData.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Tags',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.mdSpacing),
                Wrap(
                  spacing: AppConstants.smSpacing,
                  runSpacing: AppConstants.smSpacing,
                  children: tagData.take(10).map((data) {
                    final tag = data['tag'] as String;
                    final count = data['count'] as int;
                    return Chip(
                      label: Text('$tag ($count)'),
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadingGoals() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Consumer<MangaProvider>(
          builder: (context, mangaProvider, child) {
            final stats = _calculateStats(
              mangaProvider.mangaList,
              mangaProvider,
            );
            final dailyProgress =
                (stats['dailyChapters'] / settingsProvider.dailyGoal * 100)
                    .clamp(0.0, 100.0);
            final weeklyProgress =
                (stats['weeklyChapters'] / settingsProvider.weeklyGoal * 100)
                    .clamp(0.0, 100.0);
            final monthlyProgress =
                (stats['monthlyChapters'] / settingsProvider.monthlyGoal * 100)
                    .clamp(0.0, 100.0);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mdSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reading Goals',
                      style: AppTheme.getHeadlineStyle(
                        context,
                      ).copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppConstants.mdSpacing),
                    _buildGoalProgress(
                      'Daily',
                      dailyProgress,
                      stats['dailyChapters'],
                      settingsProvider.dailyGoal,
                    ),
                    const SizedBox(height: AppConstants.smSpacing),
                    _buildGoalProgress(
                      'Weekly',
                      weeklyProgress,
                      stats['weeklyChapters'],
                      settingsProvider.weeklyGoal,
                    ),
                    const SizedBox(height: AppConstants.smSpacing),
                    _buildGoalProgress(
                      'Monthly',
                      monthlyProgress,
                      stats['monthlyChapters'],
                      settingsProvider.monthlyGoal,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGoalProgress(
    String period,
    double percentage,
    int current,
    int goal,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(period, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              '$current/$goal chapters',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage >= 100 ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildReadingStreakCalendar(List<Manga> mangaList) {
    // Build a map of DateTime -> chapters read for the current year
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final yearEnd = DateTime(now.year, 12, 31);
    final Map<DateTime, int> chaptersPerDay = {};
    for (final manga in mangaList) {
      for (final session in manga.history) {
        final date = DateTime.parse(session['date']);
        if (date.year == now.year) {
          final day = DateTime(date.year, date.month, date.day);
          chaptersPerDay[day] =
              (chaptersPerDay[day] ?? 0) +
              (session['chaptersRead'] as int? ?? 1);
        }
      }
    }
    // Find max chapters in a day for color scaling
    final maxChapters = chaptersPerDay.values.isEmpty
        ? 1
        : chaptersPerDay.values.reduce((a, b) => a > b ? a : b);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Streak Calendar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TableCalendar(
              firstDay: yearStart,
              lastDay: yearEnd,
              focusedDay: now,
              headerVisible: true,
              calendarFormat: CalendarFormat.month,
              daysOfWeekVisible: false,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final chapters = chaptersPerDay[day];
                  if (chapters != null && chapters > 0) {
                    final intensity = (chapters / maxChapters).clamp(0.15, 1.0);
                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(intensity),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              calendarStyle: CalendarStyle(
                isTodayHighlighted: false,
                outsideDaysVisible: false,
                defaultTextStyle: const TextStyle(fontSize: 10),
              ),
              onDaySelected: (selectedDay, focusedDay) {},
            ),
            const SizedBox(height: 8),
            Text(
              'Darker green = more chapters read. White = no reading.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagTrendChart(List<Manga> mangaList) {
    final now = DateTime.now();
    final Map<String, int> tagChapters = {};
    for (final manga in mangaList) {
      for (final session in manga.history) {
        final date = DateTime.parse(session['date']);
        if (date.year == now.year) {
          final chapters = session['chaptersRead'] as int? ?? 1;
          for (final tag in manga.tags) {
            tagChapters[tag] = (tagChapters[tag] ?? 0) + chapters;
          }
        }
      }
    }
    final sortedTags = tagChapters.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(5).toList();
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < topTags.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: topTags[i].value.toDouble(),
              color: Colors.green,
            ),
          ],
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Genres/Tags (Chapters Read, This Year)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  alignment: BarChartAlignment.spaceAround,
                  maxY: barGroups.isNotEmpty
                      ? barGroups
                                .map((g) => g.barRods[0].toY)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2
                      : 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        interval: 1,
                        showTitles: true,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < topTags.length) {
                            return Text(
                              topTags[idx].key,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Shows the top 5 tags/genres by chapters read this year.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingVelocityChart(List<Manga> mangaList) {
    final now = DateTime.now();
    final Map<int, int> weekChapters = {};
    for (final manga in mangaList) {
      for (final session in manga.history) {
        final date = DateTime.parse(session['date']);
        if (date.year == now.year) {
          final week = int.parse(_weekOfYear(date));
          weekChapters[week] =
              (weekChapters[week] ?? 0) +
              (session['chaptersRead'] as int? ?? 1);
        }
      }
    }
    final spots = List.generate(
      53,
      (i) => FlSpot((i + 1).toDouble(), (weekChapters[i + 1] ?? 0).toDouble()),
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Velocity (Chapters/Week, This Year)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minY: 0,
                  maxY:
                      spots.map((d) => d.y).reduce((a, b) => a > b ? a : b) *
                      1.2,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        interval: 1,
                        showTitles: true,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value % 10 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Shows chapters read per week for the current year.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDurationSummary(List<Manga> mangaList) {
    final durations = <int>[];
    for (final manga in mangaList) {
      for (final session in manga.history) {
        final duration = session['duration'] as int? ?? 0;
        if (duration > 0) durations.add(duration);
      }
    }
    if (durations.isEmpty) return const SizedBox.shrink();
    final avg = (durations.reduce((a, b) => a + b) / durations.length).round();
    final min = durations.reduce((a, b) => a < b ? a : b);
    final max = durations.reduce((a, b) => a > b ? a : b);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _durationCard('Average', avg),
            _durationCard('Shortest', min),
            _durationCard('Longest', max),
          ],
        ),
      ),
    );
  }

  Widget _durationCard(String label, int minutes) {
    return Column(
      children: [
        Text(
          '$minutes min',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSessionDurationHistogram(List<Manga> mangaList) {
    final durations = <int>[];
    for (final manga in mangaList) {
      for (final session in manga.history) {
        final duration = session['duration'] as int? ?? 0;
        if (duration > 0) durations.add(duration);
      }
    }
    if (durations.isEmpty) return const SizedBox.shrink();
    final bins = <int, int>{};
    for (final d in durations) {
      final bin = ((d / 10).floor() * 10).toInt();
      bins[bin] = (bins[bin] ?? 0) + 1;
    }
    final data = bins.entries.map((e) => _DurationBin(e.key, e.value)).toList()
      ..sort((a, b) => a.bin.compareTo(b.bin));
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < data.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[i].count.toDouble(),
              color: Colors.purple,
            ),
          ],
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Duration Histogram (Minutes)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  alignment: BarChartAlignment.spaceAround,
                  maxY: barGroups.isNotEmpty
                      ? barGroups
                                .map((g) => g.barRods[0].toY)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2
                      : 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        interval: 1,
                        showTitles: true,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < data.length) {
                            return Text(
                              '${data[idx].bin}-${data[idx].bin + 9}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Shows the distribution of reading session durations.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionVelocityHistogram(List<Manga> mangaList) {
    final durations = <int>[];
    for (final manga in mangaList) {
      if (manga.startDate != null && manga.finishDate != null) {
        final days = manga.finishDate!.difference(manga.startDate!).inDays;
        if (days >= 0) durations.add(days);
      }
    }
    if (durations.isEmpty) return const SizedBox.shrink();
    final bins = <int, int>{};
    for (final d in durations) {
      final bin = ((d / 5).floor() * 5).toInt();
      bins[bin] = (bins[bin] ?? 0) + 1;
    }
    final data =
        bins.entries.map((e) => _CompletionBin(e.key, e.value)).toList()
          ..sort((a, b) => a.bin.compareTo(b.bin));
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < data.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[i].count.toDouble(),
              color: Colors.deepOrange,
            ),
          ],
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion Velocity (Days to Finish Manga)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  alignment: BarChartAlignment.spaceAround,
                  maxY: barGroups.isNotEmpty
                      ? barGroups
                                .map((g) => g.barRods[0].toY)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2
                      : 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        interval: 1,
                        showTitles: true,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < data.length) {
                            return Text(
                              '${data[idx].bin}-${data[idx].bin + 4}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Shows how quickly manga are completed (lower = faster).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _weekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final days = date.difference(firstDay).inDays;
    return ((days + firstDay.weekday) / 7).ceil().toString();
  }

  Map<String, dynamic> _calculateStats(
    List<Manga> mangaList,
    MangaProvider provider,
  ) {
    final totalManga = mangaList.length;
    final totalChapters = mangaList.fold(0, (sum, m) => sum + m.currentChapter);
    final ratedManga = mangaList.where((m) => m.rating > 0).toList();
    final averageRating = ratedManga.isNotEmpty
        ? ratedManga.map((m) => m.rating).reduce((a, b) => a + b) /
              ratedManga.length
        : 0.0;

    // Real data for reading streak and period-based stats
    final readingStreak = provider.readingStreak;
    final dailyChapters = provider.dailyChaptersRead;
    final weeklyChapters = provider.weeklyChaptersRead;
    final monthlyChapters = provider.monthlyChaptersRead;

    return {
      'totalManga': totalManga,
      'totalChapters': totalChapters,
      'averageRating': averageRating.toStringAsFixed(1),
      'readingStreak': readingStreak,
      'dailyChapters': dailyChapters,
      'weeklyChapters': weeklyChapters,
      'monthlyChapters': monthlyChapters,
    };
  }

  List<Map<String, dynamic>> _getStatusDistribution(List<Manga> mangaList) {
    final statusCounts = <String, int>{};
    for (var status in AppConstants.mangaStatuses) {
      statusCounts[status] = mangaList.where((m) => m.status == status).length;
    }

    final total = mangaList.length;
    if (total == 0) return [];

    final colors = {
      'Reading': Colors.green,
      'Completed': Colors.blue,
      'On-hold': Colors.orange,
      'Dropped': Colors.red,
      'Plan to Read': Colors.grey,
    };

    return statusCounts.entries
        .map((entry) {
          final percentage = (entry.value / total * 100);
          return {
            'status': entry.key,
            'count': entry.value,
            'percentage': percentage,
            'color': colors[entry.key] ?? Colors.grey,
          };
        })
        .where((data) => (data['count'] as int) > 0)
        .toList();
  }

  List<Map<String, dynamic>> _getRatingDistribution(List<Manga> mangaList) {
    final ratingCounts = <int, int>{};
    for (var i = 1; i <= 5; i++) {
      ratingCounts[i] = mangaList.where((m) => m.rating == i).length;
    }

    final total = mangaList.length;
    if (total == 0) return [];

    return ratingCounts.entries
        .map((entry) {
          final percentage = (entry.value / total * 100);
          return {
            'rating': entry.key,
            'count': entry.value,
            'percentage': percentage,
          };
        })
        .where((data) => (data['count'] as int) > 0)
        .toList();
  }

  List<Map<String, dynamic>> _getReadingProgress(List<Manga> mangaList) {
    final readingManga = mangaList.where((m) => m.status == 'Reading').toList();
    final sortedManga = readingManga.take(5).toList();

    return sortedManga.map((manga) {
      final percentage = (manga.totalChapters ?? 0) > 0
          ? (manga.currentChapter / (manga.totalChapters ?? 1) * 100)
          : 0.0;
      return {
        'title': manga.title,
        'current': manga.currentChapter,
        'total': manga.totalChapters ?? 0,
        'percentage': percentage,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _getTopTags(List<Manga> mangaList) {
    final tagCounts = <String, int>{};
    for (var manga in mangaList) {
      for (var tag in manga.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.map((entry) {
      return {'tag': entry.key, 'count': entry.value};
    }).toList();
  }

  Future<void> _exportAnalyticsCsv(
    BuildContext context,
    List<Manga> mangaList,
  ) async {
    final buffer = StringBuffer();
    // Summary
    buffer.writeln('Summary');
    final totalManga = mangaList.length;
    final totalChapters = mangaList.fold<int>(
      0,
      (sum, m) => sum + m.currentChapter,
    );
    final totalSessions = mangaList.fold<int>(
      0,
      (sum, m) => sum + m.history.length,
    );
    final totalMinutes = mangaList.fold<int>(
      0,
      (sum, m) =>
          sum +
          m.history.fold<int>(0, (s, h) => s + (h['duration'] as int? ?? 0)),
    );
    final totalHours = (totalMinutes / 60).toStringAsFixed(1);
    buffer.writeln('Total Manga,$totalManga');
    buffer.writeln('Total Chapters,$totalChapters');
    buffer.writeln('Total Sessions,$totalSessions');
    buffer.writeln('Total Time (h),$totalHours');
    buffer.writeln();
    // Tag Trends
    buffer.writeln('Top Tags/Genres (Chapters Read, This Year)');
    final now = DateTime.now();
    final Map<String, int> tagChapters = {};
    for (final manga in mangaList) {
      for (final session in manga.history) {
        final date = DateTime.parse(session['date']);
        if (date.year == now.year) {
          final chapters = session['chaptersRead'] as int? ?? 1;
          for (final tag in manga.tags) {
            tagChapters[tag] = (tagChapters[tag] ?? 0) + chapters;
          }
        }
      }
    }
    buffer.writeln('Tag,Chapters');
    tagChapters.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(10)
      ..forEach((e) => buffer.writeln('${e.key},${e.value}'));
    buffer.writeln();
    // Reading Velocity
    buffer.writeln('Reading Velocity (Chapters/Week, This Year)');
    final Map<int, int> weekChapters = {};
    for (final manga in mangaList) {
      for (final session in manga.history) {
        final date = DateTime.parse(session['date']);
        if (date.year == now.year) {
          final week = int.parse(_weekOfYear(date));
          weekChapters[week] =
              (weekChapters[week] ?? 0) +
              (session['chaptersRead'] as int? ?? 1);
        }
      }
    }
    buffer.writeln('Week,Chapters');
    for (var i = 1; i <= 53; i++) {
      buffer.writeln('$i,${weekChapters[i] ?? 0}');
    }
    buffer.writeln();
    // Session Duration
    buffer.writeln('Session Duration (Minutes)');
    buffer.writeln('Duration');
    for (final manga in mangaList) {
      for (final session in manga.history) {
        final duration = session['duration'] as int? ?? 0;
        if (duration > 0) buffer.writeln(duration);
      }
    }
    buffer.writeln();
    // Completion Velocity
    buffer.writeln('Completion Velocity (Days to Finish Manga)');
    buffer.writeln('Days');
    for (final manga in mangaList) {
      if (manga.startDate != null && manga.finishDate != null) {
        final days = manga.finishDate!.difference(manga.startDate!).inDays;
        if (days >= 0) buffer.writeln(days);
      }
    }
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Analytics as CSV',
        fileName:
            'manga_analytics_${DateTime.now().millisecondsSinceEpoch}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );
      if (path != null) {
        final file = File(path);
        await file.writeAsString(buffer.toString());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Analytics exported as CSV!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _DurationBin {
  final int bin;
  final int count;
  _DurationBin(this.bin, this.count);
}

class _CompletionBin {
  final int bin;
  final int count;
  _CompletionBin(this.bin, this.count);
}
