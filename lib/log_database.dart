import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'logs';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<List<Map<String, dynamic>>> getLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('logs', orderBy: 'id DESC');
    return maps;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'your_database.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute('''
  CREATE TABLE $tableName (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    logTitle TEXT,
    logRoutine TEXT,
    logDate TEXT,
    logTime TEXT,
    logDescription TEXT,
    workoutType TEXT,
    selectedGear TEXT,
    logDuration TEXT,
    type TEXT,
    foodItems TEXT,
    recipes TEXT
  )
''');
      },
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN foodItems TEXT');
      await db.execute('ALTER TABLE $tableName ADD COLUMN type TEXT');
      await db.execute('ALTER TABLE $tableName ADD COLUMN recipes TEXT');
    }
  }


  Future<int> insertLog(Map<String, dynamic> log) async {
    Database db = await database;
    return await db.insert(tableName, log);
  }

  Future<void> deleteLog(int id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
