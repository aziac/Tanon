import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../repositories/task_repository.dart';
import '../repositories/habit_repository.dart';
import '../theme/win95_theme.dart';
import '../widgets/win95_widgets.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskRepository _taskRepo = TaskRepository();
  final HabitRepository _habitRepo = HabitRepository();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _tasksForDay = [];
  List<Habit> _habitsForDay = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadDataForDay(_focusedDay);
  }

  Future<void> _loadDataForDay(DateTime day) async {
    setState(() => _isLoading = true);
    _tasksForDay = await _taskRepo.getByDate(day);

    final allHabits = await _habitRepo.getAll();
    final dayOfWeek = day.weekday % 7; // Convert to 0-6 (Sunday-Saturday)
    _habitsForDay = allHabits
        .where((habit) => habit.selectedDays.contains(dayOfWeek))
        .toList();

    setState(() => _isLoading = false);
  }

  // Combined item class to sort tasks and habits together
  List<dynamic> _getSortedItems() {
    final items = <dynamic>[..._tasksForDay, ..._habitsForDay];

    // Sort by start time
    items.sort((a, b) {
      final aTime = a is Task ? a.startTime : (a as Habit).startTime;
      final bTime = b is Task ? b.startTime : (b as Habit).startTime;

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      // Try comparing minutes
      final aMinutes = aTime.hour * 60 + aTime.minute;
      final bMinutes = bTime.hour * 60 + bTime.minute;

      return aMinutes.compareTo(bMinutes);
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar
        Win95Panel(
          padding: const EdgeInsets.all(8),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadDataForDay(selectedDay);
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Win95Theme.activeTitle,
                shape: BoxShape.rectangle,
              ),
              todayDecoration: BoxDecoration(
                color: Win95Theme.buttonFace,
                border: Border.all(color: Win95Theme.activeTitle, width: 2),
                shape: BoxShape.rectangle,
              ),
              defaultTextStyle: const TextStyle(color: Colors.black),
              weekendTextStyle: const TextStyle(color: Colors.black),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon:
                  const Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon:
                  const Icon(Icons.chevron_right, color: Colors.black),
              decoration: win95Raised(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Tasks for selected day
        Expanded(
          child: Win95Panel(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasks & Habits for ${_selectedDay!.month}/${_selectedDay!.day}/${_selectedDay!.year}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Win95Theme.buttonShadow),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (_tasksForDay.isEmpty && _habitsForDay.isEmpty)
                          ? const Center(
                              child: Text('No tasks or habits for this day'))
                          : ListView.builder(
                              itemCount: _getSortedItems().length,
                              itemBuilder: (context, index) {
                                final item = _getSortedItems()[index];

                                if (item is Task) {
                                  return _buildTaskItem(item);
                                } else {
                                  return _buildHabitItem(item as Habit);
                                }
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Win95Panel(
        padding: const EdgeInsets.all(8),
        inset: true,
        child: Row(
          children: [
            Win95Checkbox(
              value: task.isCompleted,
              onChanged: (val) async {
                final updated = task.copyWith(
                  isCompleted: val ?? false,
                  completedAt: val == true ? DateTime.now() : null,
                );
                await _taskRepo.update(updated);
                _loadDataForDay(_selectedDay!);
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.startTime != null && task.endTime != null)
                    Text(
                      '${TimeOfDay.fromDateTime(task.startTime!).format(context)} - ${TimeOfDay.fromDateTime(task.endTime!).format(context)}',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                final nextDay = _selectedDay!.add(const Duration(days: 1));
                DateTime? newStart, newEnd;

                if (task.startTime != null) {
                  final startTime = TimeOfDay.fromDateTime(task.startTime!);
                  newStart = DateTime(
                    nextDay.year,
                    nextDay.month,
                    nextDay.day,
                    startTime.hour,
                    startTime.minute,
                  );
                }

                if (task.endTime != null) {
                  final endTime = TimeOfDay.fromDateTime(task.endTime!);
                  newEnd = DateTime(
                    nextDay.year,
                    nextDay.month,
                    nextDay.day,
                    endTime.hour,
                    endTime.minute,
                  );
                }

                final updated = task.copyWith(
                  dueDate: nextDay,
                  startTime: newStart,
                  endTime: newEnd,
                );
                await _taskRepo.update(updated);
                _loadDataForDay(_selectedDay!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitItem(Habit habit) {
    return FutureBuilder<bool>(
      future: _habitRepo.isCompletedOnDate(habit.id, _selectedDay!),
      builder: (context, snapshot) {
        final isCompletedToday = snapshot.data ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Win95Panel(
            padding: const EdgeInsets.all(8),
            inset: true,
            child: Row(
              children: [
                Win95Checkbox(
                  value: isCompletedToday,
                  onChanged: (val) async {
                    if (val == true) {
                      final completion = HabitCompletion(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        habitId: habit.id,
                        completedDate: _selectedDay!,
                      );
                      await _habitRepo.addCompletion(completion);
                    } else {
                      await _habitRepo.deleteCompletion(
                          habit.id, _selectedDay!);
                    }
                    setState(() {});
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (habit.startTime != null && habit.endTime != null)
                        Text(
                          '${TimeOfDay.fromDateTime(habit.startTime!).format(context)} - ${TimeOfDay.fromDateTime(habit.endTime!).format(context)}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                      Text(
                        'Habit - ${habit.getFrequencyDisplay()}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.repeat, size: 16, color: Colors.black54),
              ],
            ),
          ),
        );
      },
    );
  }
}
