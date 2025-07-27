import 'package:sqflite/sqflite.dart';
import '../base_data_service.dart';
import '../../models/address.dart';
import '../../database_helper.dart';

class AddressLocalService extends BaseDataService<Address> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Address item) async {
    final db = await _dbHelper.database;
    final data = item.toJson();
    await db.insert('addresses', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(Address item) async {
    await insert(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    final db = await _dbHelper.database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Address>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('addresses');
    return maps.map((map) => Address.fromJson(map)).toList();
  }

  @override
  Future<Address?> getById(dynamic id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('addresses', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Address.fromJson(maps.first);
  }

  @override
  Future<void> syncFromLocal(List<Address> items) async {}

  @override
  Future<List<Address>> findWhere(bool Function(Address) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }
}
