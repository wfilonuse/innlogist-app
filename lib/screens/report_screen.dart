import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../database_helper.dart';
import '../models/report.dart';
import '../services/connectivity_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ConnectivityService _connectivityService = ConnectivityService();
  List<Report> _reports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
    _connectivityService.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncReports();
      }
    });
  }

  Future<void> _loadReports() async {
    _isLoading = true;
    try {
      _reports = await _apiService.getAllReports();
    } catch (e) {
      _reports = await _dbHelper.getAllReports();
    }
    _isLoading = false;
  }

  Future<void> _syncReports() async {
    final pending = await _dbHelper.getPendingReports();
    for (var report in pending) {
      try {
        if (report.isDeleted) {
          await _apiService.deleteReport(report.id!);
          await _dbHelper
              .deleteReport(report.id!); // Assuming add deleteReport method
        } else {
          await _apiService.updateReport(report);
          await _dbHelper.markSynced(report.id!);
        }
      } catch (e) {}
    }
    _loadReports();
  }

  Future<void> _addOrEditReport([Report? report]) async {
    final formKey = GlobalKey<FormState>();
    final fuelCtrl = TextEditingController(text: report?.fuel.toString() ?? '');
    final parkingCtrl =
        TextEditingController(text: report?.parking.toString() ?? '');
    final partsCtrl =
        TextEditingController(text: report?.parts.toString() ?? '');
    final otherCtrl =
        TextEditingController(text: report?.other.toString() ?? '');
    final distanceCtrl =
        TextEditingController(text: report?.distance.toString() ?? '');
    final distanceEmptyCtrl =
        TextEditingController(text: report?.distanceEmpty.toString() ?? '');
    final durationCtrl = TextEditingController(text: report?.duration ?? '');
    final amountCtrl =
        TextEditingController(text: report?.amount.toString() ?? '');
    final amountFactCtrl =
        TextEditingController(text: report?.amountFact.toString() ?? '');
    final ordersCtrl =
        TextEditingController(text: report?.orders.toString() ?? '');
    final dateFromCtrl = TextEditingController(text: report?.dateFrom ?? '');
    final dateToCtrl = TextEditingController(text: report?.dateTo ?? '');
    final fuelBalanceCtrl = TextEditingController(
        text: report?.fuelBalanceStartCurrentMonth.toString() ?? '');
    final lastTripDaysCtrl =
        TextEditingController(text: report?.lastTripDays.toString() ?? '');
    final expensesCtrl =
        TextEditingController(text: report?.expenses.toString() ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(report == null ? 'Додати звіт' : 'Редагувати звіт'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: fuelCtrl,
                    decoration: InputDecoration(labelText: 'Паливо'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: parkingCtrl,
                    decoration: InputDecoration(labelText: 'Парковка'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: partsCtrl,
                    decoration: InputDecoration(labelText: 'Запчастини'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: otherCtrl,
                    decoration: InputDecoration(labelText: 'Інші'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: distanceCtrl,
                    decoration: InputDecoration(labelText: 'Відстань'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: distanceEmptyCtrl,
                    decoration: InputDecoration(labelText: 'Відстань порожнім'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: durationCtrl,
                    decoration: InputDecoration(labelText: 'Тривалість')),
                TextFormField(
                    controller: amountCtrl,
                    decoration: InputDecoration(labelText: 'Сума'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: amountFactCtrl,
                    decoration: InputDecoration(labelText: 'Фактична сума'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: ordersCtrl,
                    decoration: InputDecoration(labelText: 'Замовлення'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: dateFromCtrl,
                    decoration: InputDecoration(labelText: 'Дата з')),
                TextFormField(
                    controller: dateToCtrl,
                    decoration: InputDecoration(labelText: 'Дата до')),
                TextFormField(
                    controller: fuelBalanceCtrl,
                    decoration: InputDecoration(
                        labelText: 'Баланс палива на початок місяця'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: lastTripDaysCtrl,
                    decoration:
                        InputDecoration(labelText: 'Дні останньої поїздки'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: expensesCtrl,
                    decoration: InputDecoration(labelText: 'Витрати'),
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text('Скасувати')),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newReport = Report(
                  fuel: int.tryParse(fuelCtrl.text),
                  parking: int.tryParse(parkingCtrl.text),
                  parts: int.tryParse(partsCtrl.text),
                  other: int.tryParse(otherCtrl.text),
                  distance: double.tryParse(distanceCtrl.text),
                  distanceEmpty: double.tryParse(distanceEmptyCtrl.text),
                  duration: durationCtrl.text,
                  amount: int.tryParse(amountCtrl.text),
                  amountFact: int.tryParse(amountFactCtrl.text),
                  orders: int.tryParse(ordersCtrl.text),
                  dateFrom: dateFromCtrl.text,
                  dateTo: dateToCtrl.text,
                  fuelBalanceStartCurrentMonth:
                      int.tryParse(fuelBalanceCtrl.text),
                  lastTripDays: int.tryParse(lastTripDaysCtrl.text),
                  expenses: int.tryParse(expensesCtrl.text),
                );
                final hasInternet =
                    await _connectivityService.hasInternetConnection();
                if (hasInternet) {
                  if (report == null) {
                    await _apiService.addReport(newReport);
                  } else {
                    newReport.id = report.id;
                    await _apiService.updateReport(newReport);
                  }
                } else {
                  await _dbHelper.upsertReport(newReport, isPending: true);
                }
                Navigator.pop(ctx);
                _loadReports();
              }
            },
            child: Text('Зберегти'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReport(Report report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Видалити звіт?'),
        content: Text('Дані будуть видалені назавжди.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text('Ні')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true), child: Text('Так')),
        ],
      ),
    );
    if (confirm == true) {
      final hasInternet = await _connectivityService.hasInternetConnection();
      if (hasInternet) {
        await _apiService.deleteReport(report.id!);
        await _dbHelper.deleteReport(report.id!);
      } else {
        await _dbHelper.markForDeletionReport(report.id!);
      }
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (ctx, idx) {
                final report = _reports[idx];
                return ListTile(
                  title: Text('Звіт ${report.id ?? "Новий"}'),
                  subtitle: Text(
                      'Паливо: ${report.fuel ?? 0}, Парковка: ${report.parking ?? 0}, ...'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _addOrEditReport(report)),
                      IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteReport(report)),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addOrEditReport(),
      ),
    );
  }
}
