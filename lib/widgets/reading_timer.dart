import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/manga.dart';
import '../providers/manga_provider.dart';

class ReadingTimer extends StatefulWidget {
  const ReadingTimer({super.key});

  @override
  State<ReadingTimer> createState() => _ReadingTimerState();
}

class _ReadingTimerState extends State<ReadingTimer> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    _showSessionDialog();
  }

  void _showSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => _ReadingSessionDialog(
        duration: Duration(seconds: _seconds),
        onSessionLogged: () {
          setState(() {
            _seconds = 0;
          });
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isRunning ? AppConstants.accentColor : Colors.grey[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isRunning ? Icons.timer : Icons.timer_off,
                  size: 20,
                  color: Colors.white,
                  semanticLabel: _isRunning ? 'Timer running' : 'Timer stopped',
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(Duration(seconds: _seconds)),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Start/Stop button
          Semantics(
            button: true,
            label: _isRunning
                ? 'Stop reading session'
                : 'Start reading session',
            child: SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                onPressed: _isRunning ? _stopTimer : _startTimer,
                icon: Icon(
                  _isRunning ? Icons.stop : Icons.play_arrow,
                  color: Colors.white70,
                  size: 28,
                  semanticLabel: _isRunning ? 'Stop' : 'Start',
                ),
                tooltip: _isRunning
                    ? 'Stop reading session'
                    : 'Start reading session',
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingSessionDialog extends StatefulWidget {
  final Duration duration;
  final VoidCallback onSessionLogged;

  const _ReadingSessionDialog({
    required this.duration,
    required this.onSessionLogged,
  });

  @override
  State<_ReadingSessionDialog> createState() => _ReadingSessionDialogState();
}

class _ReadingSessionDialogState extends State<_ReadingSessionDialog> {
  String? _selectedMangaId;
  int _chaptersRead = 1;
  List<Manga> _mangaList = [];

  @override
  void initState() {
    super.initState();
    // Populate manga list immediately
    final provider = Provider.of<MangaProvider>(context, listen: false);
    _mangaList = provider.mangaList;
    if (_mangaList.isNotEmpty) {
      _selectedMangaId = _mangaList.first.id;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _mangaList.isEmpty;
    return AlertDialog(
      title: const Text('Reading Session Complete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Duration: ${_formatDuration(widget.duration)}'),
          const SizedBox(height: 16),
          if (isEmpty)
            const Text('No manga available. Add manga to log a session.'),
          if (!isEmpty) ...[
            const Text('Manga read:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMangaId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select manga',
              ),
              items: _mangaList.map((manga) {
                return DropdownMenuItem(
                  value: manga.id,
                  child: Text(manga.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMangaId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Chapters read:'),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_chaptersRead > 1) {
                      setState(() {
                        _chaptersRead--;
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.remove,
                    semanticLabel: 'Decrease chapters',
                  ),
                  tooltip: 'Decrease chapters',
                  iconSize: 28,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 48, minHeight: 48),
                ),
                Expanded(
                  child: Text(
                    '$_chaptersRead',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _chaptersRead++;
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    semanticLabel: 'Increase chapters',
                  ),
                  tooltip: 'Increase chapters',
                  iconSize: 28,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onSessionLogged();
          },
          child: const Text('Cancel'),
        ),
        if (!isEmpty)
          ElevatedButton(
            onPressed: _selectedMangaId != null
                ? () async {
                    final provider = Provider.of<MangaProvider>(
                      context,
                      listen: false,
                    );
                    await provider.logReadingSession(
                      _selectedMangaId!,
                      _chaptersRead,
                      widget.duration,
                    );
                    Navigator.of(context).pop();
                    widget.onSessionLogged();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reading session logged successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                : null,
            child: const Text('Log Session'),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
