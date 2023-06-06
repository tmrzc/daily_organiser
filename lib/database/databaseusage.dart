import 'package:daily_organiser/database/notemodel.dart';
import 'package:sqflite/sqflite.dart';
import 'todomodel.dart';
import 'trackermodel.dart';
import 'statsmodel.dart';
import 'notemodel.dart';
import 'package:path/path.dart';
import 'dart:developer';
import 'todoweeklymodel.dart';

class OrganiserDatabase {
  static final OrganiserDatabase instance = OrganiserDatabase._init();

  static Database? _database;

  OrganiserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('database.db');
    return _database!;
  }

  //late String path1;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    //path1 = path;

    return await openDatabase(path,
        version: 12, onCreate: _createDB, onUpgrade: _onUpgrade);
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
    CREATE TABLE $tableTodoManager (
      ${TodoManagerTable.id} $idType,
      ${TodoManagerTable.mon} $boolType,
      ${TodoManagerTable.tue} $boolType,
      ${TodoManagerTable.wed} $boolType,
      ${TodoManagerTable.thu} $boolType,
      ${TodoManagerTable.fr} $boolType,
      ${TodoManagerTable.sat} $boolType,
      ${TodoManagerTable.sun} $boolType,
      ${TodoManagerTable.title} $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableNotes (
      ${JournalNotes.id} $idType,
      ${JournalNotes.dateYear} $integerType,
      ${JournalNotes.dateMonth} $integerType,
      ${JournalNotes.dateDay} $integerType,
      ${JournalNotes.noteContent} $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableTodo (
      ${TodoTable.id} $idType,
      ${TodoTable.value_todo} $textType,
      ${TodoTable.isDone} $boolType,
      ${TodoTable.manager_id} $integerTypeNULLABLE
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
      ${TrackerTable.stats_id} $integerTypeNULLABLE,
      ${TrackerTable.priority} $integerTypeNULLABLE
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

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'DOUBLE NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const doubleTypeNULLABLE = 'DOUBLE';
    const integerTypeNULLABLE = 'INTEGER';

    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE $tableNotes');
      await db.execute('DROP TABLE $tableTodo');
      await db.execute('DROP TABLE $tableTracker');
      await db.execute('DROP TABLE $tableStats');
      await db.execute('DROP TABLE $tableTodoManager');
      await db.execute('DROP TABLE currentTime');

      await db.execute('''
    CREATE TABLE currentTime (
      current_time $textType
    ) 
    ''');

      await db.execute('''
    CREATE TABLE $tableTodoManager (
      ${TodoManagerTable.id} $idType,
      ${TodoManagerTable.mon} $boolType,
      ${TodoManagerTable.tue} $boolType,
      ${TodoManagerTable.wed} $boolType,
      ${TodoManagerTable.thu} $boolType,
      ${TodoManagerTable.fr} $boolType,
      ${TodoManagerTable.sat} $boolType,
      ${TodoManagerTable.sun} $boolType,
      ${TodoManagerTable.title} $textType
    )
    ''');

      await db.execute('''
    CREATE TABLE $tableNotes (
      ${JournalNotes.id} $idType,
      ${JournalNotes.dateYear} $integerType,
      ${JournalNotes.dateMonth} $integerType,
      ${JournalNotes.dateDay} $integerType,
      ${JournalNotes.noteContent} $textType
    )
    ''');

      await db.execute('''
    CREATE TABLE $tableTodo (
      ${TodoTable.id} $idType,
      ${TodoTable.value_todo} $textType,
      ${TodoTable.isDone} $boolType,
      ${TodoTable.manager_id} $integerTypeNULLABLE
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
      ${TrackerTable.stats_id} $integerTypeNULLABLE,
      ${TrackerTable.priority} $integerTypeNULLABLE
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
  }

  Future<void> deleteDatabase(String path) =>
      databaseFactory.deleteDatabase(path);

// ------ MANAGER ------

  Future<TodoManager> createTodoManager(TodoManager todoManager) async {
    final db = await instance.database;

    final id = await db.insert(tableTodoManager, todoManager.toJson());

    return todoManager.copy(id: id);
  }

  Future<List<TodoManager>> readManagersOfSelectedDay(int weekDay) async {
    final db = await instance.database;
    late var query;

    switch (weekDay) {
      case 1:
        query = TodoManagerTable.mon;
        break;
      case 2:
        query = TodoManagerTable.tue;
        break;
      case 3:
        query = TodoManagerTable.wed;
        break;
      case 4:
        query = TodoManagerTable.thu;
        break;
      case 5:
        query = TodoManagerTable.fr;
        break;
      case 6:
        query = TodoManagerTable.sat;
        break;
      case 7:
        query = TodoManagerTable.sun;
        break;
      default:
    }

    final listOfMaps = await db.query(
      tableTodoManager,
      where: '$query = ?',
      whereArgs: [1],
    );

    return listOfMaps.map((json) => TodoManager.fromJson(json)).toList();
  }

  Future<List<TodoManager>> readTodoManagers() async {
    final db = await instance.database;

    final listOfMaps = await db.query(tableTodoManager);

    return listOfMaps.map((json) => TodoManager.fromJson(json)).toList();
  }

  Future<TodoManager> readSelectedTodoManager(TodoManager todoManager) async {
    final db = await instance.database;

    final listOfMaps = await db.query(
      tableTodoManager,
      where: '${TodoManagerTable.id} = ?',
      whereArgs: [todoManager.id],
    );

    return listOfMaps.map((json) => TodoManager.fromJson(json)).toList()[0];
  }

  Future<int> deleteTodoManager(TodoManager todoManager) async {
    final db = await instance.database;

    return db.delete(
      tableTodoManager,
      where: '${TodoManagerTable.id} = ?',
      whereArgs: [todoManager.id],
    );
  }

  Future<int> updateTodoManger(TodoManager todoManager) async {
    final db = await instance.database;

    return db.update(
      tableTodoManager,
      todoManager.toJson(),
      where: '${TodoManagerTable.id} = ?',
      whereArgs: [todoManager.id],
    );
  }

  Future<int> deleteTodoFromManager(TodoManager todoManager) async {
    final db = await instance.database;

    return db.delete(
      tableTodo,
      where: '${TodoTable.manager_id} = ?',
      whereArgs: [todoManager.id],
    );
  }

// ------ NOTES DATABASE ------

  Future<Note> createNote(Note note) async {
    final db = await instance.database;

    final id = await db.insert(tableNotes, note.toJson());

    return note.copy(id: id);
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;

    final listOfMaps = await db.query(
      tableNotes,
      orderBy:
          '${JournalNotes.dateYear} DESC, ${JournalNotes.dateMonth} DESC, ${JournalNotes.dateDay} DESC',
    );

    return listOfMaps.map((json) => Note.fromJson(json)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${JournalNotes.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(Note note) async {
    final db = await instance.database;

    return db.delete(
      tableNotes,
      where: '${JournalNotes.id} = ?',
      whereArgs: [note.id],
    );
  }

// ------ TODO DATABASE ------

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

// ------ TRACKER DATABASE ------

  Future<Tracker> createTracker(Tracker tracker) async {
    final db = await instance.database;

    final trackerId = await db.insert(tableTracker, tracker.toJson());

    return tracker.copy(id: trackerId, priority: trackerId);
  }

  Future prioritySwap(Tracker tracker1, Tracker tracker2) async {
    final db = await instance.database;
    int temp = tracker2.priority!;
    tracker2.priority = tracker1.priority;
    tracker1.priority = temp;

    await updateTracker(tracker1);
    await updateTracker(tracker2);
  }

  Future<List<Tracker>> readTrackers() async {
    final db = await instance.database;

    final listOfMaps = await db.query(tableTracker,
        columns: TrackerTable.values, orderBy: '${TrackerTable.priority} DESC');

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

  Future<int> updateStat(Stat stat) async {
    final db = await instance.database;

    return db.update(tableStats, stat.toJson(),
        where: '${TrackerStats.id_stats} = ?', whereArgs: [stat.id]);
  }

  Future<int> clearAfterDeletingTracker(int tracker_id) async {
    final db = await instance.database;

    return db.delete(
      tableStats,
      where: '${TrackerStats.tracker_id} = ?',
      whereArgs: [tracker_id],
    );
  }

  Future<List<Stat>> readStats(int tracker_id) async {
    final db = await instance.database;

    final listOfMaps = await db.query(tableStats,
        orderBy:
            '${TrackerStats.date_year} DESC, ${TrackerStats.date_month} DESC, ${TrackerStats.date_day} DESC',
        where: '${TrackerStats.tracker_id} = ?',
        whereArgs: [tracker_id]);

    return listOfMaps.map((json) => Stat.fromJson(json)).toList();
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
              value: -1,
            )
          : listOfMaps.map((json) => Stat.fromJson(json)).toList()[0];

      listOfXDays.add(stat);
    }

    return listOfXDays;
  }

  Future<List<Stat>> returnSelectedDateStat(
      DateTime dateTime, int tracker_id) async {
    final db = await instance.database;

    List<Map<String, Object?>> listOfMaps = await db.query(
      tableStats,
      where: '''${TrackerStats.tracker_id} = ? AND 
                ${TrackerStats.date_year} = ? AND
                ${TrackerStats.date_month} = ? AND
                ${TrackerStats.date_day} = ?''',
      whereArgs: [tracker_id, dateTime.year, dateTime.month, dateTime.day],
      limit: 1,
    );

    return listOfMaps.map((json) => Stat.fromJson(json)).toList();
  }

  Future<double> returnHighestValue(int tracker_id) async {
    final db = await instance.database;

    List<Map<String, Object?>> listOfMaps = await db.query(
      tableStats,
      where: '${TrackerStats.tracker_id} = ?',
      whereArgs: [tracker_id],
      orderBy: '${TrackerStats.value_stats} DESC',
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
