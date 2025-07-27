import 'package:shared_preferences/shared_preferences.dart';
import '../models/sync_task.dart';

abstract class BaseDataService<T> {
  // CRUD
  Future<void> insert(T item);
  Future<void> update(T item);
  Future<void> delete(dynamic id);
  Future<List<T>> getAll();
  Future<T?> getById(dynamic id);

  // Синхронізація (для remote)
  Future<void> syncFromLocal(List<T> items);

  // Пошук за умовою (для local)
  Future<List<T>> findWhere(bool Function(T) test);

  // Доступ до токена для remote-сервісів
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Методи для синхронізації через SyncTask
  Future<void> insertFromTask(SyncTask task) async {}
  Future<void> updateFromTask(SyncTask task) async {}
  Future<void> deleteFromTask(SyncTask task) async {}
}
