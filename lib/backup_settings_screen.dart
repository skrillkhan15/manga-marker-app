import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _backupFrequency = 0; // 0 for disabled, 1 for daily, 7 for weekly, etc.
  DateTime? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadBackupSettings();
  }

  Future<void> _loadBackupSettings() async {
    _backupFrequency = await _dbHelper.getBackupFrequency();
    _lastBackupTime = await _dbHelper.getLastBackupTime();
    setState(() {});
  }

  Future<void> _saveBackupSettings(int frequency) async {
    await _dbHelper.saveBackupFrequency(frequency);
    setState(() {
      _backupFrequency = frequency;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup frequency set to $frequency days.')),
    );
  }

  Future<void> _performBackup() async {
    await _dbHelper.performAutoBackup();
    await _dbHelper.saveLastBackupTime(DateTime.now());
    _loadBackupSettings(); // Reload to update last backup time
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manual backup created!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scheduled Backups',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            DropdownButtonFormField<int>(
              value: _backupFrequency,
              decoration: const InputDecoration(labelText: 'Backup Frequency'),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Disabled')),
                DropdownMenuItem(value: 1, child: Text('Daily')),
                DropdownMenuItem(value: 7, child: Text('Weekly')),
                DropdownMenuItem(value: 30, child: Text('Monthly')),
              ],
              onChanged: (int? newValue) {
                if (newValue != null) {
                  _saveBackupSettings(newValue);
                }
              },
            ),
            const SizedBox(height: 10),
            Text(
              _lastBackupTime == null
                  ? 'Last Backup: Never'
                  : 'Last Backup: ${DateFormat('yyyy-MM-dd HH:mm').format(_lastBackupTime!)}',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _performBackup,
              child: const Text('Perform Manual Backup Now'),
            ),
          ],
        ),
      ),
    );
  }
}
