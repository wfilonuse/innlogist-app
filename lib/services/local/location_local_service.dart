import 'package:sqflite/sqflite.dart';
import '../base_data_service.dart';
import '../../models/location.dart';
import '../../database_helper.dart';

class LocationLocalService extends BaseDataService<Location> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Location item) async {
    final db = await _dbHelper.database;
    final data = item.toJson();
    await db.insert('locations', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(Location item) async {
    await insert(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    final db = await _dbHelper.database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Location>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('locations');
    return maps.map((map) => Location.fromJson(map)).toList();
  }

  @override
  Future<Location?> getById(dynamic id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('locations', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Location.fromJson(maps.first);
  }

  @override
  Future<void> syncFromLocal(List<Location> items) async {}

  @override
  Future<List<Location>> findWhere(bool Function(Location) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<List<Location>> getPendingLocations() async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('locations', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Location.fromJson(map)).toList();
  }

  Future<void> markForDeletionLocation(int id) async {
    final db = await _dbHelper.database;
    await db.update('locations', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
