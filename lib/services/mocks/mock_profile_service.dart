import 'package:inn_logist_app/services/remote/profile_service.dart';

import '../../models/driver.dart';

class MockProfileService extends ProfileService {
  Driver _mockDriver = Driver(
    id: 1,
    name: "Іван",
    email: "ivan.petrenko@example.com",
    phone: "+380501112233",
    companyName: "Тест Логістика",
    avatar: "",
    isPending: true,
    isDeleted: false,
  );

  Future<void> insert(Driver item) async {
    _mockDriver = item;
  }

  Future<void> update(Driver item) async {
    _mockDriver = item;
  }

  Future<void> delete(dynamic id) async {
    if (_mockDriver.id == id) {
      _mockDriver = Driver(
        id: 0,
        name: "",
        email: "",
        phone: "",
        companyName: "",
        avatar: "",
        isPending: false,
        isDeleted: true,
      );
    }
  }

  Future<List<Driver>> getAll() async {
    return [_mockDriver];
  }

  Future<Driver?> getById(dynamic id) async {
    return _mockDriver.id == id ? _mockDriver : null;
  }

  Future<void> syncFromLocal(List<Driver> items) async {}

  Future<List<Driver>> findWhere(bool Function(Driver) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }
}
