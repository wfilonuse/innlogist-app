import 'package:sqflite/sqflite.dart';
import '../base_data_service.dart';
import '../../models/expense.dart';
import '../../database_helper.dart';

class ExpenseLocalService extends BaseDataService<Expense> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Expense item) async {
    final db = await _dbHelper.database;
    final data = item.toJson();
    data['isPending'] = item.isPending ? 1 : 0;
    data['isDeleted'] = item.isDeleted ? 1 : 0;
    await db.insert('expenses', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(Expense item) async {
    await insert(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    final db = await _dbHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Expense>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('expenses');
    return maps.map((map) => Expense.fromJson(map)).toList();
  }

  @override
  Future<Expense?> getById(dynamic id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Expense.fromJson(maps.first);
  }

  @override
  Future<void> syncFromLocal(List<Expense> items) async {}

  @override
  Future<List<Expense>> findWhere(bool Function(Expense) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<List<Expense>> getPendingExpenses() async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('expenses', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Expense.fromJson(map)).toList();
  }

  Future<void> markForDeletionExpense(int id) async {
    final db = await _dbHelper.database;
    await db.update('expenses', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
