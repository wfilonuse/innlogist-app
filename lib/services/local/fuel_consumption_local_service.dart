import 'package:sqflite/sqflite.dart';
import '../base_data_service.dart';
import '../../models/fuel_consumption.dart';
import '../../database_helper.dart';

class FuelConsumptionLocalService extends BaseDataService<FuelConsumption> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(FuelConsumption item) async {
    final db = await _dbHelper.database;
    final data = item.toJson();
    data['isPending'] = item.isPending ? 1 : 0;
    data['isDeleted'] = item.isDeleted ? 1 : 0;
    await db.insert('fuel_consumption', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(FuelConsumption item) async {
    await insert(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    final db = await _dbHelper.database;
    await db.delete('fuel_consumption', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<FuelConsumption>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('fuel_consumption');
    return maps.map((map) => FuelConsumption.fromJson(map)).toList();
  }

  @override
  Future<FuelConsumption?> getById(dynamic id) async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('fuel_consumption', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return FuelConsumption.fromJson(maps.first);
  }

  @override
  Future<void> syncFromLocal(List<FuelConsumption> items) async {}

  @override
  Future<List<FuelConsumption>> findWhere(
      bool Function(FuelConsumption) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<List<FuelConsumption>> getPendingFuelConsumption() async {
    final db = await _dbHelper.database;
    final maps = await db.query('fuel_consumption',
        where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => FuelConsumption.fromJson(map)).toList();
  }

  Future<void> markForDeletionFuelConsumption(int id) async {
    final db = await _dbHelper.database;
    await db.update('fuel_consumption', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
