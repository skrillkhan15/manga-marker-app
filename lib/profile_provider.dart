import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class ProfileProvider extends ChangeNotifier {
  List<Profile> _profiles = [];
  String? _activeProfileId;

  List<Profile> get profiles => _profiles;
  Profile? get activeProfile =>
      _profiles.firstWhereOrNull((p) => p.id == _activeProfileId);
  String? get activeProfileId => _activeProfileId;

  ProfileProvider() {
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString('profiles');
    final activeId = prefs.getString('active_profile_id');
    if (profilesJson != null) {
      final List<dynamic> list = json.decode(profilesJson);
      _profiles = list.map((e) => Profile.fromMap(e)).toList();
    }
    _activeProfileId = activeId;
    notifyListeners();
  }

  Future<void> addProfile(String name, String avatarPath) async {
    final newProfile = Profile(
      id: const Uuid().v4(),
      name: name,
      avatarPath: avatarPath,
    );
    _profiles.add(newProfile);
    await _saveProfiles();
    notifyListeners();
  }

  Future<void> deleteProfile(String id) async {
    _profiles.removeWhere((p) => p.id == id);
    if (_activeProfileId == id && _profiles.isNotEmpty) {
      _activeProfileId = _profiles.first.id;
    }
    await _saveProfiles();
    notifyListeners();
  }

  Future<void> switchProfile(String id) async {
    _activeProfileId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_profile_id', id);
    notifyListeners();
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _profiles.map((e) => e.toMap()).toList();
    await prefs.setString('profiles', json.encode(list));
    if (_activeProfileId != null) {
      await prefs.setString('active_profile_id', _activeProfileId!);
    }
  }
}
