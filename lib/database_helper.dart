// lib/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type INTEGER,
        data TEXT
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
}
