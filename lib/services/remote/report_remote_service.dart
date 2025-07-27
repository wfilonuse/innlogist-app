import 'package:inn_logist_app/models/sync_task.dart';

import '../base_data_service.dart';
import '../../models/report.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../build_config.dart';
import 'dart:convert';

class ReportRemoteService extends BaseDataService<Report> {
  @override
  Future<void> insert(Report item) => update(item);

  @override
  Future<void> update(Report report) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('${BuildConfig.baseUrl}/report/update/${report.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(report.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update report: ${response.statusCode}');
    }
  }

  @override
  Future<void> delete(dynamic id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('${BuildConfig.baseUrl}/report/delete/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete report: ${response.statusCode}');
    }
  }

  @override
  Future<List<Report>> getAll() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${BuildConfig.baseUrl}/report/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Report.fromJson(json)).toList();
    }
    throw Exception('Failed to load reports');
  }

  @override
  Future<Report?> getById(dynamic id) async {
    final reports = await getAll();
    return reports.firstWhere((r) => r.id == id);
  }

  @override
  Future<void> syncFromLocal(List<Report> items) async {
    for (final report in items) {
      await update(report);
    }
  }

  @override
  Future<List<Report>> findWhere(bool Function(Report) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  @override
  Future<void> insertFromTask(SyncTask task) async {
    final report = Report.fromJson(task.data);
    await update(report);
  }

  @override
  Future<void> updateFromTask(SyncTask task) async {
    final report = Report.fromJson(task.data);
    await update(report);
  }

  @override
  Future<void> deleteFromTask(SyncTask task) async {
    final id = task.data['id'];
    await delete(id);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
