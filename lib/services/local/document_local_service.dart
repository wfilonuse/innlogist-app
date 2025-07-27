import 'package:sqflite/sqflite.dart';

import '../base_data_service.dart';
import '../../models/document.dart';
import '../../database_helper.dart';

class DocumentLocalService extends BaseDataService<Document> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insert(Document item) async {
    final db = await _dbHelper.database;
    final data = item.toJson();
    data['isPending'] = item.isPending ? 1 : 0;
    data['isDeleted'] = item.isDeleted ? 1 : 0;
    await db.insert('documents', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> update(Document item) async {
    await insert(item);
  }

  @override
  Future<void> delete(dynamic id) async {
    final db = await _dbHelper.database;
    await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Document>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('documents');
    return maps.map((map) => Document.fromJson(map)).toList();
  }

  @override
  Future<Document?> getById(dynamic id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('documents', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Document.fromJson(maps.first);
  }

  @override
  Future<void> syncFromLocal(List<Document> items) async {
    // локальний сервіс не синхронізує на сервер
  }

  @override
  Future<List<Document>> findWhere(bool Function(Document) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<List<Document>> getPendingDocuments() async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('documents', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Document.fromJson(map)).toList();
  }

  Future<void> markForDeletionDocument(int id) async {
    final db = await _dbHelper.database;
    await db.update('documents', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
