import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';
import 'dart:async';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final dbHelper = DatabaseHelper();
  List<ActivityLogEntry> _log = [];
  List<ActivityLogEntry> _filteredLog = [];
  String _searchQuery = '';
  String? _selectedTypeFilter;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadLog() async {
    final log = await dbHelper.getActivityLog();
    setState(() {
      _log = log.reversed.toList(); // Show newest first
      _applyFilter();
    });
  }

  void _applyFilter() {
    _filteredLog = _log.where((entry) {
      final matchesSearch = entry.description.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesType =
          _selectedTypeFilter == null || entry.type == _selectedTypeFilter;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Semantics(
              label: 'Search Activity Log',
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    setState(() {
                      _searchQuery = value;
                      _applyFilter();
                    });
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Semantics(
              label: 'Filter by Type',
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Filter by Type'),
                value: _selectedTypeFilter,
                items:
                    <String>[
                      'Bookmark Added',
                      'Bookmark Updated',
                      'Bookmark Deleted',
                      'Goal Added',
                      'Goal Updated',
                      'Goal Deleted',
                      'Backup Created',
                      'Data Imported',
                      'Data Exported',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTypeFilter = newValue;
                    _applyFilter();
                  });
                },
                hint: const Text('All Types'),
              ),
            ),
          ),
          Expanded(
            child: _filteredLog.isEmpty
                ? const Center(child: Text('No activities found.'))
                : ListView.builder(
                    itemCount: _filteredLog.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredLog[index];
                      return Semantics(
                        label:
                            'Activity: ${entry.description}, at ${entry.timestamp}',
                        child: ListTile(
                          leading: const Icon(
                            Icons.history,
                            semanticLabel: 'Activity',
                          ),
                          title: Text(
                            entry.description,
                            textScaleFactor: MediaQuery.of(
                              context,
                            ).textScaleFactor,
                          ),
                          subtitle: Text(
                            entry.timestamp.toString(),
                            textScaleFactor: MediaQuery.of(
                              context,
                            ).textScaleFactor,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
