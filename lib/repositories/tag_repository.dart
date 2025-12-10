import '../database/database_helper.dart';
import '../models/tag.dart';

// Business logic for interacting with database
class TagRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<String> create(Tag tag) async {
    final db = await _dbHelper.database;
    await db.insert('tags', tag.toMap());
    return tag.id;
  }

  Future<List<Tag>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('tags', orderBy: 'name ASC');
    return result.map((map) => Tag.fromMap(map)).toList();
  }

  Future<List<Tag>> getHierarchical() async {
    final allTags = await getAll();
    final tagMap = {for (var tag in allTags) tag.id: tag};
    final rootTags = <Tag>[];

    // Create hiearchy system for tags
    for (var tag in allTags) {
      if (tag.parentId == null) {
        rootTags.add(tag);
      } else {
        final parent = tagMap[tag.parentId];
        if (parent != null) {
          parent.children ??= [];
          parent.children!.add(tag);
        }
      }
    }

    return rootTags;
  }

  Future<List<Tag>> getByParentId(String? parentId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'tags',
      where: parentId == null ? 'parent_id IS NULL' : 'parent_id = ?',
      whereArgs: parentId == null ? null : [parentId],
      orderBy: 'name ASC',
    );
    return result.map((map) => Tag.fromMap(map)).toList();
  }

  Future<Tag?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query('tags', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Tag.fromMap(result.first);
    }
    return null;
  }

  Future<List<String>> getAllDescendantIds(String tagId) async {
    final descendants = <String>[tagId];
    final children = await getByParentId(tagId);

    for (var child in children) {
      final childDescendants = await getAllDescendantIds(child.id);
      descendants.addAll(childDescendants);
    }

    return descendants;
  }

  Future<int> update(Tag tag) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tags',
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }
}
