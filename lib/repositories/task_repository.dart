import '../database/database_helper.dart';
import '../models/task.dart';

// Business logic for interacting with database
class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<String> create(Task task) async {
    final db = await _dbHelper.database;
    await db.insert('tasks', task.toMap());

    // Insert tags
    if (task.tagIds != null && task.tagIds!.isNotEmpty) {
      for (var tagId in task.tagIds!) {
        await db.insert('task_tags', {
          'task_id': task.id,
          'tag_id': tagId,
        });
      }
    }

    return task.id;
  }

  Future<List<Task>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('tasks', orderBy: 'created_at DESC');
    final tasks = result.map((map) => Task.fromMap(map)).toList();

    // Load tags for each task
    for (var task in tasks) {
      task.tagIds = await _getTagIdsForTask(task.id);
    }

    return tasks;
  }

  Future<List<Task>> getByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'tasks',
      where: 'due_date >= ? AND due_date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'start_time ASC',
    );

    final tasks = result.map((map) => Task.fromMap(map)).toList();
    for (var task in tasks) {
      task.tagIds = await _getTagIdsForTask(task.id);
    }

    return tasks;
  }

  Future<List<Task>> getByTagIds(List<String> tagIds) async {
    if (tagIds.isEmpty) return [];

    final db = await _dbHelper.database;
    final placeholders = List.filled(tagIds.length, '?').join(',');

    final result = await db.rawQuery('''
      SELECT DISTINCT tasks.* FROM tasks
      INNER JOIN task_tags ON tasks.id = task_tags.task_id
      WHERE task_tags.tag_id IN ($placeholders)
      ORDER BY tasks.created_at DESC
    ''', tagIds);

    final tasks = result.map((map) => Task.fromMap(map)).toList();
    for (var task in tasks) {
      task.tagIds = await _getTagIdsForTask(task.id);
    }

    return tasks;
  }

  Future<Task?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final task = Task.fromMap(result.first);
      task.tagIds = await _getTagIdsForTask(task.id);
      return task;
    }
    return null;
  }

  Future<List<String>> _getTagIdsForTask(String taskId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'task_tags',
      columns: ['tag_id'],
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
    return result.map((row) => row['tag_id'] as String).toList();
  }

  Future<int> update(Task task) async {
    final db = await _dbHelper.database;

    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    await db.delete('task_tags', where: 'task_id = ?', whereArgs: [task.id]);
    if (task.tagIds != null && task.tagIds!.isNotEmpty) {
      for (var tagId in task.tagIds!) {
        await db.insert('task_tags', {
          'task_id': task.id,
          'tag_id': tagId,
        });
      }
    }

    return 1;
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
