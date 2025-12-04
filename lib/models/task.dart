class Task {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final DateTime? completedAt;
  List<String>? tagIds;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    this.dueDate,
    this.startTime,
    this.endTime,
    required this.createdAt,
    this.completedAt,
    this.tagIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'due_date': dueDate?.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['is_completed'] == 1,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      startTime:
          map['start_time'] != null ? DateTime.parse(map['start_time']) : null,
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      createdAt: DateTime.parse(map['created_at']),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? completedAt,
    List<String>? tagIds,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      tagIds: tagIds ?? this.tagIds,
    );
  }
}
