import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('soil_analysis.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Таблица Полей
    await db.execute('''
      CREATE TABLE fields (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        area REAL NOT NULL
      )
    ''');

    // Таблица Проб Почвы
    await db.execute('''
      CREATE TABLE soil_samples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        field_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        ph_value REAL NOT NULL,
        nitrogen REAL NOT NULL,     -- Азот (N)
        phosphorus REAL NOT NULL,   -- Фосфор (P)
        potassium REAL NOT NULL,    -- Калий (K)
        crop_name TEXT NOT NULL,    -- Культура
        FOREIGN KEY (field_id) REFERENCES fields (id)
      )
    ''');
    
    // Таблица Рекомендаций (История расчетов)
    await db.execute('''
      CREATE TABLE recommendations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sample_id INTEGER NOT NULL,
        fertilizer_name TEXT NOT NULL,
        dosage REAL NOT NULL,
        date_created TEXT NOT NULL
      )
    ''');
  }

  // Метод добавления пробы
  Future<int> createSample(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('soil_samples', row);
  }

  // Метод получения всех проб
  Future<List<Map<String, dynamic>>> getAllSamples() async {
    final db = await instance.database;
    return await db.query('soil_samples', orderBy: 'date DESC');
  }
}