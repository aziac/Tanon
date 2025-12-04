import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';
import '../theme/win95_theme.dart';
import '../widgets/win95_widgets.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final HabitRepository _habitRepo = HabitRepository();
  final _uuid = const Uuid();

  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    _habits = await _habitRepo.getAll();
    setState(() => _isLoading = false);
  }

  void _showHabitDialog({Habit? existingHabit}) {
    final titleController = TextEditingController(text: existingHabit?.title);
    final descController =
        TextEditingController(text: existingHabit?.description);
    final selectedDays = existingHabit?.selectedDays.toSet() ?? <int>{};

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
                  Text(existingHabit == null ? 'New Habit' : 'Edit Habit',
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Days:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Win95Button(
                        onPressed: () {
                          setDialogState(() {
                            if (selectedDays.length == 7) {
                              selectedDays.clear();
                            } else {
                              selectedDays.addAll([0, 1, 2, 3, 4, 5, 6]);
                            }
                          });
                        },
                        child: Text(selectedDays.length == 7
                            ? 'Deselect All'
                            : 'Select All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Win95Panel(
                    inset: true,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _buildDayButton(
                            0, 'Sunday', selectedDays, setDialogState),
                        _buildDayButton(
                            1, 'Monday', selectedDays, setDialogState),
                        _buildDayButton(
                            2, 'Tuesday', selectedDays, setDialogState),
                        _buildDayButton(
                            3, 'Wednesday', selectedDays, setDialogState),
                        _buildDayButton(
                            4, 'Thursday', selectedDays, setDialogState),
                        _buildDayButton(
                            5, 'Friday', selectedDays, setDialogState),
                        _buildDayButton(
                            6, 'Saturday', selectedDays, setDialogState),
                      ],
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
                          if (titleController.text.isNotEmpty &&
                              selectedDays.isNotEmpty) {
                            final habit = Habit(
                              id: existingHabit?.id ?? _uuid.v4(),
                              title: titleController.text,
                              description: descController.text.isEmpty
                                  ? null
                                  : descController.text,
                              selectedDays: selectedDays.toList()..sort(),
                              createdAt:
                                  existingHabit?.createdAt ?? DateTime.now(),
                            );

                            if (existingHabit == null) {
                              await _habitRepo.create(habit);
                            } else {
                              await _habitRepo.update(habit);
                            }

                            Navigator.pop(context);
                            _loadHabits();
                          } else if (selectedDays.isEmpty) {
                            // Show error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please select at least one day')),
                            );
                          }
                        },
                        child: Text(existingHabit == null ? 'Create' : 'Save'),
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

  Widget _buildDayButton(int dayIndex, String dayName, Set<int> selectedDays,
      StateSetter setDialogState) {
    final isSelected = selectedDays.contains(dayIndex);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setDialogState(() {
                  if (isSelected) {
                    selectedDays.remove(dayIndex);
                  } else {
                    selectedDays.add(dayIndex);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: isSelected ? win95Inset() : win95Raised(),
                child: Row(
                  children: [
                    Win95Checkbox(
                      value: isSelected,
                      onChanged: null, // Handled by GestureDetector
                    ),
                    const SizedBox(width: 8),
                    Text(dayName, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
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
                onPressed: () => _showHabitDialog(),
                child: const Text('New Habit'),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Win95Theme.buttonShadow),
        // Habit list
        Expanded(
          child: _habits.isEmpty
              ? const Center(
                  child: Text('No habits yet. Click "New Habit" to add one.'))
              : ListView.builder(
                  itemCount: _habits.length,
                  itemBuilder: (context, index) {
                    final habit = _habits[index];
                    return FutureBuilder<bool>(
                      future: _habitRepo.isCompletedOnDate(
                          habit.id, DateTime.now()),
                      builder: (context, snapshot) {
                        final isCompletedToday = snapshot.data ?? false;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Win95Panel(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Win95Checkbox(
                                  value: isCompletedToday,
                                  onChanged: (val) async {
                                    if (val == true) {
                                      final completion = HabitCompletion(
                                        id: _uuid.v4(),
                                        habitId: habit.id,
                                        completedDate: DateTime.now(),
                                      );
                                      await _habitRepo
                                          .addCompletion(completion);
                                    } else {
                                      await _habitRepo.deleteCompletion(
                                          habit.id, DateTime.now());
                                    }
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        _showHabitDialog(existingHabit: habit),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          habit.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (habit.description != null)
                                          Text(habit.description!,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        Text(
                                          habit.getFrequencyDisplay(),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Win95Button(
                                  onPressed: () async {
                                    await _habitRepo.delete(habit.id);
                                    _loadHabits();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
