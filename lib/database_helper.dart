// lib/database_helper.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/document.dart';
import '../models/driver.dart';
import '../models/expense.dart';
import '../models/ltd_lng.dart';
import '../models/order.dart';
import '../models/progress.dart';
import '../models/report.dart';
import '../models/downloaded_file.dart';
import '../models/fuel_consumption.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inn_logist.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fuel INTEGER,
        parking INTEGER,
        parts INTEGER,
        other INTEGER,
        comment TEXT,
        time TEXT,
        isPending INTEGER DEFAULT 1,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY,
        fuel INTEGER,
        parking INTEGER,
        parts INTEGER,
        other INTEGER,
        distance REAL,
        distanceEmpty REAL,
        duration TEXT,
        amount INTEGER,
        amountFact INTEGER,
        orders INTEGER,
        dateFrom TEXT,
        dateTo TEXT,
        fuelBalanceStartCurrentMonth INTEGER,
        lastTripDays INTEGER,
        expenses INTEGER,
        isPending INTEGER DEFAULT 1,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY,
        status TEXT,
        clientName TEXT,
        clientPhone TEXT,
        cargo TEXT,
        currentPrice REAL,
        currency TEXT,
        paymentType TEXT,
        arrivalTime TEXT,
        downloadDate TEXT,
        uploadDate TEXT,
        addresses TEXT,
        documents TEXT,
        locations TEXT,
        progress TEXT,
        isPending INTEGER DEFAULT 1,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        name TEXT,
        date TEXT,
        type TEXT,
        position INTEGER,
        completed INTEGER,
        address TEXT,
        statusId TEXT,
        statusIdHistory TEXT,
        statusName TEXT,
        isPending INTEGER DEFAULT 1,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        lat REAL,
        lng REAL,
        time INTEGER,
        odometer REAL,
        deviation REAL,
        statusId INTEGER,
        isPending INTEGER DEFAULT 1,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE downloaded_files (
        id INTEGER PRIMARY KEY,
        orderId INTEGER,
        fileName TEXT,
        isPending INTEGER DEFAULT 1,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE drivers (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        phone TEXT,
        companyName TEXT,
        avatar TEXT,
        isPending INTEGER DEFAULT 1,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY,
        name TEXT,
        fileName TEXT,
        scope TEXT,
        isPending INTEGER DEFAULT 1,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE fuel_consumption (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        date TEXT,
        isPending INTEGER DEFAULT 1,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }

  // Clear all local data
  Future<void> clearLocalData() async {
    final db = await database;
    await db.execute('DELETE FROM expenses');
    await db.execute('DELETE FROM reports');
    await db.execute('DELETE FROM orders');
    await db.execute('DELETE FROM progress');
    await db.execute('DELETE FROM locations');
    await db.execute('DELETE FROM downloaded_files');
    await db.execute('DELETE FROM drivers');
    await db.execute('DELETE FROM documents');
    await db.execute('DELETE FROM fuel_consumption');
  }

  // Expense methods
  Future<void> upsertExpense(Expense expense, {bool isPending = true}) async {
    final db = await database;
    final data = expense.toJson();
    data['isPending'] = isPending ? 1 : 0;
    await db.insert('expenses', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query('expenses');
    return maps.map((map) => Expense.fromJson(map)).toList();
  }

  Future<List<Expense>> getPendingExpenses() async {
    final db = await database;
    final maps =
        await db.query('expenses', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Expense.fromJson(map)).toList();
  }

  Future<void> deleteExpense(String key) async {
    final db = await database;
    await db.delete('expenses', where: 'time = ?', whereArgs: [key]);
  }

  Future<void> markForDeletionExpense(int id) async {
    final db = await database;
    await db.update('expenses', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // Report methods
  Future<void> upsertReport(Report report, {bool isPending = true}) async {
    final db = await database;
    final data = report.toJson();
    data['isPending'] = isPending ? 1 : 0;
    await db.insert('reports', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Report>> getAllReports() async {
    final db = await database;
    final maps = await db.query('reports');
    return maps.map((map) => Report.fromJson(map)).toList();
  }

  Future<List<Report>> getPendingReports() async {
    final db = await database;
    final maps =
        await db.query('reports', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Report.fromJson(map)).toList();
  }

  Future<void> markSynced(int id) async {
    final db = await database;
    await db.update('reports', {'isPending': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteReport(int id) async {
    final db = await database;
    await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markForDeletionReport(int id) async {
    final db = await database;
    await db.update('reports', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // Order methods
  Future<void> upsertOrder(Order order, {bool isPending = true}) async {
    final db = await database;
    final data = {
      'id': order.id,
      'status': order.status,
      'clientName': order.clientName,
      'clientPhone': order.clientPhone,
      'cargo': jsonEncode(order.cargo.toJson()),
      'currentPrice': order.currentPrice,
      'currency': order.currency,
      'paymentType': order.paymentType,
      'arrivalTime': order.arrivalTime,
      'downloadDate': order.downloadDate,
      'uploadDate': order.uploadDate,
      'addresses': jsonEncode(order.addresses.map((e) => e.toJson()).toList()),
      'documents': jsonEncode(order.documents.map((e) => e.toJson()).toList()),
      'locations': jsonEncode(order.locations.map((e) => e.toJson()).toList()),
      'progress': jsonEncode(order.progress.map((e) => e.toJson()).toList()),
      'isPending': isPending ? 1 : 0,
      'isDeleted': order.isDeleted ? 1 : 0,
    };
    await db.insert('orders', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final maps = await db.query('orders');
    return maps
        .map((map) => Order.fromJson({
              'id': map['id'],
              'status': map['status'],
              'clientName': map['clientName'],
              'clientPhone': map['clientPhone'],
              'cargo': jsonDecode(map['cargo'] as String),
              'currentPrice': map['currentPrice'],
              'currency': map['currency'],
              'paymentType': map['paymentType'],
              'arrivalTime': map['arrivalTime'],
              'downloadDate': map['downloadDate'],
              'uploadDate': map['uploadDate'],
              'addresses': jsonDecode(map['addresses'] as String),
              'documents': jsonDecode(map['documents'] as String),
              'locations': jsonDecode(map['locations'] as String),
              'progress': jsonDecode(map['progress'] as String),
              'isDeleted': map['isDeleted'] as int? ?? 0,
            }))
        .toList();
  }

  Future<List<Order>> getPendingOrders() async {
    final db = await database;
    final maps =
        await db.query('orders', where: 'isPending = 1 AND isDeleted = 0');
    return maps
        .map((map) => Order.fromJson({
              'id': map['id'],
              'status': map['status'],
              'clientName': map['clientName'],
              'clientPhone': map['clientPhone'],
              'cargo': jsonDecode(map['cargo'] as String),
              'currentPrice': map['currentPrice'],
              'currency': map['currency'],
              'paymentType': map['paymentType'],
              'arrivalTime': map['arrivalTime'],
              'downloadDate': map['downloadDate'],
              'uploadDate': map['uploadDate'],
              'addresses': jsonDecode(map['addresses'] as String),
              'documents': jsonDecode(map['documents'] as String),
              'locations': jsonDecode(map['locations'] as String),
              'progress': jsonDecode(map['progress'] as String),
              'isDeleted': map['isDeleted'] as int? ?? 0,
            }))
        .toList();
  }

  Future<void> markForDeletionOrder(int id) async {
    final db = await database;
    await db.update('orders', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // Progress methods
  Future<void> upsertProgress(Progress progress, int orderId,
      {bool isPending = true}) async {
    final db = await database;
    final data = progress.toJson();
    data['order_id'] = orderId;
    data['isPending'] = isPending ? 1 : 0;
    data['isDeleted'] = progress.isDeleted ? 1 : 0;
    await db.insert('progress', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Progress>> getPendingProgress() async {
    final db = await database;
    final maps =
        await db.query('progress', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Progress.fromJson(map)).toList();
  }

  Future<void> markForDeletionProgress(int id) async {
    final db = await database;
    await db.update('progress', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // Location / LtdLng methods
  Future<void> upsertLocation(int orderId, LtdLng geoPoint,
      {bool isPending = true}) async {
    final db = await database;
    final data = geoPoint.toJson();
    data['order_id'] = orderId;
    data['isPending'] = isPending ? 1 : 0;
    data['isDeleted'] = geoPoint.isDeleted ? 1 : 0;
    await db.insert('locations', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LtdLng>> getPendingLocations() async {
    final db = await database;
    final maps =
        await db.query('locations', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => LtdLng.fromJson(map)).toList();
  }

  Future<void> markForDeletionLocation(int id) async {
    final db = await database;
    await db.update('locations', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getDeviation(int orderId) async {
    return 0.0; // Placeholder for deviation logic
  }

  Future<void> deleteLocations(int orderId) async {
    final db = await database;
    await db.delete('locations', where: 'order_id = ?', whereArgs: [orderId]);
  }

  // DownloadedFile methods
  Future<void> upsertDownloadedFile(DownloadedFile file,
      {bool isPending = true}) async {
    final db = await database;
    final data = file.toJson();
    data['isPending'] = isPending ? 1 : 0;
    data['isDeleted'] = file.isDeleted ? 1 : 0;
    await db.insert('downloaded_files', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DownloadedFile>> getDownloadedFiles() async {
    final db = await database;
    final maps = await db.query('downloaded_files');
    return maps.map((map) => DownloadedFile.fromJson(map)).toList();
  }

  Future<List<DownloadedFile>> getPendingDownloadedFiles() async {
    final db = await database;
    final maps = await db.query('downloaded_files',
        where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => DownloadedFile.fromJson(map)).toList();
  }

  Future<void> deleteDownloadedFile(int id) async {
    final db = await database;
    await db.delete('downloaded_files', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markForDeletionDownloadedFile(int id) async {
    final db = await database;
    await db.update('downloaded_files', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // Document methods
  Future<void> upsertDocument(Document document,
      {bool isPending = true}) async {
    final db = await database;
    final data = document.toJson();
    data['isPending'] = isPending ? 1 : 0;
    data['isDeleted'] = document.isDeleted ? 1 : 0;
    await db.insert('documents', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Document>> getDocuments() async {
    final db = await database;
    final maps = await db.query('documents');
    return maps.map((map) => Document.fromJson(map)).toList();
  }

  Future<List<Document>> getPendingDocuments() async {
    final db = await database;
    final maps =
        await db.query('documents', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Document.fromJson(map)).toList();
  }

  Future<void> deleteDocument(int id) async {
    final db = await database;
    await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markForDeletionDocument(int id) async {
    final db = await database;
    await db.update('documents', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // Driver methods
  Future<void> upsertDriver(Driver driver, {bool isPending = true}) async {
    final db = await database;
    final data = driver.toJson();
    data['isPending'] = isPending ? 1 : 0;
    data['isDeleted'] = driver.isDeleted ? 1 : 0;
    await db.insert('drivers', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Driver?> getDriver(int id) async {
    final db = await database;
    final maps = await db.query('drivers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Driver.fromJson(maps.first);
  }

  Future<List<Driver>> getPendingDrivers() async {
    final db = await database;
    final maps =
        await db.query('drivers', where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => Driver.fromJson(map)).toList();
  }

  Future<void> markForDeletionDriver(int id) async {
    final db = await database;
    await db.update('drivers', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // FuelConsumption methods
  Future<void> upsertFuelConsumption(FuelConsumption fuel,
      {bool isPending = true}) async {
    final db = await database;
    final data = fuel.toJson();
    data['isPending'] = isPending ? 1 : 0;
    data['isDeleted'] = fuel.isDeleted ? 1 : 0;
    await db.insert('fuel_consumption', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FuelConsumption>> getPendingFuelConsumption() async {
    final db = await database;
    final maps = await db.query('fuel_consumption',
        where: 'isPending = 1 AND isDeleted = 0');
    return maps.map((map) => FuelConsumption.fromJson(map)).toList();
  }

  Future<void> markForDeletionFuelConsumption(int id) async {
    final db = await database;
    await db.update('fuel_consumption', {'isDeleted': 1, 'isPending': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
