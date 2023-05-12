import 'package:flutter/material.dart';
import 'screens/tracker/trackerscreen.dart';
import 'database/databaseusage.dart';
import 'database/todomodel.dart';
import 'database/trackermodel.dart';
import 'database/statsmodel.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// ------ CHANGE NOTIFIER ------

class MyAppState extends ChangeNotifier {
  late List<Todo> TodoList = [];
  late List<Todo> DoneList = [];

  List<Tracker> trackers = [];

  var db = OrganiserDatabase.instance;

  // ------ TO DO ------

  void importTodo() async {
    TodoList = await db.readTodos(false);
    DoneList = await db.readTodos(true);
    notifyListeners();
  }

  // CREATING NEW TO-DO LIST ELEMENTS
  Future<void> addTodo(var title) async {
    var newTodo = Todo(value: title, isDone: false);
    newTodo = await db.createTodo(newTodo);
    TodoList.insert(0, newTodo);

    notifyListeners();
  }

  // FINISHING A TASK AND DELETING IT FROM TO DO'S
  void switchListsTodo(
      List<Todo> fromList, List<Todo> toList, Todo task, int idx) {
    //task.isDone = !task.isDone;
    toList.insert(0, fromList[idx]);
    fromList.removeAt(idx);
    db.updateTodo(task);

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
    notifyListeners();
  }

  void addTracker(String title, TrackerType type, int colorId,
      [int rangeMax = 10]) async {
    var tracker = Tracker(
      name: title,
      type: typeConverterToString(type),
      color: colorId,
      range: rangeMax,
      isLocked: false,
    );
    tracker = await db.createTracker(tracker);
    trackers.add(tracker);

    notifyListeners();
  }

  void saveValueToTracker(Tracker tracker, double value) async {
    tracker.value = value;
    tracker.isLocked = true;
    DateTime todaysDate = DateTime.now();
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

  void dailyTrackerUnlock() async {
    var list = await db.checkSavedDay();
    DateTime now = DateTime.now();

    bool isSameDay(DateTime? dateA, DateTime? dateB) {
      return dateA?.year == dateB?.year &&
          dateA?.month == dateB?.month &&
          dateA?.day == dateB?.day;
    }

    if (list.isEmpty) {
      await db.resetTime(now.toIso8601String());

      notifyListeners();
    } else {
      DateTime saved_time = DateTime.parse(list[0]['current_time']);
      if (!isSameDay(now, saved_time)) {
        await db.resetTime(now.toIso8601String());
        await db.unlockAllTrackers();
        importTrackers();

        notifyListeners();
      }
    }
  }

  // ------ STATS ------

  // ------ TESTING ------
  void fillUpTrackersStats(int howManyDaysToFabricate) async {
    for (int i = 0; i < trackers.length; i++) {
      for (int j = 0; j < howManyDaysToFabricate; j++) {
        var randGenerator = Random();
        DateTime date = DateTime.now().subtract(Duration(days: j));
        Stat stat = Stat(
          tracker_id: trackers[i].id!,
          year: date.year,
          month: date.month,
          day: date.day,
          value: randGenerator.nextInt(10).toDouble(),
        );
        await db.createStat(stat);
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

  void changeTodayTimeBackwards() async {
    String dayBeforeYesterday =
        DateTime.now().subtract(Duration(days: 2)).toIso8601String();

    checkDatabase();

    print(dayBeforeYesterday);
    await db.resetTime(dayBeforeYesterday);
  }

  void checkDatabase() async {
    print(await db.readTrackers());
    print(await db.checkSavedDay());
  }
}
