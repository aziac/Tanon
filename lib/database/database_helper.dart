import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habit_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);
    return await openDatabase(
      path,
      version: 3, // Increment version for notification columns
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add start_time and end_time columns to habits table
      await db.execute('ALTER TABLE habits ADD COLUMN start_time TEXT');
      await db.execute('ALTER TABLE habits ADD COLUMN end_time TEXT');
    }
    if (oldVersion < 3) {
      // Add notification columns
      await db.execute(
          'ALTER TABLE tasks ADD COLUMN notify_at_start INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE tasks ADD COLUMN notify_at_end INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE habits ADD COLUMN notify_at_start INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE habits ADD COLUMN notify_at_end INTEGER DEFAULT 0');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    // Tags table with parent reference for hierarchy
    await db.execute('''
      CREATE TABLE tags (
        id $idType,
        name $textType,
        parent_id TEXT,
        color TEXT,
        created_at $textType,
        FOREIGN KEY (parent_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        title $textType,
        description TEXT,
        is_completed $boolType,
        due_date TEXT,
        start_time TEXT,
        end_time TEXT,
        created_at $textType,
        completed_at TEXT,
        notify_at_start $boolType DEFAULT 0,
        notify_at_end $boolType DEFAULT 0
      )
    ''');

    // Habits table
    await db.execute('''
      CREATE TABLE habits (
        id $idType,
        title $textType,
        description TEXT,
        frequency $textType,
        target_days $intType,
        start_time TEXT,
        end_time TEXT,
        created_at $textType,
        notify_at_start $boolType DEFAULT 0,
        notify_at_end $boolType DEFAULT 0
      )
    ''');

    // Habit completions table
    await db.execute('''
      CREATE TABLE habit_completions (
        id $idType,
        habit_id $textType,
        completed_date $textType,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // Task-Tag relationship (many-to-many)
    await db.execute('''
      CREATE TABLE task_tags (
        task_id $textType,
        tag_id $textType,
        PRIMARY KEY (task_id, tag_id),
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    // Habit-Tag relationship (many-to-many)
    await db.execute('''
      CREATE TABLE habit_tags (
        habit_id $textType,
        tag_id $textType,
        PRIMARY KEY (habit_id, tag_id),
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
