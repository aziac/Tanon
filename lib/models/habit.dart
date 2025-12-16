class Habit {
  final String id;
  final String title;
  final String? description;
  final List<int> selectedDays; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final bool notifyAtStart;
  final bool notifyAtEnd;
  List<String>? tagIds;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.selectedDays,
    this.startTime,
    this.endTime,
    required this.createdAt,
    this.notifyAtStart = false,
    this.notifyAtEnd = false,
    this.tagIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'frequency': selectedDays.join(','), // Store as comma-separated string
      'target_days': selectedDays.length,
      'created_at': createdAt.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'notify_at_start': notifyAtStart ? 1 : 0,
      'notify_at_end': notifyAtEnd ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    final frequencyStr = map['frequency'] as String;
    List<int> selectedDays;

    // Handle migration from old format (daily/weekly) to new format (comma-separated days)
    if (frequencyStr == 'daily') {
      selectedDays = [0, 1, 2, 3, 4, 5, 6]; // All days
    } else if (frequencyStr == 'weekly') {
      // Default to weekdays for old "weekly" habits
      selectedDays = [1, 2, 3, 4, 5]; // Mon-Fri
    } else if (frequencyStr.isEmpty) {
      selectedDays = [];
    } else {
      // New format: comma-separated day indices
      try {
        selectedDays =
            frequencyStr.split(',').map((e) => int.parse(e.trim())).toList();
      } catch (e) {
        // If parsing fails, default to all days
        selectedDays = [0, 1, 2, 3, 4, 5, 6];
      }
    }

    return Habit(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      selectedDays: selectedDays,
      startTime:
          map['start_time'] != null ? DateTime.parse(map['start_time']) : null,
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      createdAt: DateTime.parse(map['created_at']),
      notifyAtStart: map['notify_at_start'] == 1,
      notifyAtEnd: map['notify_at_end'] == 1,
    );
  }

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    List<int>? selectedDays,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    bool? notifyAtStart,
    bool? notifyAtEnd,
    List<String>? tagIds,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      selectedDays: selectedDays ?? this.selectedDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      notifyAtStart: notifyAtStart ?? this.notifyAtStart,
      notifyAtEnd: notifyAtEnd ?? this.notifyAtEnd,
      tagIds: tagIds ?? this.tagIds,
    );
  }

  String getFrequencyDisplay() {
    if (selectedDays.length == 7) return 'Every day';
    if (selectedDays.isEmpty) return 'No days selected';

    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return selectedDays.map((d) => dayNames[d]).join(', ');
  }
}

class HabitCompletion {
  final String id;
  final String habitId;
  final DateTime completedDate;

  HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'completed_date': completedDate.toIso8601String(),
    };
  }

  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'],
      habitId: map['habit_id'],
      completedDate: DateTime.parse(map['completed_date']),
    );
  }
}
