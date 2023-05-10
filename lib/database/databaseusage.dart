import 'package:sqflite/sqflite.dart';
import 'todomodel.dart';
import 'trackermodel.dart';
import 'package:path/path.dart';

class OrganiserDatabase {
  static final OrganiserDatabase instance = OrganiserDatabase._init();

  static Database? _database;

  OrganiserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final integerType = 'INTEGER NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final doubleType = 'DOUBLE';

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
      ${TrackerTable.value} $doubleType
    )''');

    /*await db.execute('''
    CREATE TABLE $tableStats (
      ${TrackerStats.id_stats} $idType,
      ${TrackerStats.date_stats} $
    )''');*/
  }

  Future<Todo> createTodo(Todo todo) async {
    final db = await instance.database;

    final id = await db.insert(tableTodo, todo.toJson());

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

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
