import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import '../providers/manga_provider.dart';
import '../models/manga.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'manga_detail_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert'; // Added for base64Decode

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<MangaProvider>(
      builder: (context, mangaProvider, child) {
        final mangaList = mangaProvider.mangaList;
        final readingDays = <DateTime>{};
        for (final manga in mangaList) {
          for (final session in manga.history) {
            final sessionDate = DateTime.parse(session['date']);
            readingDays.add(
              DateTime(sessionDate.year, sessionDate.month, sessionDate.day),
            );
          }
        }
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.mdSpacing),
                child: TableCalendar(
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: (day) {
                    final d = DateTime(day.year, day.month, day.day);
                    return readingDays.contains(d) ? ['Reading'] : [];
                  },
                ),
              ),
              Expanded(child: _buildHistoryList()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return Consumer<MangaProvider>(
      builder: (context, provider, child) {
        final historyData = _getHistoryData(provider.mangaList);

        if (historyData.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          key: const PageStorageKey('historyList'),
          padding: const EdgeInsets.all(AppConstants.mdSpacing),
          itemCount: historyData.length,
          itemBuilder: (context, index) {
            final entry = historyData[index];
            final manga = entry['manga'] as Manga;
            final date = entry['date'] as DateTime;
            final chaptersRead = entry['chaptersRead'] as int;
            return Card(
              margin: const EdgeInsets.only(bottom: AppConstants.smSpacing),
              child: ListTile(
                leading: manga.coverImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? (manga.coverImage.startsWith('data:image/')
                                  ? Image.memory(
                                      base64Decode(
                                        manga.coverImage.split(',').last,
                                      ),
                                      width: 50,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      manga.coverImage,
                                      width: 50,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 50,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.book,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    ))
                            : Image.file(
                                File(manga.coverImage),
                                width: 50,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.book,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                      )
                    : Container(
                        width: 50,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                title: Text(
                  manga.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${_formatDate(date)} • $chaptersRead chapters',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MangaDetailScreen(manga: manga),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'No reading history',
            style: AppTheme.getHeadlineStyle(context).copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          Text(
            'Start reading manga to see your history here',
            style: AppTheme.getBodyStyle(context).copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getHistoryData(List<Manga> mangaList) {
    final historyData = <Map<String, dynamic>>[];

    // Mock history data - in a real app, this would come from actual reading logs
    for (var manga in mangaList) {
      if (manga.currentChapter > 0) {
        // Add mock reading sessions
        final daysAgo =
            mangaList.indexOf(manga) % 30; // Mock: spread over 30 days
        final date = DateTime.now().subtract(Duration(days: daysAgo));
        final chaptersRead = (manga.currentChapter / 10)
            .ceil(); // Mock: read in chunks

        historyData.add({
          'manga': manga,
          'date': date,
          'chaptersRead': chaptersRead,
        });
      }
    }

    // Sort by date (most recent first)
    historyData.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    return historyData.take(20).toList(); // Limit to 20 most recent entries
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
