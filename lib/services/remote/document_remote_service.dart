import 'package:inn_logist_app/models/sync_task.dart';

import '../base_data_service.dart';
import '../../models/document.dart';
import 'package:http/http.dart' as http;
import '../../build_config.dart';
import 'dart:convert';

class DocumentRemoteService extends BaseDataService<Document> {
  @override
  Future<void> insert(Document item) => update(item);

  @override
  Future<void> update(Document document) async {
    final token = await super.getToken();
    final response = await http.put(
      Uri.parse('${BuildConfig.baseUrl}/order-document/${document.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(document.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update document: ${response.statusCode}');
    }
  }

  @override
  Future<void> delete(dynamic id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('${BuildConfig.baseUrl}/order-document/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete document: ${response.statusCode}');
    }
  }

  @override
  Future<List<Document>> getAll() async {
    // No direct endpoint for all documents, return empty list or implement if needed
    return [];
  }

  @override
  Future<Document?> getById(dynamic id) async {
    // No direct endpoint for single document, return null or implement if needed
    return null;
  }

  @override
  Future<void> syncFromLocal(List<Document> items) async {
    for (final doc in items) {
      await update(doc);
    }
  }

  @override
  Future<List<Document>> findWhere(bool Function(Document) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  @override
  Future<void> insertFromTask(SyncTask task) async {
    final document = Document.fromJson(task.data);
    await update(document);
  }

  @override
  Future<void> updateFromTask(SyncTask task) async {
    final document = Document.fromJson(task.data);
    await update(document);
  }

  @override
  Future<void> deleteFromTask(SyncTask task) async {
    final id = task.data['id'];
    await delete(id);
  }
}
