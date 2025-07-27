import 'package:sqflite/sqflite.dart';
import '../base_data_service.dart';
import '../../models/driver.dart';
import '../../models/transport.dart';
import '../../database_helper.dart';

class ProfileLocalService extends BaseDataService<Driver> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Driver item) async {
    final db = await _dbHelper.database;
    final data = item.toJson();
    data['isPending'] = item.isPending ? 1 : 0;
    data['isDeleted'] = item.isDeleted ? 1 : 0;
    await db.insert('drivers', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(Driver item) async {
    await insert(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    final db = await _dbHelper.database;
    await db.delete('drivers', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Driver>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('drivers');
    return maps.map((map) => Driver.fromJson(map)).toList();
  }

  @override
  Future<Driver?> getById(dynamic id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('drivers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Driver.fromJson(maps.first);
  }

  @override
  Future<void> syncFromLocal(List<Driver> items) async {}

  @override
  Future<List<Driver>> findWhere(bool Function(Driver) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<void> upsertTransport(Transport transport) async {
    final db = await _dbHelper.database;
    final data = transport.toJson();
    await db.insert('transport', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Transport?> getTransport(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('transport', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Transport.fromJson(maps.first);
  }
}
