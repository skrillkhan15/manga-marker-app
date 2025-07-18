import 'package:flutter/material.dart';

class MultiActionFab extends StatelessWidget {
  final VoidCallback onAddBookmark;

  const MultiActionFab({super.key, required this.onAddBookmark});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.bookmark_add),
                    title: const Text('Add New Bookmark'),
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
                      onAddBookmark();
                    },
                  ),
                  // Add more actions here as needed
                ],
              ),
            );
          },
        );
      },
      tooltip: 'Actions',
      child: const Icon(Icons.add),
    );
  }
}
