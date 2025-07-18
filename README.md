# Manga Marker

A feature-rich, privacy-focused, fully offline manga tracker and reader app built with Flutter.

---

## 📸 Screenshots

| Dashboard Overview | Add/Edit Bookmark | Manga Reader (Zoom) |
|-------------------|------------------|---------------------|
| ![Dashboard](screenshots/dashboard.png) | ![Bookmark Edit](screenshots/bookmark_edit.png) | ![Manga Reader](screenshots/manga_reader.png) |

| CBZ/PDF Reader | Tracker Import/Export |
|----------------|---------------------|
| ![CBZ PDF](screenshots/cbz_pdf.png) | ![Tracker Import](screenshots/tracker_import.png) |

*Tip: Annotate screenshots with arrows or labels for clarity.*

---

## ✅ Release Checklist

- [x] All features complete and tested
- [x] All linter and build errors resolved
- [x] Manual QA: Add/Edit/Delete bookmarks
- [x] Folder image manga reading tested
- [x] CBZ/PDF viewing tested on multiple files
- [x] Backup/Restore works with real data
- [x] Tracker import tested with AniList/MAL files
- [x] No external APIs or network requests
- [x] Flutter build (Android) successful
- [ ] iOS build tested (optional)
- [ ] App icon & splash screen finalized

---

## 🔧 Developer Setup

1. Clone the repo
2. Run `flutter pub get`
3. Use a physical device or emulator
4. Optional: Run with `--no-sound-null-safety` if needed

---

## Features

- **Core bookmarking:** Add, edit, and delete manga bookmarks with details like title, URL, cover image, chapters, status, tags, notes, and rating.
- **Multiple Views:** Choose between compact, expanded, card stack, and cover wall views to display your bookmarks.
- **Data Management:**
    - **Import/Export:** Back up and restore your data in JSON or encrypted JSON format.
    - **Backup/Restore:** Create automatic and manual backups of your data.
    - **QR Code Import:** Quickly import bookmarks by scanning QR codes.
- **User Features:**
    - **PIN Lock:** Secure your app with a PIN.
    - **Profiles:** Manage multiple user profiles for different users or purposes.
    - **Reading Goals:** Set and track your reading goals to stay motivated.
    - **Statistics:** View detailed statistics about your reading habits.
    - **Themes:** Customize the app's appearance with different themes.
- **Advanced Features:**
    - **Bulk Editing:** Edit multiple bookmarks at once to save time.
    - **Filtering:** Easily find bookmarks by filtering by status, tag, collection, or notes.
    - **Developer Mode:** Access experimental features and settings.

## Getting Started

To get started with Manga Marker, you'll need to have Flutter installed on your system. You can find instructions on how to install Flutter [here](https://flutter.dev/docs/get-started/install).

Once you have Flutter installed, you can clone this repository and run the app using the following commands:

```
git clone https://github.com/your-username/manga_marker.git
cd manga_marker
flutter pub get
flutter run
```

## Contributing

Contributions are welcome! If you have any ideas for new features or improvements, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.