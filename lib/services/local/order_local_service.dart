import 'package:sqflite/sqflite.dart';
import '../base_data_service.dart';
import '../../models/order.dart';
import '../../database_helper.dart';

class OrderLocalService extends BaseDataService<Order> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Order item) async {
    final db = await _dbHelper.database;
    final data = {
      'id': item.id,
      'status': item.status,
      'clientName': item.clientName,
      'clientPhone': item.clientPhone,
      'cargo': item.cargo.toJson().toString(),
      'currentPrice': item.currentPrice,
      'currency': item.currency,
      'paymentType': item.paymentType,
      'arrivalTime': item.arrivalTime,
      'downloadDate': item.downloadDate,
      'uploadDate': item.uploadDate,
      'addresses': item.addresses.map((e) => e.toJson()).toList().toString(),
      'documents': item.documents.map((e) => e.toJson()).toList().toString(),
      'locations': item.locations.map((e) => e.toJson()).toList().toString(),
      'progress': item.progress?.map((e) => e.toJson()).toList().toString(),
      'isPending': item.isPending ? 1 : 0,
      'isDeleted': item.isDeleted ? 1 : 0,
    };
    await db.insert('orders', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(Order item) async {
    await insert(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    final db = await _dbHelper.database;
    await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Order>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('orders');
    return maps
        .map((map) => Order.fromJson({
              'id': map['id'],
              'status': map['status'],
              'clientName': map['clientName'],
              'clientPhone': map['clientPhone'],
              'cargo': map['cargo'],
              'currentPrice': map['currentPrice'],
              'currency': map['currency'],
              'paymentType': map['paymentType'],
              'arrivalTime': map['arrivalTime'],
              'downloadDate': map['downloadDate'],
              'uploadDate': map['uploadDate'],
              'addresses': map['addresses'],
              'documents': map['documents'],
              'locations': map['locations'],
              'progress': map['progress'],
              'isPending': map['isPending'] == 1,
              'isDeleted': map['isDeleted'] == 1,
            }))
        .toList();
  }

  @override
  Future<Order?> getById(dynamic id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('orders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Order.fromJson(maps.first);
  }

  @override
  Future<void> syncFromLocal(List<Order> items) async {}

  @override
  Future<List<Order>> findWhere(bool Function(Order) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<List<Order>> getPendingOrders() async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('orders', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Order.fromJson(map)).toList();
  }

  Future<void> markForDeletionOrder(int id) async {
    final db = await _dbHelper.database;
    await db.update('orders', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
