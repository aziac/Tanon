import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';
import '../models/tag.dart';
import '../repositories/tag_repository.dart';
import '../theme/win95_theme.dart';
import '../widgets/win95_widgets.dart';

// Call this from initState of any screen, for example:
// @override
// void initState() {
//   super.initState();
//   cleanupOrphanedTags();
// }

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final TagRepository _tagRepo = TagRepository();
  final _uuid = const Uuid();

  List<Tag> _rootTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);
    _rootTags = await _tagRepo.getHierarchical();
    setState(() => _isLoading = false);
  }

  void _showAddTagDialog({String? parentId, String? parentName}) {
    final titleController = TextEditingController();
    String selectedColor = '#808080';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Win95Theme.windowBackground,
        child: Win95Panel(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentName != null
                      ? 'New Sub-tag under "$parentName"'
                      : 'New Tag',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Tag Name:'),
                const SizedBox(height: 4),
                Win95TextField(controller: titleController),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Win95Button(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    Win95Button(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty) {
                          final tag = Tag(
                            id: _uuid.v4(),
                            name: titleController.text,
                            parentId: parentId,
                            color: selectedColor,
                            createdAt: DateTime.now(),
                          );
                          await _tagRepo.create(tag);
                          Navigator.pop(context);
                          _loadTags();
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagTree(Tag tag, int depth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 20.0, top: 4, bottom: 4),
          child: Win95Panel(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                if (depth > 0)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.subdirectory_arrow_right, size: 16),
                  ),
                Expanded(
                  child: Text(
                    tag.name,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Win95Button(
                  onPressed: () =>
                      _showAddTagDialog(parentId: tag.id, parentName: tag.name),
                  child: const Text('Add Sub-tag'),
                ),
                const SizedBox(width: 4),
                Win95Button(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Win95Theme.windowBackground,
                        child: Win95Panel(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                  'Delete this tag and all its sub-tags?'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Win95Button(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 8),
                                  Win95Button(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    if (confirm == true) {
                      await _tagRepo.delete(tag.id);
                      _loadTags();
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ),
        if (tag.children != null)
          ...tag.children!.map((child) => _buildTagTree(child, depth + 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Win95Button(
                onPressed: () => _showAddTagDialog(),
                child: const Text('New Tag'),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Organize your tags hierarchically. Tags can have sub-tags (e.g., School → Math, CS).',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Win95Theme.buttonShadow),
        // Tag tree
        Expanded(
          child: _rootTags.isEmpty
              ? const Center(
                  child: Text('No tags yet. Click "New Tag" to create one.'))
              : ListView(
                  padding: const EdgeInsets.all(8),
                  children:
                      _rootTags.map((tag) => _buildTagTree(tag, 0)).toList(),
                ),
        ),
      ],
    );
  }
}
