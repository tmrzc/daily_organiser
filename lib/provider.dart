import 'package:flutter/material.dart';
import 'screens/tracker/trackerscreen.dart';
import 'database/databaseusage.dart';
import 'database/todomodel.dart';
import 'database/trackermodel.dart';
import 'database/statsmodel.dart';
import 'database/notemodel.dart';
import 'database/todoweeklymodel.dart';
import 'dart:math';
import 'dart:developer';

// ------ CHANGE NOTIFIER ------

class MyAppState extends ChangeNotifier {
  DateTime? currentTime;
  bool isDailyChangeActive = false;

  late List<Todo> TodoList = [];
  late List<Todo> DoneList = [];

  List<Tracker> trackers = [];

  var db = OrganiserDatabase.instance;

  // ------ TODOMANAGER ------

  Future<TodoManager> addTodoManager(TodoManager todoManager) async {
    final newTodoManager = await db.createTodoManager(todoManager);
    notifyListeners();
    return newTodoManager;
  }

  // ------ JOURNAL ------

  void saveNote(String noteContent, DateTime dateTime) async {
    await db.createNote(Note(
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      note: noteContent,
    ));
    notifyListeners();
  }

  void editNote(Note note) async {
    await db.updateNote(note);
    notifyListeners();
  }

  void deleteNote(Note note) async {
    await db.deleteNote(note);
    notifyListeners();
  }

  // ------ TO DO ------

  void importTodo() async {
    TodoList = await db.readTodos(false);
    DoneList = await db.readTodos(true);
    notifyListeners();
  }

  void importTodoFromManager(TodoManager tM) {
    var now = DateTime.now();
    List<bool> managersDays = [
      tM.mon,
      tM.tue,
      tM.wed,
      tM.thu,
      tM.fr,
      tM.sat,
      tM.sun
    ];

    if (managersDays[now.weekday - 1]) {
      addTodo(tM.title, false, tM);
    }
    notifyListeners();
  }

  Future<int> importTodaysTodoManagers(DateTime now) async {
    List<TodoManager> recursiveTodoManagers =
        await db.readManagersOfSelectedDay(now.weekday);

    for (int i = 0; i < recursiveTodoManagers.length; i++) {
      addTodo(recursiveTodoManagers[i].title, false, recursiveTodoManagers[i]);
    }

    notifyListeners();
    return recursiveTodoManagers.length;
  }

  void deleteTodoManager(TodoManager todoManager) async {
    await db.deleteTodoManager(todoManager);
    notifyListeners();
  }

  void deleteTodoFromManager(TodoManager todoManager) async {
    await db.deleteTodoFromManager(todoManager);
    notifyListeners();
  }

  // CREATING NEW TO-DO LIST ELEMENTS
  Future<void> addTodo(var title, bool isDone,
      [TodoManager? todoManager]) async {
    late var newTodo;

    if (isDone) {
      todoManager == null
          ? newTodo = Todo(value: title, isDone: true)
          : newTodo =
              Todo(value: title, isDone: true, manager_id: todoManager.id);
      DoneList.insert(0, newTodo);
    } else {
      todoManager == null
          ? newTodo = Todo(value: title, isDone: false)
          : newTodo =
              Todo(value: title, isDone: false, manager_id: todoManager.id);
      TodoList.insert(0, newTodo);
    }

    newTodo = await db.createTodo(newTodo);

    notifyListeners();
  }

  // FINISHING A TASK AND DELETING IT FROM TO DO'S
  void switchListsTodo(
      List<Todo> fromList, List<Todo> toList, Todo task, int idx) async {
    //task.isDone = !task.isDone;

    await db.updateTodo(task).then((value) {
      toList.insert(0, fromList[idx]);
      fromList.removeAt(idx);
    });

    notifyListeners();
  }

  void clearlist() {
    db.deleteDoneTodo();
    DoneList.clear();
    notifyListeners();
  }

  // ------ TRACKERS ------

  void importTrackers() async {
    trackers = await db.readTrackers();
    //inspect(trackers);
    notifyListeners();
  }

  Future addTracker(String title, TrackerType type, int colorId,
      [int rangeMax = 10]) async {
    var tracker = Tracker(
      name: title,
      type: typeConverterToString(type),
      color: colorId,
      range: rangeMax,
      isLocked: false,
    );
    tracker = await db.createTracker(tracker);
    updateTracker(tracker);
    trackers.isEmpty ? trackers.add(tracker) : trackers.insert(0, tracker);

    notifyListeners();
  }

  void saveValueToTracker(Tracker tracker, double value,
      [int year = 0, int month = 0, int day = 0]) async {
    tracker.value = value;
    tracker.isLocked = true;
    DateTime todaysDate = DateTime.now();

    if (year != 0 && month != 0 && day != 0) {
      todaysDate = DateTime.utc(year, month, day);
    }

    Stat tracker_stat = Stat(
      tracker_id: tracker.id!,
      year: todaysDate.year,
      month: todaysDate.month,
      day: todaysDate.day,
      value: tracker.value!,
    );
    tracker_stat = await db.createStat(tracker_stat);
    tracker.stats_id = tracker_stat.id;

    await db.updateTracker(tracker);

    notifyListeners();
  }

