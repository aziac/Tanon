import '../database/database_helper.dart';
import '../models/habit.dart';

// Business logic for interacting with database
class HabitRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<String> create(Habit habit) async {
    final db = await _dbHelper.database;
    await db.insert('habits', habit.toMap());

    if (habit.tagIds != null && habit.tagIds!.isNotEmpty) {
      for (var tagId in habit.tagIds!) {
        await db.insert('habit_tags', {
          'habit_id': habit.id,
          'tag_id': tagId,
        });
      }
    }

    return habit.id;
  }

  Future<List<Habit>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('habits', orderBy: 'created_at DESC');
    final habits = result.map((map) => Habit.fromMap(map)).toList();

    for (var habit in habits) {
      habit.tagIds = await _getTagIdsForHabit(habit.id);
    }

    return habits;
  }

  Future<Habit?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('habits', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final habit = Habit.fromMap(result.first);
      habit.tagIds = await _getTagIdsForHabit(habit.id);
      return habit;
    }
    return null;
  }

  Future<List<String>> _getTagIdsForHabit(String habitId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'habit_tags',
      columns: ['tag_id'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return result.map((row) => row['tag_id'] as String).toList();
  }

  Future<int> update(Habit habit) async {
    final db = await _dbHelper.database;

    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );

    await db.delete('habit_tags', where: 'habit_id = ?', whereArgs: [habit.id]);
    if (habit.tagIds != null && habit.tagIds!.isNotEmpty) {
      for (var tagId in habit.tagIds!) {
        await db.insert('habit_tags', {
          'habit_id': habit.id,
          'tag_id': tagId,
        });
      }
    }

    return 1;
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<String> addCompletion(HabitCompletion completion) async {
    final db = await _dbHelper.database;
    await db.insert('habit_completions', completion.toMap());
    return completion.id;
  }

  Future<List<HabitCompletion>> getCompletions(String habitId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_date DESC',
    );
    return result.map((map) => HabitCompletion.fromMap(map)).toList();
  }

  Future<bool> isCompletedOnDate(String habitId, DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'habit_completions',
      where: 'habit_id = ? AND completed_date >= ? AND completed_date < ?',
      whereArgs: [
        habitId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String()
      ],
    );

    return result.isNotEmpty;
  }

  Future<int> deleteCompletion(String habitId, DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await db.delete(
      'habit_completions',
      where: 'habit_id = ? AND completed_date >= ? AND completed_date < ?',
      whereArgs: [
        habitId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String()
      ],
    );
  }
}
