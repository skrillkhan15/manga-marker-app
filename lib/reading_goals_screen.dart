import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ReadingGoalsScreen extends StatefulWidget {
  const ReadingGoalsScreen({super.key});

  @override
  State<ReadingGoalsScreen> createState() => _ReadingGoalsScreenState();
}

class _ReadingGoalsScreenState extends State<ReadingGoalsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<ReadingGoal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _dbHelper.getReadingGoals();
    setState(() {
      _goals = goals;
    });
  }

  Future<void> _addOrEditGoal({ReadingGoal? goal}) async {
    String title = goal?.title ?? '';
    int targetValue = goal?.targetValue ?? 0;
    String type = goal?.type ?? 'Chapters';
    DateTime startDate = goal?.startDate ?? DateTime.now();
    DateTime endDate = goal?.endDate ?? DateTime.now().add(const Duration(days: 30));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal == null ? 'Add New Goal' : 'Edit Goal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: title),
                decoration: const InputDecoration(labelText: 'Goal Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                controller: TextEditingController(text: targetValue.toString()),
                decoration: const InputDecoration(labelText: 'Target Value'),
                keyboardType: TextInputType.number,
                onChanged: (value) => targetValue = int.tryParse(value) ?? 0,
              ),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Goal Type'),
                items: <String>['Chapters', 'Manga', 'Minutes'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) type = newValue;
                },
              ),
              ListTile(
                title: Text('Start Date: ${DateFormat('yyyy-MM-dd').format(startDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      startDate = pickedDate;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('End Date: ${DateFormat('yyyy-MM-dd').format(endDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      endDate = pickedDate;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (title.isNotEmpty && targetValue > 0) {
                if (goal == null) {
                  await _dbHelper.addReadingGoal(ReadingGoal(
                    id: const Uuid().v4(),
                    title: title,
                    targetValue: targetValue,
                    type: type,
                    startDate: startDate,
                    endDate: endDate,
                  ));
                } else {
                  goal.title = title;
                  goal.targetValue = targetValue;
                  goal.type = type;
                  goal.startDate = startDate;
                  goal.endDate = endDate;
                  await _dbHelper.updateReadingGoal(goal);
                }
                _loadGoals();
                Navigator.pop(context);
              }
            },
            child: Text(goal == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(String goalId) async {
    await _dbHelper.deleteReadingGoal(goalId);
    _loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Goals'),
      ),
      body: _goals.isEmpty
          ? const Center(
              child: Text('No reading goals yet. Add one!'),
            )
          : ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                return ListTile(
                  title: Text(goal.title),
                  subtitle: Text(
                      'Type: ${goal.type}, Target: ${goal.targetValue}, Current: ${goal.currentValue}\n'
                      '${DateFormat('yyyy-MM-dd').format(goal.startDate)} - ${DateFormat('yyyy-MM-dd').format(goal.endDate)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditGoal(goal: goal),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteGoal(goal.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditGoal(),
        child: const Icon(Icons.add),
      ),
    );
  }
}