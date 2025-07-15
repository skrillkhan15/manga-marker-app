import 'package:flutter/material.dart';
import 'package:manga_marker/database_helper.dart';
import 'package:manga_marker/models.dart';
import 'package:uuid/uuid.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Tag> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await _dbHelper.getTags();
    setState(() {
      _tags = tags;
    });
  }

  Future<void> _addOrEditTag({Tag? tag}) async {
    String tagName = tag?.name ?? '';
    Color tagColor = tag?.color != null ? Color(tag!.color!) : Colors.blue;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tag == null ? 'Add New Tag' : 'Edit Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: tagName),
              decoration: const InputDecoration(labelText: 'Tag Name'),
              onChanged: (value) => tagName = value,
            ),
            const SizedBox(height: 10),
            // Simple color picker (for demonstration)
            Row(
              children: [
                const Text('Tag Color:'),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    // In a real app, you'd use a color picker package
                    // For simplicity, we'll cycle through a few colors
                    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
                    int currentIndex = colors.indexOf(tagColor);
                    setState(() {
                      tagColor = colors[(currentIndex + 1) % colors.length];
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: tagColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tagName.isNotEmpty) {
                if (tag == null) {
                  await _dbHelper.addTag(Tag(
                    id: const Uuid().v4(),
                    name: tagName,
                    color: tagColor.value,
                  ));
                } else {
                  tag.name = tagName;
                  tag.color = tagColor.value;
                  await _dbHelper.updateTag(tag);
                }
                _loadTags();
                Navigator.pop(context);
              }
            },
            child: Text(tag == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTag(String tagId) async {
    await _dbHelper.deleteTag(tagId);
    _loadTags();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
      ),
      body: _tags.isEmpty
          ? const Center(
              child: Text('No tags yet. Add one!'),
            )
          : ListView.builder(
              itemCount: _tags.length,
              itemBuilder: (context, index) {
                final tag = _tags[index];
                return ListTile(
                  leading: Icon(Icons.label, color: tag.color != null ? Color(tag.color!) : Colors.grey),
                  title: Text(tag.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditTag(tag: tag),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTag(tag.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditTag(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
