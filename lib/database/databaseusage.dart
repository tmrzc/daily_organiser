import 'package:sqflite/sqflite.dart';
import 'todomodel.dart';
import 'trackermodel.dart';
import 'statsmodel.dart';
import 'package:path/path.dart';

class OrganiserDatabase {
  static final OrganiserDatabase instance = OrganiserDatabase._init();

  static Database? _database;

  OrganiserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('database1.db');
    return _database!;
  }

  //late String path1;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    //path1 = path;

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'DOUBLE NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const doubleTypeNULLABLE = 'DOUBLE';
    const integerTypeNULLABLE = 'INTEGER';

    await db.execute('''
    CREATE TABLE currentTime (
      current_time $textType
    ) 
    ''');

    await db.execute('''
    CREATE TABLE $tableTodo (
      ${TodoTable.id} $idType,
      ${TodoTable.value_todo} $textType,
      ${TodoTable.isDone} $boolType
    )''');

    await db.execute('''
    CREATE TABLE $tableTracker (
      ${TrackerTable.id_tracker} $idType,
      ${TrackerTable.name_tracker} $textType,
      ${TrackerTable.type_tracker} $textType,
      ${TrackerTable.color_id} $integerType,
      ${TrackerTable.range_tracker} $integerType,
      ${TrackerTable.isLocked} $boolType,
      ${TrackerTable.value} $doubleTypeNULLABLE,
      ${TrackerTable.stats_id} $integerTypeNULLABLE
    )''');

    await db.execute('''
    CREATE TABLE $tableStats (
      ${TrackerStats.id_stats} $idType,
      ${TrackerStats.tracker_id} $integerType,
      ${TrackerStats.date_year} $integerType,
      ${TrackerStats.date_month} $integerType,
      ${TrackerStats.date_day} $integerType,
      ${TrackerStats.value_stats} $doubleType
    )''');
  }

  Future<void> deleteDatabase(String path) =>
      databaseFactory.deleteDatabase(path);

// ------ TODO DATABASE ------

  Future<Todo> createTodo(Todo todo) async {
    final db = await instance.database;

    final id = await db.insert(tableTodo, todo.toJson());
    //await db.close();
    //await deleteDatabase(path1);

    return todo.copy(id: id);
  }

  Future<List<Todo>> readTodos(bool status) async {
    final db = await instance.database;

    final listOfMaps = await db.query(tableTodo,
        columns: TodoTable.values,
        where: '${TodoTable.isDone} = ?',
        orderBy: '${TodoTable.id} DESC',
        whereArgs: [status ? 1 : 0]);

    return listOfMaps.map((json) => Todo.fromJson(json)).toList();
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await instance.database;

    return db.update(
      tableTodo,
      todo.toJson(),
      where: '${TodoTable.id} = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(Todo todo) async {
    final db = await instance.database;

    return db.delete(
      tableTodo,
      where: '${TodoTable.id} = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteDoneTodo() async {
    final db = await instance.database;

    return db.delete(
      tableTodo,
      where: '${TodoTable.isDone} = ?',
      whereArgs: [1],
    );
  }

// ------ TRACKER DATABASE ------

  Future<Tracker> createTracker(Tracker tracker) async {
    final db = await instance.database;

    final id = await db.insert(tableTracker, tracker.toJson());

    return tracker.copy(id: id);
  }

  Future<List<Tracker>> readTrackers() async {
    final db = await instance.database;

    final listOfMaps = await db.query(
      tableTracker,
      columns: TrackerTable.values,
    );

    return listOfMaps.map((json) => Tracker.fromJson(json)).toList();
  }

  Future<int> updateTracker(Tracker tracker) async {
    final db = await instance.database;

    return db.update(
      tableTracker,
      tracker.toJson(),
      where: '${TrackerTable.id_tracker} = ?',
      whereArgs: [tracker.id],
    );
  }

  Future<int> deleteTracker(Tracker tracker) async {
    final db = await instance.database;

    return db.delete(
      tableTracker,
      where: '${TrackerTable.id_tracker} = ?',
      whereArgs: [tracker.id],
    );
  }

  Future<int> unlockAllTrackers() async {
    final db = await instance.database;

    return db.rawUpdate('''
    UPDATE $tableTracker 
    SET ${TrackerTable.isLocked} = ?, ${TrackerTable.stats_id} = ?
    ''', [0, null]);
  }

// ------ CURRENT TIME DATABASE ------

  Future<List<Map>> checkSavedDay() async {
    final db = await instance.database;

    return db.query('currentTime', limit: 1);
  }

  Future<int> resetTime(String iso8601) async {
    final db = await instance.database;

    db.delete('currentTime');

    return db.rawInsert('''
    INSERT INTO currentTime (current_time)
    VALUES (?)
    ''', [iso8601]);
  }

// ------ STATS DATABASE ------

  Future<Stat> createStat(Stat stat) async {
    final db = await instance.database;

    final id = await db.insert(tableStats, stat.toJson());

    return stat.copy(id: id);
  }

  Future<int> deleteStat(int stat_id) async {
    final db = await instance.database;

    return db.delete(
      tableStats,
      where: '${TrackerStats.id_stats} = ?',
      whereArgs: [stat_id],
    );
  }

  Future<int> clearAfterDeletingTracker(int tracker_id) async {
    final db = await instance.database;

    return db.delete(
      tableStats,
      where: '${TrackerStats.tracker_id} = ?',
      whereArgs: [tracker_id],
    );
  }

  Future<List<Stat>> importLastXDays(int tracker_id, int howManyDays) async {
    final db = await instance.database;
    List<Stat> listOfXDays = [];

    for (int i = 0; i < howManyDays; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      final listOfMaps = await db.query(
        tableStats,
        where: '''
        ${TrackerStats.tracker_id} = ? AND 
        ${TrackerStats.date_year} = ? AND
        ${TrackerStats.date_month} = ? AND
        ${TrackerStats.date_day} = ? 
        ''',
        whereArgs: [
          tracker_id,
          date.year,
          date.month,
          date.day,
        ],
      );
      Stat stat = listOfMaps.isEmpty
          ? Stat(
              tracker_id: tracker_id,
              year: date.year,
              month: date.month,
              day: date.day,
              value: 0,
            )
          : listOfMaps.map((json) => Stat.fromJson(json)).toList()[0];

      listOfXDays.add(stat);
    }

    return listOfXDays;
  }

  Future<double> returnHighestValue(int tracker_id) async {
    final db = await instance.database;

    List<Map<String, Object?>> listOfMaps = await db.query(
      tableStats,
      where: '${TrackerStats.tracker_id} = ?',
      whereArgs: [tracker_id],
      orderBy: '${TrackerStats.value_stats}',
      limit: 1,
    );

    return listOfMaps.isEmpty
        ? 10
        : listOfMaps.map((json) => Stat.fromJson(json)).toList()[0].value;
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
