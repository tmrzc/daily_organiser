import 'package:flutter/material.dart';
import 'screens/tracker/trackerscreen.dart';
import 'database/databaseusage.dart';
import 'database/todomodel.dart';
import 'database/trackermodel.dart';

// ------ CHANGE NOTIFIER ------

class MyAppState extends ChangeNotifier {
  /*MyAppState() {
    importTodo();
  }*/

  late List<Todo> TodoList = [];
  late List<Todo> DoneList = [];
  var db = OrganiserDatabase.instance;

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

  List<Tracker> trackers = [];

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

    await db.updateTracker(tracker);

    notifyListeners();
  }

  void enableTracker(Tracker tracker) async {
    tracker.value = null;
    tracker.isLocked = false;

    await db.updateTracker(tracker);

    notifyListeners();
  }

  void removeTracker(Tracker tracker) async {
    await db.deleteTracker(tracker);
    trackers.remove(tracker);

    notifyListeners();
  }
}
