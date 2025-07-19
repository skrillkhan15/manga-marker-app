import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'MangaMarks Local';
  static const String appVersion = '1.0.0';
  static const String flutterVersion = '3.16.0';

  // Navigation
  static const int dashboardIndex = 0;
  static const int myMangaIndex = 1;
  static const int libraryIndex = 2;
  static const int discoverIndex = 3;
  static const int bookmarksIndex = 4;
  static const int historyIndex = 5;
  static const int analyticsIndex = 6;
  static const int tagsIndex = 7;
  static const int settingsIndex = 8;

  // Manga Status
  static const List<String> mangaStatuses = [
    'Reading',
    'Completed',
    'On-hold',
    'Dropped',
    'Plan to Read',
  ];

  // Reading Goals
  static const int defaultDailyGoal = 5;
  static const int defaultWeeklyGoal = 25;
  static const int defaultMonthlyGoal = 100;

  // UI Constants
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 70.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double xsSpacing = 4.0;
  static const double smSpacing = 8.0;
  static const double mdSpacing = 16.0;
  static const double lgSpacing = 24.0;
  static const double xlSpacing = 32.0;
  static const double xxlSpacing = 48.0;

  // Colors (will be overridden by theme)
  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFFF59E0B);
  static const Color accentColor = Color(0xFF8B5CF6);

  // Status Colors
  static const Map<String, Color> statusColors = {
    'Reading': Color(0xFF10B981),
    'Completed': Color(0xFF3B82F6),
    'On-hold': Color(0xFFF59E0B),
    'Dropped': Color(0xFFEF4444),
    'Plan to Read': Color(0xFF6B7280),
  };

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String settingsKey = 'app_settings';
  static const String dashboardLayoutKey = 'dashboard_layout';
  static const String readingGoalsKey = 'reading_goals';
  static const String autoBackupKey = 'auto_backup_enabled';

  // File Extensions
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const List<String> supportedDocumentFormats = ['pdf', 'cbz', 'cbr'];

  // Search Keywords
  static const Map<String, String> searchKeywords = {
    'status:': 'Filter by reading status',
    'rating:': 'Filter by rating (e.g., rating:>=8)',
    'tags:': 'Filter by tags',
    'chapters:': 'Filter by chapter count (e.g., chapters:>100)',
    'author:': 'Filter by author name',
    'year:': 'Filter by year',
  };
}
