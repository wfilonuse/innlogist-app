import 'package:sqflite/sqflite.dart';
import '../base_data_service.dart';
import '../../models/transport.dart';
import '../../database_helper.dart';

class TransportLocalService extends BaseDataService<Transport> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Transport item) async {
    final db = await _dbHelper.database;
    final data = item.toJson();
    await db.insert('transport', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(Transport item) async {
    await insert(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    final db = await _dbHelper.database;
    await db.delete('transport', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Transport>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('transport');
    return maps.map((map) => Transport.fromJson(map)).toList();
  }

  @override
  Future<Transport?> getById(dynamic id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('transport', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Transport.fromJson(maps.first);
  }

  @override
  Future<void> syncFromLocal(List<Transport> items) async {}

  @override
  Future<List<Transport>> findWhere(bool Function(Transport) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }
}
