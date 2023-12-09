import 'package:final_project/routine.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'logs';
  static const String goalsTableName = 'weeklyGoals';
  static const String locationsTableName = 'locations';
  static const String dailyStatsTableName = 'dailyStats';

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
      version: 14,
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
          calories REAL,
          waterIntake TEXT,
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
        await db.execute('''
        CREATE TABLE $goalsTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          caloriesBurnedGoal INTEGER,
          waterIntakeGoal INTEGER,
          workoutsCompletedGoal INTEGER,
          caloriesGoal INTEGER
        )
      ''');
        await db.execute('''
        CREATE TABLE $locationsTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          latitude REAL,
          longitude REAL,
          timestamp INTEGER
        )
      ''');
      },
      onUpgrade: _onUpgrade,
    );
  }
  Future<double> getDailyCalories() async {
    String today =  DateFormat('MMMM dd, yyyy').format(DateTime.now()); // Get today's date in 'yyyy-MM-dd' format

    Database db = await initDatabase(); // Assuming you've defined initDatabase to initialize your SQLite database
    List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'logDate = ? AND type = ?',
      whereArgs: [today,'meal'],
      columns: ['calories'],
    );
    double totalCalories = result.fold<double>(
      0,
          (previousValue, row) =>
      previousValue + (row['calories'] ?? 0),
    );
    return totalCalories;
  }

  Future<int> getDailyNumberOfWorkouts() async {
    String today =  DateFormat('MMMM dd, yyyy').format(DateTime.now());
    Database db = await initDatabase(); // Assuming you've defined initDatabase to initialize your SQLite database
    List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'logDate = ? AND type = ?',
      whereArgs: [today,'workout'],
    );
    Set<int> routineIds = Set<int>();
    for (var row in result) {
      int routineId = row['routineId'] as int;
      routineIds.add(routineId);
    }

    int numberOfWorkouts = 0;
    for (int routineId in routineIds) {
      List<Map<String, dynamic>> routinesResult = await db.query(
        'routines',
        where: 'id = ? AND workoutCount > 0',
        whereArgs: [routineId],
        columns: ['workoutCount'],
      );
      if (routinesResult.isNotEmpty) {
        numberOfWorkouts += routinesResult[0]['workoutCount'] as int;
      }
    }

    return numberOfWorkouts;
  }
  Future<double> getWeeklyCalories() async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday); // Assuming Sunday is the start of the week
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7)); // A week ahead

    Database db = await initDatabase();
    List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'logDate >= ? AND logDate <= ? AND type = ?',
      whereArgs: [
        DateFormat('MMMM dd, yyyy').format(startOfWeek),
        DateFormat('MMMM dd, yyyy').format(endOfWeek),
        'meal',
      ],
      columns: ['calories'],
    );

    double totalCalories = result.fold<double>(
      0,
          (previousValue, row) => previousValue + (row['calories'] ?? 0),
    );
    return totalCalories;
  }

  Future<int> getWeeklyNumberOfWorkouts() async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday); // Assuming Sunday is the start of the week
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7)); // A week ahead

    Database db = await initDatabase();
    List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'logDate >= ? AND logDate <= ? AND type = ?',
      whereArgs: [
        DateFormat('MMMM dd, yyyy').format(startOfWeek),
        DateFormat('MMMM dd, yyyy').format(endOfWeek),
        'workout',
      ],
    );

    Set<int> routineIds = {};
    for (var row in result) {
      routineIds.add(row['routineId'] as int);
    }

    int numberOfWorkouts = 0;
    for (int routineId in routineIds) {
      List<Map<String, dynamic>> routinesResult = await db.query(
        'routines',
        where: 'id = ? AND workoutCount > 0',
        whereArgs: [routineId],
        columns: ['workoutCount'],
      );
      if (routinesResult.isNotEmpty) {
        numberOfWorkouts += routinesResult[0]['workoutCount'] as int;
      }
    }

    return numberOfWorkouts;
  }

  Future<int> getWeeklyWaterIntake() async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday); // Assuming Sunday is the start of the week
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7)); // A week ahead

    Database db = await initDatabase();
    List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'logDate >= ? AND logDate <= ? AND type = ?',
      whereArgs: [
        DateFormat('MMMM dd, yyyy').format(startOfWeek),
        DateFormat('MMMM dd, yyyy').format(endOfWeek),
        'water',
      ],
      columns: ['waterIntake'],
    );

    int totalWaterIntake = result.fold<int>(
      0,
          (previousValue, row) => previousValue + (int.tryParse(row['waterIntake'] ?? '') ?? 0),
    );
    return totalWaterIntake;
  }

  Future<int> getDailyWaterIntake() async {
    String today = DateFormat('MMMM dd, yyyy').format(DateTime.now()); // Get today's date in 'yyyy-MM-dd' format

    Database db = await initDatabase(); // Assuming you've defined initDatabase to initialize your SQLite database
    List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'logDate = ? AND type = ?',
      whereArgs: [today, 'water'], // Assuming 'water' is the type for water intake logs
      columns: ['waterIntake'],
    );
    int totalWaterIntake = result.fold<int>(
      0,
          (previousValue, row) =>
      previousValue + (int.tryParse(row['waterIntake'] ?? '') ?? 0),
    );
    return totalWaterIntake;
  }
  Future<void> insertLocation(double latitude, double longitude, int timestamp) async {
    await _database?.insert('locations', {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
    });
  }
  Future<double> getTotalDistance() async {
    final List<Map<String, dynamic?>>? locations = await _database?.query('locations');
    double totalDistance = 0;

    for (int i = 0; i < locations!.length - 1; i++) {
      double lat1 = locations[i]['latitude'] as double;
      double lon1 = locations[i]['longitude'] as double;
      double lat2 = locations[i + 1]['latitude'] as double;
      double lon2 = locations[i + 1]['longitude'] as double;

      totalDistance += Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    }

    return totalDistance;
  }
  Future<double> getDailyDistance() async {
    final List<Map<String, dynamic>>? locations =
    await _database?.query('locations');

    double totalDistance = 0;
    DateTime now = DateTime.now();
    int todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    int todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;

    if (locations != null) {
      for (int i = 0; i < locations.length - 1; i++) {
        int timestamp = locations[i]['timestamp'] as int;

        // Check if the location was recorded within the current day
        if (timestamp >= todayStart && timestamp <= todayEnd) {
          double lat1 = locations[i]['latitude'] as double;
          double lon1 = locations[i]['longitude'] as double;
          double lat2 = locations[i + 1]['latitude'] as double;
          double lon2 = locations[i + 1]['longitude'] as double;

          totalDistance += Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
        }
      }
    }

    return totalDistance;
  }
  Future<void> insertWeeklyGoals(Map<String, int> goals) async {
    final db = await database;
    await db.insert(
      goalsTableName,
      goals,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<Map<String, int>> getWeeklyGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(goalsTableName);

    if (maps.isNotEmpty) {
      return {
        'caloriesBurnedGoal': maps[0]['caloriesBurnedGoal'],
        'waterIntakeGoal': maps[0]['waterIntakeGoal'],
        'workoutsCompletedGoal': maps[0]['workoutsCompletedGoal'],
        'caloriesGoal': maps[0]['caloriesGoal'],
      };
    } else {
      return {
        'caloriesBurnedGoal': 0,
        'waterIntakeGoal': 0,
        'workoutsCompletedGoal': 0,
        'caloriesGoal': 0,
      };
    }
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
        id: maps[i]['id'] ?? 0,
        name: maps[i]['name'],
        days: maps[i]['days'],
        equipment: maps[i]['equipment'],
        workouts: maps[i]['workouts'].split(', '),
        workoutCount: maps[i]['workoutCount'] ?? 0,
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 14) {
      // Adding the 'calories' column to the existing table
      await db.execute('ALTER TABLE $tableName ADD calories REAL');
    }
    // Add more upgrade logic for future versions if needed
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
      int? routineId = log['routineId']; // Use int? to handle potential null values

      if (routineId != null) {
        int workoutCount = await _getWorkoutCountForRoutine(db, routineId);

        if (totalWorkoutsPerLog.containsKey(routineId)) {
          totalWorkoutsPerLog[routineId] = (totalWorkoutsPerLog[routineId] ?? 0) + workoutCount;
        } else {
          totalWorkoutsPerLog[routineId] = workoutCount;
        }
      }
    }

    return totalWorkoutsPerLog;
  }


  Future<Map<String, dynamic>> _getRoutine(Database db, int routineId) async {
    final routines = await db.query(
      'routines',
      where: 'id = ?',
      whereArgs: [routineId],
    );

    return routines.isNotEmpty ? routines.first : {};
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