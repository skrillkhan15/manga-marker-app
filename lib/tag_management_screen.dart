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
            // Expanded color picker options
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildColorSelectionCircle(
                  Colors.red,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.pink,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.purple,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.deepPurple,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.indigo,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.blue,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.lightBlue,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.cyan,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.teal,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.green,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.lightGreen,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.lime,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.yellow,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.amber,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.orange,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.deepOrange,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.brown,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.grey,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.blueGrey,
                  tagColor,
                  (color) => setState(() => tagColor = color),
                ),
                _buildColorSelectionCircle(
                  Colors.black,
                  tagColor,
                  (color) => setState(() => tagColor = color),
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
                  await _dbHelper.addTag(
                    Tag(
                      id: const Uuid().v4(),
                      name: tagName,
                      color: tagColor.value,
                    ),
                  );
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

  Widget _buildColorSelectionCircle(
    Color color,
    Color currentColor,
    ValueChanged<Color> onColorSelected,
  ) {
    final isSelected = currentColor.value == color.value;
    return GestureDetector(
      onTap: () => onColorSelected(color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                )
              : null,
        ),
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
      appBar: AppBar(title: const Text('Manage Tags')),
      body: _tags.isEmpty
          ? const Center(child: Text('No tags yet. Add one!'))
          : ListView.builder(
              itemCount: _tags.length,
              itemBuilder: (context, index) {
                final tag = _tags[index];
                return ListTile(
                  leading: Icon(
                    Icons.label,
                    color: tag.color != null ? Color(tag.color!) : Colors.grey,
                  ),
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
