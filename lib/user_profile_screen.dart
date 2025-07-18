import 'package:flutter/material.dart';
import 'package:manga_marker/auth_manager.dart';

class UserProfileScreen extends StatefulWidget {
  final void Function(String profileName) onProfileSelected;
  const UserProfileScreen({super.key, required this.onProfileSelected});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthManager _authManager = AuthManager();
  List<String> _profiles = [];
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await _authManager.getAllUserProfiles();
    setState(() {
      _profiles = profiles;
    });
  }

  Future<void> _createProfile() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() {
        _error = 'Profile name required.';
      });
      return;
    }
    if (_profiles.contains(name)) {
      setState(() {
        _error = 'Profile already exists.';
      });
      return;
    }
    await _authManager.saveUserProfile(name);
    await _loadProfiles();
    widget.onProfileSelected(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a profile:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_profiles.isEmpty)
              const Text('No profiles found. Create one below.'),
            ..._profiles.map(
              (profile) => ListTile(
                title: Text(profile),
                leading: const Icon(Icons.person),
                onTap: () => widget.onProfileSelected(profile),
              ),
            ),
            const Divider(height: 32),
            const Text(
              'Create new profile:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Profile Name'),
              onSubmitted: (_) => _createProfile(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createProfile,
              child: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
