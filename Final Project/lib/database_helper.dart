import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/stock_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartstock.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // We store the Symbol, Name, and the Price at which you bought it
    await db.execute('''
      CREATE TABLE portfolio (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT,
        name TEXT,
        price REAL,
        changePercent REAL
      )
    ''');
  }

  Future<void> insertStock(Stock stock) async {
    final db = await instance.database;
    await db.insert(
        'portfolio',
        stock.toMap(), // We will add this function to your model next
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<Stock>> getPortfolio() async {
    final db = await instance.database;
    final result = await db.query('portfolio');

    return result.map((json) => Stock.fromMap(json)).toList();
  }
}