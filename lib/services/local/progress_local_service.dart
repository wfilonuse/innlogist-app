import 'package:sqflite/sqflite.dart';
import '../base_data_service.dart';
import '../../models/progress.dart';
import '../../database_helper.dart';

class ProgressLocalService extends BaseDataService<Progress> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Progress item) async {
    final db = await _dbHelper.database;
    final data = item.toJson();
    data['isPending'] = item.isPending ? 1 : 0;
    data['isDeleted'] = item.isDeleted ? 1 : 0;
    await db.insert('progress', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(Progress item) async {
    await insert(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    final db = await _dbHelper.database;
    await db.delete('progress', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Progress>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('progress');
    return maps.map((map) => Progress.fromJson(map)).toList();
  }

  @override
  Future<Progress?> getById(dynamic id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('progress', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Progress.fromJson(maps.first);
  }

  @override
  Future<void> syncFromLocal(List<Progress> items) async {}

  @override
  Future<List<Progress>> findWhere(bool Function(Progress) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<List<Progress>> getPendingProgress() async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('progress', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Progress.fromJson(map)).toList();
  }

  Future<void> markForDeletionProgress(int id) async {
    final db = await _dbHelper.database;
    await db.update('progress', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
