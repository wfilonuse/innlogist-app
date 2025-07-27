import 'package:sqflite/sqflite.dart';
import '../base_data_service.dart';
import '../../models/report.dart';
import '../../database_helper.dart';

class ReportLocalService extends BaseDataService<Report> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Report item) async {
    final db = await _dbHelper.database;
    final data = item.toJson();
    data['isPending'] = item.isPending ? 1 : 0;
    data['isDeleted'] = item.isDeleted ? 1 : 0;
    await db.insert('reports', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(Report item) async {
    await insert(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    final db = await _dbHelper.database;
    await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Report>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('reports');
    return maps.map((map) => Report.fromJson(map)).toList();
  }

  @override
  Future<Report?> getById(dynamic id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('reports', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Report.fromJson(maps.first);
  }

  @override
  Future<void> syncFromLocal(List<Report> items) async {}

  @override
  Future<List<Report>> findWhere(bool Function(Report) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<List<Report>> getPendingReports() async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('reports', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Report.fromJson(map)).toList();
  }

  Future<void> markForDeletionReport(int id) async {
    final db = await _dbHelper.database;
    await db.update('reports', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
