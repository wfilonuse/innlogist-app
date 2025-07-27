import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../models/sync_task.dart';
import '../services/remote/document_remote_service.dart';
import '../services/remote/report_remote_service.dart';
import '../services/remote/order_remote_service.dart';
import '../services/remote/expense_remote_service.dart';
import '../services/remote/progress_remote_service.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  SyncService._init();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Додаємо SyncTask у чергу
  Future<void> addSyncTask(SyncTask task) async {
    final db = await _dbHelper.database;
    await db.insert('sync_queue', task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Отримуємо всі SyncTask з черги
  Future<List<SyncTask>> getSyncQueue() async {
    final db = await _dbHelper.database;
    final maps = await db.query('sync_queue');
    return maps.map((map) => SyncTask.fromJson(map)).toList();
  }

  // Видаляємо SyncTask з черги
  Future<void> removeSyncTask(int id) async {
    final db = await _dbHelper.database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> syncAll() async {
    final List<SyncTask> tasks = await getSyncQueue();
    for (final task in tasks) {
      try {
        switch (task.type) {
          case SyncTaskType.documentUpload:
            await DocumentRemoteService().insertFromTask(task);
            break;
          case SyncTaskType.documentDelete:
            await DocumentRemoteService().deleteFromTask(task);
            break;
          case SyncTaskType.reportAdd:
            await ReportRemoteService().insertFromTask(task);
            break;
          case SyncTaskType.reportUpdate:
            await ReportRemoteService().updateFromTask(task);
            break;
          case SyncTaskType.reportDelete:
            await ReportRemoteService().deleteFromTask(task);
            break;
          case SyncTaskType.expenseAdd:
            await ExpenseRemoteService().insertFromTask(task);
            break;
          case SyncTaskType.expenseDelete:
            await ExpenseRemoteService().deleteFromTask(task);
            break;
          case SyncTaskType.orderAdd:
            await OrderRemoteService().insertFromTask(task);
            break;
          case SyncTaskType.orderUpdate:
            await OrderRemoteService().updateFromTask(task);
            break;
          case SyncTaskType.orderDelete:
            await OrderRemoteService().deleteFromTask(task);
            break;
          case SyncTaskType.progressUpdate:
            await ProgressRemoteService().updateFromTask(task);
            break;
          case SyncTaskType.progressDelete:
            await ProgressRemoteService().deleteFromTask(task);
            break;
          // додайте інші типи за потреби
        }
        await removeSyncTask(task.id!);
      } catch (_) {
        // залишаємо задачу в черзі для повторної спроби
      }
    }
  }
}
