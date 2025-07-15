import 'package:flutter/material.dart';

class FaqHelpScreen extends StatelessWidget {
  const FaqHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ / Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ExpansionTile(
            title: Text('How do I add a new bookmark?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    'To add a new bookmark, tap the floating `+` button on the home screen.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I edit a bookmark?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    'To edit a bookmark, tap on it in the list to open the edit screen.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I delete a bookmark?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    'To delete a bookmark, swipe it left or right in the list view.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}