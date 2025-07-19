import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manga_provider.dart';
import '../providers/settings_provider.dart';
import '../models/manga.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Monthly Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectMonth(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthHeader(),
            const SizedBox(height: AppConstants.lgSpacing),
            _buildOverviewCards(),
            const SizedBox(height: AppConstants.lgSpacing),
            _buildReadingProgress(),
            const SizedBox(height: AppConstants.lgSpacing),
            _buildTopManga(),
            const SizedBox(height: AppConstants.lgSpacing),
            _buildReadingGoals(),
            const SizedBox(height: AppConstants.lgSpacing),
            _buildReadingHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                style: AppTheme.getHeadlineStyle(
                  context,
                ).copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final stats = _calculateMonthlyStats(provider.mangaList);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.mdSpacing,
          mainAxisSpacing: AppConstants.mdSpacing,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Chapters Read',
              '${stats['chaptersRead']}',
              Icons.menu_book,
              Colors.blue,
            ),
            _buildStatCard(
              'Reading Days',
              '${stats['readingDays']}',
              Icons.calendar_month,
              Colors.green,
            ),
            _buildStatCard(
              'Manga Started',
              '${stats['mangaStarted']}',
              Icons.play_arrow,
              Colors.orange,
            ),
            _buildStatCard(
              'Manga Completed',
              '${stats['mangaCompleted']}',
              Icons.check_circle,
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildReadingProgress() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final stats = _calculateMonthlyStats(provider.mangaList);
        final goal = Provider.of<SettingsProvider>(
          context,
          listen: false,
        ).monthlyGoal;
        final progress = goal > 0
            ? (stats['chaptersRead'] / goal * 100).clamp(0.0, 100.0)
            : 0.0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Goal Progress',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.mdSpacing),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${stats['chaptersRead']} / $goal chapters',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${progress.toStringAsFixed(1)}% complete',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 100 ? Colors.green : Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.smSpacing),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 100 ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopManga() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final topManga = _getTopMangaForMonth(provider.mangaList);

        if (topManga.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mdSpacing),
              child: Column(
                children: [
                  Text(
                    'Top Manga This Month',
                    style: AppTheme.getHeadlineStyle(
                      context,
                    ).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppConstants.mdSpacing),
                  const Text('No reading activity this month'),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Manga This Month',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.mdSpacing),
                ...topManga
                    .take(5)
                    .map(
                      (manga) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            manga.title.isNotEmpty
                                ? manga.title[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(manga.title),
                        subtitle: Text('${manga.currentChapter} chapters read'),
                        trailing: Text(
                          manga.status,
                          style: TextStyle(
                            color: AppConstants.statusColors[manga.status],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
            final stats = _calculateMonthlyStats(mangaProvider.mangaList);
            final dailyProgress =
                (stats['dailyChapters'] / settingsProvider.dailyGoal * 100)
                    .clamp(0.0, 100.0);
            final weeklyProgress =
                (stats['weeklyChapters'] / settingsProvider.weeklyGoal * 100)
                    .clamp(0.0, 100.0);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mdSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goal Achievement',
                      style: AppTheme.getHeadlineStyle(
                        context,
                      ).copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppConstants.mdSpacing),
                    _buildGoalItem(
                      'Daily Goal',
                      dailyProgress,
                      stats['dailyChapters'],
                      settingsProvider.dailyGoal,
                    ),
                    const SizedBox(height: AppConstants.smSpacing),
                    _buildGoalItem(
                      'Weekly Goal',
                      weeklyProgress,
                      stats['weeklyChapters'],
                      settingsProvider.weeklyGoal,
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

  Widget _buildReadingHistory() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final history = _getReadingHistoryForMonth(provider.mangaList);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reading History',
                  style: AppTheme.getHeadlineStyle(
                    context,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppConstants.mdSpacing),
                if (history.isEmpty)
                  const Text('No reading sessions this month')
                else
                  ...history
                      .take(10)
                      .map(
                        (session) => ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(session['manga']),
                          subtitle: Text(
                            '${session['chapters']} chapters • ${session['duration']} minutes',
                          ),
                          trailing: Text(session['date']),
                          dense: true,
                        ),
                      ),
              ],
            ),
          ),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(
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

  Widget _buildGoalItem(String title, double progress, int current, int goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
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
          value: progress / 100,
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 100 ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Map<String, dynamic> _calculateMonthlyStats(List<Manga> mangaList) {
    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );

    int chaptersRead = 0;
    int readingDays = 0;
    int mangaStarted = 0;
    int mangaCompleted = 0;
    int dailyChapters = 0;
    int weeklyChapters = 0;

    final readingDaysSet = <DateTime>{};

    for (final manga in mangaList) {
      for (final session in manga.history) {
        final sessionDate = DateTime.parse(session['date']);
        if (sessionDate.isAfter(
              startOfMonth.subtract(const Duration(days: 1)),
            ) &&
            sessionDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          chaptersRead += session['chaptersRead'] as int;
          readingDaysSet.add(
            DateTime(sessionDate.year, sessionDate.month, sessionDate.day),
          );
        }
      }

      // Check if manga was started or completed this month
      if (manga.startDate != null &&
          manga.startDate!.isAfter(
            startOfMonth.subtract(const Duration(days: 1)),
          ) &&
          manga.startDate!.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        mangaStarted++;
      }

      if (manga.finishDate != null &&
          manga.finishDate!.isAfter(
            startOfMonth.subtract(const Duration(days: 1)),
          ) &&
          manga.finishDate!.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        mangaCompleted++;
      }
    }

    readingDays = readingDaysSet.length;

    // Calculate daily and weekly chapters (simplified)
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(now.year, now.month, now.day);

    for (final manga in mangaList) {
      for (final session in manga.history) {
        final sessionDate = DateTime.parse(session['date']);
        if (sessionDate.isAfter(startOfDay.subtract(const Duration(days: 1)))) {
          dailyChapters += session['chaptersRead'] as int;
        }
        if (sessionDate.isAfter(
          startOfWeek.subtract(const Duration(days: 1)),
        )) {
          weeklyChapters += session['chaptersRead'] as int;
        }
      }
    }

    return {
      'chaptersRead': chaptersRead,
      'readingDays': readingDays,
      'mangaStarted': mangaStarted,
      'mangaCompleted': mangaCompleted,
      'dailyChapters': dailyChapters,
      'weeklyChapters': weeklyChapters,
    };
  }

  List<Manga> _getTopMangaForMonth(List<Manga> mangaList) {
    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );

    final mangaStats = <Manga, int>{};

    for (final manga in mangaList) {
      int chaptersThisMonth = 0;
      for (final session in manga.history) {
        final sessionDate = DateTime.parse(session['date']);
        if (sessionDate.isAfter(
              startOfMonth.subtract(const Duration(days: 1)),
            ) &&
            sessionDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          chaptersThisMonth += session['chaptersRead'] as int;
        }
      }
      if (chaptersThisMonth > 0) {
        mangaStats[manga] = chaptersThisMonth;
      }
    }

    final sortedManga = mangaStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedManga.map((e) => e.key).toList();
  }

  List<Map<String, dynamic>> _getReadingHistoryForMonth(List<Manga> mangaList) {
    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );

    final history = <Map<String, dynamic>>[];

    for (final manga in mangaList) {
      for (final session in manga.history) {
        final sessionDate = DateTime.parse(session['date']);
        if (sessionDate.isAfter(
              startOfMonth.subtract(const Duration(days: 1)),
            ) &&
            sessionDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          history.add({
            'manga': manga.title,
            'chapters': session['chaptersRead'],
            'duration': session['duration'],
            'date': '${sessionDate.day}/${sessionDate.month}',
          });
        }
      }
    }

    history.sort((a, b) {
      final aDate = DateTime.parse(a['date'].split('/').reversed.join('-'));
      final bDate = DateTime.parse(b['date'].split('/').reversed.join('-'));
      return bDate.compareTo(aDate);
    });

    return history;
  }
}
