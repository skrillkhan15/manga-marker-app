import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final dbHelper = DatabaseHelper();
  List<ActivityLogEntry> _log = [];

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  Future<void> _loadLog() async {
    final log = await dbHelper.getActivityLog();
    setState(() {
      _log = log.reversed.toList(); // Show newest first
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
      ),
      body: _log.isEmpty
          ? const Center(child: Text('No activities yet.'))
          : ListView.builder(
              itemCount: _log.length,
              itemBuilder: (context, index) {
                final entry = _log[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(entry.description),
                  subtitle: Text(entry.timestamp.toString()),
                );
              },
            ),
    );
  }
}