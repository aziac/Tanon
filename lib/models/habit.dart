class Habit {
  final String id;
  final String title;
  final String? description;
  final List<int> selectedDays; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  List<String>? tagIds;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.selectedDays,
    this.startTime,
    this.endTime,
    required this.createdAt,
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
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    final frequencyStr = map['frequency'] as String;
    List<int> selectedDays;

    // Handle migration from old format (daily/weekly) to new format (comma-separated days)
    if (frequencyStr == 'daily') {
      selectedDays = [0, 1, 2, 3, 4, 5, 6];
    } else if (frequencyStr == 'weekly') {
      selectedDays = [1, 2, 3, 4, 5];
    } else if (frequencyStr.isEmpty) {
      selectedDays = [];
    } else {
      try {
        selectedDays =
            frequencyStr.split(',').map((e) => int.parse(e.trim())).toList();
      } catch (e) {
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
