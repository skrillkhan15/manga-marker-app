import 'package:flutter/material.dart';

class ReadingGoalsScreen extends StatefulWidget {
  const ReadingGoalsScreen({super.key});

  @override
  State<ReadingGoalsScreen> createState() => _ReadingGoalsScreenState();
}

class _ReadingGoalsScreenState extends State<ReadingGoalsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Goals'),
      ),
      body: const Center(
        child: Text('Reading Goals Screen'),
      ),
    );
  }
}