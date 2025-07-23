import 'dart:convert';
import 'dart:math';
import 'package:inn_logist_app/models/address.dart';
import 'package:inn_logist_app/models/ltd_lng.dart' hide Order;
import 'package:inn_logist_app/models/progress.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'models/order.dart';
import 'models/driver.dart';
import 'models/transport.dart';
import 'models/expense.dart';
import 'models/downloaded_file.dart';
import 'models/report.dart';
import 'models/way.dart';
import 'models/location.dart';
import 'models/status.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inn_logist.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY,
        status TEXT,
        client_name TEXT,
        client_phone TEXT,
        progress TEXT,
        cargo TEXT,
        current_price REAL,
        currency TEXT,
        payment_type TEXT,
        arrival_time TEXT,
        addresses TEXT,
        download_date TEXT,
        upload_date TEXT,
        documents TEXT,
        locations TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE drivers (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        phone TEXT,
        avatar TEXT,
        company_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transports (
        id INTEGER PRIMARY KEY,
        number TEXT,
        status_id INTEGER,
        model TEXT,
        tonnage INTEGER,
        monitoring TEXT,
        company TEXT,
        type TEXT,
        rolling_stock_type TEXT,
        avatar TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        fuel INTEGER,
        fuel_liters INTEGER,
        parking INTEGER,
        parts INTEGER,
        other INTEGER,
        comment TEXT,
        fuel_consumption INTEGER,
        buy_time TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE downloaded_files (
        id INTEGER PRIMARY KEY,
        order_id INTEGER,
        file_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ways (
        id INTEGER PRIMARY KEY,
        order_id INTEGER,
        list TEXT
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
        distance_empty REAL,
        duration TEXT,
        amount INTEGER,
        amount_fact INTEGER,
        orders INTEGER,
        date_from TEXT,
        date_to TEXT,
        fuel_balance_start_current_month INTEGER,
        last_trip_days INTEGER,
        expenses INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE statuses (
        id INTEGER PRIMARY KEY,
        order_id INTEGER,
        address TEXT,
        lat REAL,
        lng REAL,
        date TEXT
      )
    ''');
  }

  // Driver
  Future<void> upsertDriver(Driver driver) async {
    final db = await database;
    await db.insert(
      'drivers',
      driver.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Driver?> getDriver(int id) async {
    final db = await database;
    final maps = await db.query('drivers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Driver.fromJson(maps.first);
  }

  // Transport
  Future<void> upsertTransport(Transport transport) async {
    final db = await database;
    await db.insert(
      'transports',
      transport.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Transport?> getTransport(int id) async {
    final db = await database;
    final maps = await db.query('transports', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Transport.fromJson(maps.first);
  }

  // Expense
  Future<void> upsertExpense(Expense expense) async {
    final db = await database;
    final existing = await db.query('expenses',
        where: 'id = ?', whereArgs: ['${expense.fuel}_${expense.time}']);
    if (existing.isNotEmpty) {
      await db.update(
        'expenses',
        expense.toJson(),
        where: 'id = ?',
        whereArgs: ['${expense.fuel}_${expense.time}'],
      );
    } else {
      await db.insert(
        'expenses',
        {
          'id': '${expense.fuel}_${expense.time}',
          ...expense.toJson(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query('expenses');
    return maps.map((map) => Expense.fromJson(map)).toList();
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // DownloadedFile
  Future<void> upsertDownloadedFile(DownloadedFile file) async {
    final db = await database;
    await db.insert(
      'downloaded_files',
      file.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DownloadedFile>> getDownloadedFiles() async {
    final db = await database;
    final maps = await db.query('downloaded_files');
    return maps.map((map) => DownloadedFile.fromJson(map)).toList();
  }

  Future<void> deleteDownloadedFile(int id) async {
    final db = await database;
    await db.delete('downloaded_files', where: 'id = ?', whereArgs: [id]);
  }

  // Way
  Future<void> upsertLocation(int orderId, LtdLng location) async {
    final db = await database;
    final maps =
        await db.query('ways', where: 'order_id = ?', whereArgs: [orderId]);
    if (maps.isEmpty) {
      await db.insert(
        'ways',
        {
          'order_id': orderId,
          'list': jsonEncode([location.toJson()]),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      final way = Way.fromJson(maps.first);
      way.list.add(LatLng(location.lat, location.lng));
      await db.update(
        'ways',
        {
          'list': jsonEncode(way.list
              .map((e) => {'lat': e.latitude, 'lng': e.longitude})
              .toList())
        },
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
    }
  }

  Future<Way?> getWay(int orderId) async {
    final db = await database;
    final maps =
        await db.query('ways', where: 'order_id = ?', whereArgs: [orderId]);
    if (maps.isEmpty) return null;
    return Way.fromJson(maps.first);
  }

  Future<void> deleteLocations(int orderId) async {
    final db = await database;
    await db.update(
      'ways',
      {'list': jsonEncode([])},
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<LatLng?> getLastLocation(int orderId) async {
    final way = await getWay(orderId);
    if (way != null && way.list.isNotEmpty) {
      return way.list.last;
    }
    return null;
  }

  // Report
  Future<void> upsertReport(Report report) async {
    final db = await database;
    await db.insert(
      'reports',
      report.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Report?> getReport(int id) async {
    final db = await database;
    final maps = await db.query('reports', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Report.fromJson(maps.first);
  }

  // Order
  Future<void> upsertOrder(Order order) async {
    final db = await database;
    await db.insert(
      'orders',
      order.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final maps = await db.query('orders');
    return maps.map((map) => Order.fromJson(map)).toList();
  }

  Future<Order?> getOrder(int id) async {
    final db = await database;
    final maps = await db.query('orders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Order.fromJson(maps.first);
  }

  Future<void> upsertOrderProgress(int orderId, int position, Location location,
      String address, String time) async {
    final db = await database;
    final maps =
        await db.query('orders', where: 'id = ?', whereArgs: [orderId]);
    if (maps.isEmpty) return;

    final order = Order.fromJson(maps.first);
    bool isUpdate = false;
    for (var progress in order.progress) {
      if (progress.position == position) {
        progress.address = Address(
          address: address,
          type: progress.type,
          lat: location.lat,
          lng: location.lng,
          dateAt: time,
        );
        progress.completed = progress.completed == 1 ? 0 : 1;
        isUpdate = true;
        break;
      }
    }
    if (!isUpdate) {
      order.progress.add(Progress(
        name: 'Point $position',
        date: time,
        type: 'unknown',
        position: position,
        completed: 1,
        address: Address(
            address: address,
            type: 'unknown',
            lat: location.lat,
            lng: location.lng,
            dateAt: time),
        statusId: '',
        statusIdHistory: '',
        statusName: '',
      ));
    }
    await db.update(
      'orders',
      {
        'progress': jsonEncode(order.progress.map((e) => e.toJson()).toList()),
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );

    final statusMaps = await db.query('statuses',
        where: 'order_id = ? AND id = ?', whereArgs: [orderId, position]);
    if (statusMaps.isEmpty) {
      await db.insert(
        'statuses',
        {
          'order_id': orderId,
          'id': position,
          'address': address,
          'lat': location.lat,
          'lng': location.lng,
          'date': time,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.update(
        'statuses',
        {
          'address': address,
          'lat': location.lat,
          'lng': location.lng,
          'date': time,
        },
        where: 'order_id = ? AND id = ?',
        whereArgs: [orderId, position],
      );
    }
  }

  Future<double> getDeviation(int orderId, LatLng currentPosition) async {
    final db = await database;
    final maps =
        await db.query('orders', where: 'id = ?', whereArgs: [orderId]);
    if (maps.isEmpty) return 0.0;

    final order = Order.fromJson(maps.first);
    final directions = order.locations;
    if (directions.length < 2) return 0.0;

    List<double> distances = [];
    for (int i = 0; i < directions.length - 1; i++) {
      final distance = _distanceToLine(
        currentPosition,
        LatLng(directions[i].lat, directions[i].lng),
        LatLng(directions[i + 1].lat, directions[i + 1].lng),
      );
      distances.add(distance);
    }
    distances.sort();
    return distances.isNotEmpty ? distances.first : 0.0;
  }

  double _distanceToLine(LatLng p, LatLng start, LatLng end) {
    final double x = p.latitude;
    final double y = p.longitude;
    final double x1 = start.latitude;
    final double y1 = start.longitude;
    final double x2 = end.latitude;
    final double y2 = end.longitude;

    final double A = x - x1;
    final double B = y - y1;
    final double C = x2 - x1;
    final double D = y2 - y1;

    final double dot = A * C + B * D;
    final double len_sq = C * C + D * D;
    final double param = len_sq != 0 ? dot / len_sq : -1;

    double xx, yy;
    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }

    final double dx = x - xx;
    final double dy = y - yy;
    return sqrt(dx * dx + dy * dy);
  }

  Future<void> deleteAllOrders() async {
    final db = await database;
    await db.delete('orders');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
