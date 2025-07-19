import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  int _dailyGoal = AppConstants.defaultDailyGoal;
  int _weeklyGoal = AppConstants.defaultWeeklyGoal;
  int _monthlyGoal = AppConstants.defaultMonthlyGoal;
  bool _autoBackupEnabled = true;
  bool _showReadingTimer = true;
  bool _enableHapticFeedback = true;
  String _defaultSortBy = 'recently_updated';
  bool _defaultGridView = true;
  bool _showChapterProgress = true;
  bool _showRatingStars = true;
  bool _developerMode = false;
  String _autoBackupInterval = 'off'; // 'off', 'daily', 'weekly'
  String _profileId;

  int get dailyGoal => _dailyGoal;
  int get weeklyGoal => _weeklyGoal;
  int get monthlyGoal => _monthlyGoal;
  bool get autoBackupEnabled => _autoBackupEnabled;
  bool get showReadingTimer => _showReadingTimer;
  bool get enableHapticFeedback => _enableHapticFeedback;
  String get defaultSortBy => _defaultSortBy;
  bool get defaultGridView => _defaultGridView;
  bool get showChapterProgress => _showChapterProgress;
  bool get showRatingStars => _showRatingStars;
  bool get developerMode => _developerMode;
  String get autoBackupInterval => _autoBackupInterval;

  SettingsProvider(this._profileId) {
    _loadSettings();
  }

  Future<void> setProfile(String profileId) async {
    if (_profileId != profileId) {
      _profileId = profileId;
      await _loadSettings();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _dailyGoal =
        prefs.getInt('daily_goal_$_profileId') ?? AppConstants.defaultDailyGoal;
    _weeklyGoal =
        prefs.getInt('weekly_goal_$_profileId') ??
        AppConstants.defaultWeeklyGoal;
    _monthlyGoal =
        prefs.getInt('monthly_goal_$_profileId') ??
        AppConstants.defaultMonthlyGoal;
    _autoBackupEnabled =
        prefs.getBool('auto_backup_enabled_$_profileId') ?? true;
    _showReadingTimer = prefs.getBool('show_reading_timer_$_profileId') ?? true;
    _enableHapticFeedback =
        prefs.getBool('enable_haptic_feedback_$_profileId') ?? true;
    _defaultSortBy =
        prefs.getString('default_sort_by_$_profileId') ?? 'recently_updated';
    _defaultGridView = prefs.getBool('default_grid_view_$_profileId') ?? true;
    _showChapterProgress =
        prefs.getBool('show_chapter_progress_$_profileId') ?? true;
    _showRatingStars = prefs.getBool('show_rating_stars_$_profileId') ?? true;
    _developerMode = prefs.getBool('developer_mode_$_profileId') ?? false;
    _autoBackupInterval =
        prefs.getString('auto_backup_interval_$_profileId') ?? 'off';

    notifyListeners();
  }

  Future<void> loadSettings() async {
    await _loadSettings();
  }

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal_$_profileId', goal);
    notifyListeners();
  }

  Future<void> setWeeklyGoal(int goal) async {
    _weeklyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weekly_goal_$_profileId', goal);
    notifyListeners();
  }

  Future<void> setMonthlyGoal(int goal) async {
    _monthlyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('monthly_goal_$_profileId', goal);
    notifyListeners();
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    _autoBackupEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_backup_enabled_$_profileId', enabled);
    notifyListeners();
  }

  Future<void> setShowReadingTimer(bool show) async {
    _showReadingTimer = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_reading_timer_$_profileId', show);
    notifyListeners();
  }

  Future<void> setEnableHapticFeedback(bool enabled) async {
    _enableHapticFeedback = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_haptic_feedback_$_profileId', enabled);
    notifyListeners();
  }

  Future<void> setDefaultSortBy(String sortBy) async {
    _defaultSortBy = sortBy;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_sort_by_$_profileId', sortBy);
    notifyListeners();
  }

  Future<void> setDefaultGridView(bool isGrid) async {
    _defaultGridView = isGrid;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('default_grid_view_$_profileId', isGrid);
    notifyListeners();
  }

  Future<void> setShowChapterProgress(bool show) async {
    _showChapterProgress = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_chapter_progress_$_profileId', show);
    notifyListeners();
  }

  Future<void> setShowRatingStars(bool show) async {
    _showRatingStars = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_rating_stars_$_profileId', show);
    notifyListeners();
  }

  Future<void> setDeveloperMode(bool enabled) async {
    _developerMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('developer_mode_$_profileId', enabled);
    notifyListeners();
  }

  Future<void> setAutoBackupInterval(String interval) async {
    _autoBackupInterval = interval;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auto_backup_interval_$_profileId', interval);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _dailyGoal = AppConstants.defaultDailyGoal;
    _weeklyGoal = AppConstants.defaultWeeklyGoal;
    _monthlyGoal = AppConstants.defaultMonthlyGoal;
    _autoBackupEnabled = true;
    _showReadingTimer = true;
    _enableHapticFeedback = true;
    _defaultSortBy = 'recently_updated';
    _defaultGridView = true;
    _showChapterProgress = true;
    _showRatingStars = true;
    _developerMode = false;
    _autoBackupInterval = 'off';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('daily_goal_$_profileId');
    await prefs.remove('weekly_goal_$_profileId');
    await prefs.remove('monthly_goal_$_profileId');
    await prefs.remove('auto_backup_enabled_$_profileId');
    await prefs.remove('show_reading_timer_$_profileId');
    await prefs.remove('enable_haptic_feedback_$_profileId');
    await prefs.remove('default_sort_by_$_profileId');
    await prefs.remove('default_grid_view_$_profileId');
    await prefs.remove('show_chapter_progress_$_profileId');
    await prefs.remove('show_rating_stars_$_profileId');
    await prefs.remove('developer_mode_$_profileId');
    await prefs.remove('auto_backup_interval_$_profileId');
    notifyListeners();
  }
}
