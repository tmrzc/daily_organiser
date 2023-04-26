import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:daily_organiser/main.dart';
import 'datamodels.dart';

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

    await db.execute('''
    CREATE TABLE $tableTodo (
      ${TodoTable.id} $idType,
      ${TodoTable.value_todo} $textType,
      ${TodoTable.isDone} $boolType
    )''');

    /*await db.execute('''
    CREATE TABLE $tableTracker (
      ${TrackerTable.id_tracker} $idType,
      ${TrackerTable.name_tracker} $textType,
      ${TrackerTable.type_tracker} $textType,
      ${TrackerTable.color_id} $integerType,
      ${TrackerTable.range_tracker} $integerType
    )''');*/

    /*await db.execute('''
    CREATE TABLE trackersStats (
      tracker_id INTEGER NOT NULL,
      date_submitted TEXT NOT NULL,
      value_submitted REAL NOT NULL
    )''');*/
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  Future<Todo> create(Todo todo) async {
    final db = await instance.database;

    final id = await db.insert(tableTodo, todo.toJson());

    return todo.copy(id: id);
  }

  Future<Todo> readTodo(bool isDone) async {
    final db = await instance.database;

    final maps = await db.query(tableTodo,
        columns: TodoTable.values,
        where: '${TodoTable.isDone} = ?',
        whereArgs: [isDone ? 1 : 0]);

    if (maps.isNotEmpty) {
      return Todo.fromJson(maps);
    }
  }
  /*Future addTracker(String name, TrackerType type, int colorId,
      [int rangeMax = 10]) async {
    final db = await instance.database;

    String typeToString(type) {
      switch (type) {
        case TrackerType.score:
          return 'score';
        case TrackerType.stars:
          rangeMax = 5;
          return 'stars';
        case TrackerType.counter:
          rangeMax = 0;
          return 'counter';
        default:
          return 'ERROR';
      }
    }

    final id = await db.rawInsert('''
      INSERT INTO trackersList (
        name_tracker,
        type_tracker,
        color_id_tracker,
        range_tracker
        )
      VALUES(?, ?, ?, ?)''', [name, typeToString(type), colorId, rangeMax]);
  }*/
}
