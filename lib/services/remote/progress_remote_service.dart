import 'package:inn_logist_app/models/sync_task.dart';

import '../base_data_service.dart';
import '../../models/progress.dart';
import 'package:http/http.dart' as http;
import '../../build_config.dart';
import 'dart:convert';

class ProgressRemoteService extends BaseDataService<Progress> {
  @override
  Future<void> insert(Progress item) => update(item);

  @override
  Future<void> update(Progress progress) async {
    final token = await super.getToken();
    final response = await http.post(
      Uri.parse('${BuildConfig.baseUrl}/progress/check/${progress.id ?? ''}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'data': progress.toJson()}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update progress: ${response.statusCode}');
    }
  }

  @override
  Future<void> delete(dynamic id) async {
    // Реалізуйте, якщо є endpoint для видалення прогресу
  }

  @override
  Future<List<Progress>> getAll() async {
    // No direct endpoint for all progress, return empty list or implement if needed
    return [];
  }

  @override
  Future<Progress?> getById(dynamic id) async {
    // No direct endpoint for single progress, return null or implement if needed
    return null;
  }

  @override
  Future<void> syncFromLocal(List<Progress> items) async {
    for (final progress in items) {
      await update(progress);
    }
  }

  @override
  Future<List<Progress>> findWhere(bool Function(Progress) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  @override
  Future<void> insertFromTask(SyncTask task) async {
    final progress = Progress.fromJson(task.data);
    await update(progress);
  }

  @override
  Future<void> updateFromTask(SyncTask task) async {
    final progress = Progress.fromJson(task.data);
    await update(progress);
  }

  @override
  Future<void> deleteFromTask(SyncTask task) async {
    final id = task.data['id'];
    await delete(id);
  }
}
