import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';

class BookmarkProvider with ChangeNotifier {
  List<Bookmark> _bookmarks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Bookmark> get bookmarks => _bookmarks;

  BookmarkProvider() {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    _bookmarks = await _dbHelper.getBookmarks();
    notifyListeners();
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    // Check if a bookmark with the same URL already exists
    final existingBookmarkIndex = _bookmarks.indexWhere((b) => b.url == bookmark.url);

    if (existingBookmarkIndex != -1) {
      // Update existing bookmark
      final existingBookmark = _bookmarks[existingBookmarkIndex];
      existingBookmark.currentChapter = bookmark.currentChapter;
      existingBookmark.lastUpdated = DateTime.now();
      // You might want to update other fields here as well, e.g., status, notes, etc.
      await _dbHelper.updateBookmark(existingBookmark);
    } else {
      // Add new bookmark
      await _dbHelper.addBookmark(bookmark);
    }
    await loadBookmarks();
  }

  Future<void> updateBookmark(Bookmark bookmark) async {
    await _dbHelper.updateBookmark(bookmark);
    await loadBookmarks();
  }

  Future<void> deleteBookmark(String id) async {
    await _dbHelper.deleteBookmark(id);
    await loadBookmarks();
  }

  // New method for reordering bookmarks
  Future<void> reorderBookmarks(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _bookmarks.removeAt(oldIndex);
    _bookmarks.insert(newIndex, item);
    notifyListeners(); // Notify listeners immediately for UI update
    await _dbHelper.saveBookmarks(_bookmarks); // Persist the new order
  }
}
