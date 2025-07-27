import 'package:flutter/material.dart';
import '../services/base_data_service.dart';
import '../services/connectivity_service.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  final ConnectivityService _connectivityService = ConnectivityService();

  late BaseDataService<T> localService;
  late BaseDataService<T> remoteService;

  List<T> _items = [];
  List<T> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final hasInternet = await _connectivityService.hasInternetConnection();
      if (hasInternet) {
        _items = await remoteService.getAll();
      } else {
        _items = await localService.getAll();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrUpdateItem(T item) async {
    _isLoading = true;
    notifyListeners();
    try {
      final hasInternet = await _connectivityService.hasInternetConnection();
      if (hasInternet) {
        await remoteService.update(item);
        await localService.update(item);
      } else {
        await localService.update(item);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      await fetchItems();
    }
  }

  Future<void> deleteItem(dynamic id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final hasInternet = await _connectivityService.hasInternetConnection();
      if (hasInternet) {
        await remoteService.delete(id);
        await localService.delete(id);
      } else {
        await localService.delete(id);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      await fetchItems();
    }
  }

  Future<void> syncOfflineData() async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet) return;
    final pendingItems = await localService.findWhere((item) {
      // Передбачає, що у моделі є isPending та isDeleted
      final map = (item as dynamic).toJson();
      return map['isPending'] == true && map['isDeleted'] == false;
    });
    for (final item in pendingItems) {
      try {
        await remoteService.update(item);
        await localService.update(item);
      } catch (_) {}
    }
    notifyListeners();
  }
}
