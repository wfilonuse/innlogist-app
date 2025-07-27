import 'package:inn_logist_app/services/remote/report_remote_service.dart';

import '../../models/report.dart';

class MockReportService extends ReportRemoteService {
  final List<Report> _mockReports = [
    Report(
      id: 1,
      fuel: 100,
      parking: 30,
      parts: 50,
      other: 20,
      distance: 420.5,
      distanceEmpty: 50.0,
      duration: "12h",
      amount: 800,
      amountFact: 780,
      orders: 3,
      dateFrom: "2024-07-01",
      dateTo: "2024-07-15",
      fuelBalanceStartCurrentMonth: 200,
      lastTripDays: 2,
      expenses: 200,
      isPending: true,
      isDeleted: false,
    ),
    Report(
      id: 2,
      fuel: 90,
      parking: 10,
      parts: 0,
      other: 15,
      distance: 300.0,
      distanceEmpty: 25.0,
      duration: "10h",
      amount: 600,
      amountFact: 580,
      orders: 2,
      dateFrom: "2024-06-15",
      dateTo: "2024-06-30",
      fuelBalanceStartCurrentMonth: 100,
      lastTripDays: 3,
      expenses: 150,
      isPending: true,
      isDeleted: false,
    ),
  ];

  @override
  Future<void> insert(Report item) async {
    _mockReports.add(item);
  }

  @override
  Future<void> update(Report item) async {
    final index = _mockReports.indexWhere((r) => r.id == item.id);
    if (index != -1) {
      _mockReports[index] = item;
    }
  }

  @override
  Future<void> delete(dynamic id) async {
    _mockReports.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<Report>> getAll() async {
    return _mockReports;
  }

  @override
  Future<Report?> getById(dynamic id) async {
    return _mockReports.firstWhere((r) => r.id == id);
  }

  @override
  Future<void> syncFromLocal(List<Report> items) async {}

  @override
  Future<List<Report>> findWhere(bool Function(Report) test) async {
    return _mockReports.where(test).toList();
  }
}
