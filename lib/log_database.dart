import 'package:final_project/routine.dart';
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
      version: 10,
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
          logDuration TEXT,
          type TEXT,
          foodItems TEXT,
          recipes TEXT,
          routineId INTEGER,
          FOREIGN KEY (routineId) REFERENCES routines(id)
        )
      ''');
        await db.execute('''
        CREATE TABLE routines (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          days TEXT,
          equipment TEXT,
          workouts TEXT,
          workoutCount INTEGER
        )
      ''');
      },
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> insertRoutine(Routine routine) async {
    final db = await database;
    await db.insert(
      'routines',
      routine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Routine>> getRoutines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('routines');

    return List.generate(maps.length, (i) {
      return Routine(
        id: maps[i]['id'],
        name: maps[i]['name'],
        days: maps[i]['days'],
        equipment: maps[i]['equipment'],
        workouts: maps[i]['workouts'].split(', '),
        workoutCount: maps[i]['workoutCount'],
      );
    });
  }

  Future<void> deleteRoutine(int id) async {
    final db = await database;
    await db.delete(
      'routines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRoutine(Routine routine) async {
    final db = await database;

    await db.update(
      'routines',
      routine.toMap(),
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 10) {
      await db.execute('''
      ALTER TABLE routines ADD COLUMN workoutCount INTEGER;
    ''');
    }
  }

  Future<Routine> getRoutineById(int routineId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'routines',
      where: 'id = ?',
      whereArgs: [routineId],
    );

    if (maps.isNotEmpty) {
      return Routine(
        id: maps[0]['id'],
        name: maps[0]['name'],
        days: maps[0]['days'],
        equipment: maps[0]['equipment'],
        workouts: maps[0]['workouts'].split(', '),
        workoutCount: maps[0]['workoutCount'],
      );
    } else {
      throw Exception('Routine not found');
    }
  }


  Future<int> insertLog(Map<String, dynamic> log) async {
    Database db = await database;
    return await db.insert(tableName, log);
  }
  Future<Map<int, int>> getTotalWorkoutsPerLog() async {
    final db = await database;
    final List<Map<String, dynamic>> logs = await db.query('logs');

    Map<int, int> totalWorkoutsPerLog = {};

    for (var log in logs) {
      int routineId = log['routineId'];
      int workoutCount = await _getWorkoutCountForRoutine(db, routineId);

      if (totalWorkoutsPerLog.containsKey(routineId)) {
        totalWorkoutsPerLog[routineId] = (totalWorkoutsPerLog[routineId] ?? 0) + workoutCount;
      } else {
        totalWorkoutsPerLog[routineId] = workoutCount;
      }
    }

    return totalWorkoutsPerLog;
  }


  Future<int> _getWorkoutCountForRoutine(Database db, int routineId) async {
    final List<Map<String, dynamic>> routines = await db.query(
      'routines',
      where: 'id = ?',
      whereArgs: [routineId],
    );

    if (routines.isNotEmpty) {
      return routines[0]['workoutCount'] ?? 0;
    } else {
      return 0;
    }
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
