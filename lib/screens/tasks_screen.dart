import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../repositories/task_repository.dart';
import '../repositories/tag_repository.dart';
import '../theme/win95_theme.dart';
import '../widgets/win95_widgets.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskRepository _taskRepo = TaskRepository();
  final TagRepository _tagRepo = TagRepository();
  final _uuid = const Uuid();

  List<Task> _tasks = [];
  List<Tag> _allTags = [];
  String? _selectedTagFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _allTags = await _tagRepo.getAll();

    if (_selectedTagFilter == null) {
      _tasks = await _taskRepo.getAll();
    } else {
      // Get all descendant tag IDs for filtering
      final allFilterIds =
          await _tagRepo.getAllDescendantIds(_selectedTagFilter!);
      _tasks = await _taskRepo.getByTagIds(allFilterIds);
    }

    setState(() => _isLoading = false);
  }

  void _showTaskDialog({Task? existingTask}) {
    final titleController = TextEditingController(text: existingTask?.title);
    final descController =
        TextEditingController(text: existingTask?.description);
    DateTime? selectedDate = existingTask?.dueDate;
    TimeOfDay? startTime = existingTask?.startTime != null
        ? TimeOfDay.fromDateTime(existingTask!.startTime!)
        : null;
    TimeOfDay? endTime = existingTask?.endTime != null
        ? TimeOfDay.fromDateTime(existingTask!.endTime!)
        : null;
    final selectedTags = existingTask?.tagIds?.toSet() ?? <String>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Win95Theme.windowBackground,
          child: Win95Panel(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(existingTask == null ? 'New Task' : 'Edit Task',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Title:'),
                  const SizedBox(height: 4),
                  Win95TextField(controller: titleController),
                  const SizedBox(height: 12),
                  const Text('Description:'),
                  const SizedBox(height: 4),
                  Win95TextField(controller: descController, maxLines: 3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Due Date:'),
                            const SizedBox(height: 4),
                            Win95Button(
                              onPressed: () async {
                                final date = await showDialog<DateTime>(
                                  context: context,
                                  builder: (context) => Win95DatePicker(
                                    initialDate: selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  ),
                                );
                                if (date != null) {
                                  setDialogState(() => selectedDate = date);
                                }
                              },
                              child: Text(selectedDate == null
                                  ? 'Select Date'
                                  : '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Time:'),
                            const SizedBox(height: 4),
                            Win95Button(
                              onPressed: () async {
                                final time = await showDialog<TimeOfDay>(
                                  context: context,
                                  builder: (context) => Win95TimePicker(
                                    initialTime: startTime ?? TimeOfDay.now(),
                                  ),
                                );
                                if (time != null) {
                                  setDialogState(() => startTime = time);
                                }
                              },
                              child: Text(startTime == null
                                  ? 'Select'
                                  : startTime!.format(context)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Time:'),
                            const SizedBox(height: 4),
                            Win95Button(
                              onPressed: () async {
                                final time = await showDialog<TimeOfDay>(
                                  context: context,
                                  builder: (context) => Win95TimePicker(
                                    initialTime:
                                        endTime ?? startTime ?? TimeOfDay.now(),
                                  ),
                                );
                                if (time != null) {
                                  setDialogState(() => endTime = time);
                                }
                              },
                              child: Text(endTime == null
                                  ? 'Select'
                                  : endTime!.format(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Tags:'),
                  const SizedBox(height: 4),
                  Win95Panel(
                    inset: true,
                    child: SizedBox(
                      height: 100,
                      child: ListView(
                        children: _allTags.map((tag) {
                          final isSelected = selectedTags.contains(tag.id);
                          return Win95Checkbox(
                            value: isSelected,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedTags.add(tag.id);
                                  // Auto-select parent tags
                                  String? currentParentId = tag.parentId;
                                  while (currentParentId != null) {
                                    selectedTags.add(currentParentId);
                                    final parent = _allTags.firstWhere(
                                      (t) => t.id == currentParentId,
                                      orElse: () => Tag(
                                        id: '',
                                        name: '',
                                        createdAt: DateTime.now(),
                                      ),
                                    );
                                    if (parent.id.isEmpty) break;
                                    currentParentId = parent.parentId;
                                  }
                                } else {
                                  selectedTags.remove(tag.id);
                                }
                              });
                            },
                            label: Text(tag.name),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
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
                            DateTime? start, end;
                            if (selectedDate != null && startTime != null) {
                              start = DateTime(
                                selectedDate!.year,
                                selectedDate!.month,
                                selectedDate!.day,
                                startTime!.hour,
                                startTime!.minute,
                              );
                            }
                            if (selectedDate != null && endTime != null) {
                              end = DateTime(
                                selectedDate!.year,
                                selectedDate!.month,
                                selectedDate!.day,
                                endTime!.hour,
                                endTime!.minute,
                              );
                            }

                            final task = Task(
                              id: existingTask?.id ?? _uuid.v4(),
                              title: titleController.text,
                              description: descController.text.isEmpty
                                  ? null
                                  : descController.text,
                              isCompleted: existingTask?.isCompleted ?? false,
                              dueDate: selectedDate,
                              startTime: start,
                              endTime: end,
                              createdAt:
                                  existingTask?.createdAt ?? DateTime.now(),
                              completedAt: existingTask?.completedAt,
                              tagIds: selectedTags.toList(),
                            );

                            if (existingTask == null) {
                              await _taskRepo.create(task);
                            } else {
                              await _taskRepo.update(task);
                            }

                            Navigator.pop(context);
                            _loadData();
                          }
                        },
                        child: Text(existingTask == null ? 'Create' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                onPressed: () => _showTaskDialog(),
                child: const Text('New Task'),
              ),
              const SizedBox(width: 8),
              const Text('Filter:', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: Win95Dropdown<String>(
                  value: _selectedTagFilter,
                  hint: 'All tasks',
                  items: [
                    const Win95DropdownItem<String>(
                      value: null,
                      child: 'All tasks',
                    ),
                    ..._allTags.map((tag) => Win95DropdownItem<String>(
                          value: tag.id,
                          child: tag.name,
                        )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedTagFilter = val;
                    });
                    _loadData();
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Win95Theme.buttonShadow),
        // Task list
        Expanded(
          child: _tasks.isEmpty
              ? const Center(
                  child: Text('No tasks yet. Click "New Task" to add one.'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Win95Panel(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Win95Checkbox(
                              value: task.isCompleted,
                              onChanged: (val) async {
                                final updated = task.copyWith(
                                  isCompleted: val ?? false,
                                  completedAt:
                                      val == true ? DateTime.now() : null,
                                );
                                await _taskRepo.update(updated);
                                _loadData();
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _showTaskDialog(existingTask: task),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (task.description != null)
                                      Text(task.description!,
                                          style: const TextStyle(fontSize: 12)),
                                    if (task.startTime != null &&
                                        task.endTime != null)
                                      Text(
                                        '${TimeOfDay.fromDateTime(task.startTime!).format(context)} - ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54),
                                      ),
                                    if (task.tagIds != null &&
                                        task.tagIds!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: task.tagIds!.map((tagId) {
                                            final tag = _allTags.firstWhere(
                                              (t) => t.id == tagId,
                                              orElse: () => Tag(
                                                  id: '',
                                                  name: 'Unknown',
                                                  createdAt: DateTime.now()),
                                            );
                                            if (tag.id.isEmpty) {
                                              return const SizedBox.shrink();
                                            }

                                            final tagColor = tag.color != null
                                                ? Color(int.parse(
                                                        tag.color!.substring(1),
                                                        radix: 16) +
                                                    0xFF000000)
                                                : Win95Theme.buttonShadow;

                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: tagColor,
                                                border: Border.all(
                                                    color: Colors.black,
                                                    width: 1),
                                              ),
                                              child: Text(
                                                tag.name,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Win95Button(
                              onPressed: () async {
                                await _taskRepo.delete(task.id);
                                _loadData();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