  void trackerPrioritySwap(int idx, bool toTop) async {
    int tempUp = 0;
    int tempDown = 0;

    if (toTop == true) {
      tempUp = trackers[idx - 1].priority!;
      tempDown = trackers[idx].priority!;
      trackers[idx - 1].priority = tempDown;
      trackers[idx].priority = tempUp;
      await db.updateTracker(trackers[idx]);
      await db.updateTracker(trackers[idx - 1]);
    } else {
      tempDown = trackers[idx + 1].priority!;
      tempUp = trackers[idx].priority!;
      trackers[idx + 1].priority = tempUp;
      trackers[idx].priority = tempDown;
      await db.updateTracker(trackers[idx]);
      await db.updateTracker(trackers[idx + 1]);
    }
    importTrackers();
  }

  void updateTracker(Tracker tracker) async {
    await db.updateTracker(tracker);
    notifyListeners();
  }

  void enableTracker(Tracker tracker) async {
    tracker.value = null;
    tracker.isLocked = false;

    await db.deleteStat(tracker.stats_id!);
    tracker.stats_id = null;

    await db.updateTracker(tracker);

    notifyListeners();
  }

  void removeTracker(Tracker tracker) async {
    await db.deleteTracker(tracker);
    await db.clearAfterDeletingTracker(tracker.id!);
    trackers.remove(tracker);

    notifyListeners();
  }

  bool isSameDay(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year &&
        dateA?.month == dateB?.month &&
        dateA?.day == dateB?.day;
  }

  void dailyTrackerAndTodoCheck() async {
    var list = await db.checkSavedDay();
    DateTime now = DateTime.now();

    if (list.isEmpty) {
      await db.resetTime(now.toIso8601String());

      notifyListeners();
    } else {
      DateTime saved_time = DateTime.parse(list[0]['current_time']);
      if (!isSameDay(now, saved_time)) {
        await db.resetTime(now.toIso8601String()).then((value) async {
          await db.unlockAllTrackers().then((value) {
            importTrackers();
          });
          await importTodaysTodoManagers(now).then((value) {
            importTodo();
          });
        });
        //notifyListeners();
      }
    }
  }

  /*void dailyTodoLoading() async {
    var list = await db.checkSavedDay();
    DateTime now = DateTime.now();

    if (list.isEmpty) {
      await db.resetTime(now.toIso8601String());

      notifyListeners();
    } else {
      DateTime saved_time = DateTime.parse(list[0]['current_time']);
      if (!isSameDay(now, saved_time)) {
        //print(
        //'------------------LOAD TO DO AND UNLOCK TRACKERS------------------');
        await db.resetTime(now.toIso8601String());

        importTodaysTodoManagers(now);

        notifyListeners();
      }
    }
  }

  void dailyTrackerUnlock() async {
    var list = await db.checkSavedDay();
    DateTime now = DateTime.now();

    if (list.isEmpty) {
      await db.resetTime(now.toIso8601String());

      notifyListeners();
    } else {
      DateTime saved_time = DateTime.parse(list[0]['current_time']);
      if (!isSameDay(now, saved_time)) {
        //print('------------------UNLOCK TRACKERS------------------');
        await db.resetTime(now.toIso8601String());

        await db.unlockAllTrackers();
        importTrackers();

        notifyListeners();
      }
    }
  }*/

  // ------ STATS ------

  void createStat(Stat stat) async {
    await db.createStat(stat);
    notifyListeners();
  }

  void updateStat(Stat stat) async {
    await db.updateStat(stat);
    notifyListeners();
  }

  void deleteStat(Stat stat) async {
    await db.deleteStat(stat.id!);
    notifyListeners();
  }

  // ------ TESTING ------
  void fillUpTrackersStats(int howManyDaysToFabricate, int range) async {
    for (int i = 0; i < trackers.length; i++) {
      var randGenerator = Random();
      for (int j = 1; j < howManyDaysToFabricate; j += 10) {
        for (int k = 0; k < 5; k++) {
          DateTime date = DateTime.now().subtract(Duration(days: j + k));
          Stat stat = Stat(
            tracker_id: trackers[i].id!,
            year: date.year,
            month: date.month,
            day: date.day,
            value: randGenerator.nextInt(trackers[i].range).toDouble(),
          );
          await db.createStat(stat);
        }
      }
    }
    notifyListeners();
  }

  void testUnockingTrackers() async {
    await db.unlockAllTrackers();

    checkDatabase();

    importTrackers();
    notifyListeners();
  }

  void changeTodayTimeBackwards10days() async {
    String dayBeforeYesterday =
        DateTime.now().subtract(Duration(days: 10)).toIso8601String();

    //checkDatabase();

    //print(dayBeforeYesterday);
    await db.resetTime(dayBeforeYesterday);
    //notifyListeners();
  }

  void checkDatabase() async {
    //print(await db.readTrackers());
    //print(await db.checkSavedDay());
  }
}
